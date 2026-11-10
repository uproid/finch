import 'dart:async';
import 'package:finch/finch_route.dart';
import 'package:finch/finch_tools.dart';
import 'package:mcp_models/mcp_models_v2026.dart' as v26;
import 'package:mcp_models/mcp_models_v2025.dart' as v25;

/// Abstract base for MCPP-compatible controllers in the Finch framework.
///
/// Extend this class and implement [configure] to declaratively register
/// all MCPP capabilities using [McpBuilder]. The controller handles all
/// standard MCPP JSON-RPC routing automatically.
///
/// ```dart
/// class MyMcpController extends McpController {
///   @override
///   void configure(McpBuilder mcp) {
///     mcp.tool(
///       name: 'hello',
///       description: 'Says hello',
///       handler: (req) async =>
///           CallToolResult(content: [TextContent(text: 'Hello!')]),
///     );
///
///     mcp.resource(
///       name: 'readme',
///       uri: rq.url(''),
///       handler: (req) async => ReadResourceResult(contents: [...]),
///     );
///
///     // Override or extend built-in method routing:
///     mcp.method('server/discover', (p) async =>
///         JSONRPCResultResponse(result: EmptyResult()));
///   }
/// }
/// ```
abstract class McpServerController extends Controller {
  v26.McpBuilder? _mcpBuilder;

  /// Lazily built once per controller instance.
  /// Since Finch controllers are per-request, [configure] is always called
  /// with the live [rq] object, making request-scoped values (e.g. `rq.url()`)
  /// safe to use inside [configure].
  v26.McpBuilder get _registry {
    if (_mcpBuilder == null) {
      _mcpBuilder = v26.McpBuilder();
      configure(_mcpBuilder!);
    }
    return _mcpBuilder!;
  }

  /// Register all MCPP capabilities for this server.
  ///
  /// Implement this method to register tools, resources, prompts, resource
  /// templates, and custom method handlers via [McpBuilder].
  void configure(v26.McpBuilder mcp);

  McpProtocolVersion _findRequestVersion(Map<String, Object?> rpcRequest) {
    // Real MCP clients never send a top-level "version" field. The actual
    // signal is the `Mcp-Protocol-Version` header (Streamable HTTP transport,
    // sent on every request after initialize), `params.protocolVersion`
    // (sent on `initialize`), or `params._meta`'s protocolVersion key (sent
    // per-request by 2026-07-28 clients).
    String? stringVersion = rq.headers.value('mcp-protocol-version');

    final params = rpcRequest['params'];
    if (params is Map) {
      stringVersion ??= params['protocolVersion']?.toString();

      final meta = params['_meta'];
      if (meta is Map) {
        stringVersion ??=
            meta['io.modelcontextprotocol/protocolVersion']?.toString();
      }
    }

    stringVersion ??= '2025-11-25';
    if (stringVersion.contains('2026')) {
      return McpProtocolVersion.v2026_07_28;
    }
    return McpProtocolVersion.v2025_11_25;
  }

  @override
  Future<String> index() async {
    final payload = rq.getAll().removeAll(['POST', 'GET', 'FILE']);
    var version = _findRequestVersion(payload);
    if (version == McpProtocolVersion.v2026_07_28) {
      return _renderV26(payload);
    }
    return _renderV25(payload);
  }

  Future<String> _renderV25(Map<String, Object?> payload) async {
    try {
      final v25.JSONRPCRequest rpcRequest = v25.JSONRPCRequest.toMCP(payload);

      final stream = Stream.fromFuture(Future(() async {
        final response = await _dispatchV25(
          rpcRequest.method,
          rpcRequest.id,
          payload,
        );
        return SSE(data: FinchJson.jsonEncoder(response.toMap()));
      }));
      return await rq.renderSSE(stream);
    } catch (e) {
      final errorResponse = v25.JSONRPCErrorResponse(
        id: payload['id']?.toString() ?? '-1',
        error: v25.Error(code: -32600, message: 'Invalid Request: $e'),
      );

      final stream = Stream.fromIterable([
        SSE(
          data: FinchJson.jsonEncoder(errorResponse.toMap()),
        ),
      ]);
      return await rq.renderSSE(stream, status: 400);
    }
  }

  Future<String> _renderV26(Map<String, Object?> payload) async {
    try {
      final v26.JSONRPCRequest rpcRequest = v26.JSONRPCRequest.toMCP(payload);
      final stream = Stream.fromFuture(Future(() async {
        final response = await _dispatchV26(
          rpcRequest.method,
          rpcRequest.id,
          payload,
        );
        return SSE(data: FinchJson.jsonEncoder(response.toMap()));
      }));
      return await rq.renderSSE(stream);
    } catch (e) {
      final errorResponse = v26.JSONRPCErrorResponse(
        id: payload['id']?.toString() ?? '-1',
        error: v26.Error(code: -32600, message: 'Invalid Request: $e'),
      );

      final stream = Stream.fromIterable([
        SSE(
          data: FinchJson.jsonEncoder(errorResponse.toMap()),
        ),
      ]);
      return await rq.renderSSE(stream, status: 400);
    }
  }

  Future<v25.MCP> _dispatchV25(
    String method,
    String id,
    Map<String, Object?> payload,
  ) async {
    final registry = _registry;

    // Custom handlers registered via mcp.method() take priority.
    final customHandler = registry.methodHandler(method);
    if (customHandler != null) return await customHandler(payload);

    switch (method) {
      case '':
        return v25.JSONRPCResultResponse(result: v25.EmptyResult());

      case 'initialize':
        return _buildInitializeResponse(id, registry);

      case 'tools/list':
        return v26.ListToolsResultResponse(
            id: id, result: registry.buildToolsResult());

      case 'tools/call':
        return await _dispatchToolCall(payload, id, registry);

      case 'resources/list':
        return v26.ListResourcesResultResponse(
            id: id, result: registry.buildResourcesResult());

      case 'resources/read':
        return await _dispatchResourceRead(payload, id, registry);

      case 'resources/templates/list':
        return v26.ListResourceTemplatesResultResponse(
            id: id, result: registry.buildResourceTemplatesResult());

      case 'prompts/list':
        return v26.ListPromptsResultResponse(
            id: id, result: registry.buildPromptsResult());

      case 'prompts/get':
        return await _dispatchPromptGet(payload, id, registry);

      case 'notifications/initialized':
        return v25.JSONRPCNotification(method: 'notifications/initialized');

      case 'logging/setLevel':
        return v25.SetLevelResultResponse(id: id, result: v25.Result());

      default:
        return v25.JSONRPCErrorResponse(
          id: id,
          error: v25.Error(code: -32601, message: 'Method not found: $method'),
        );
    }
  }

  v25.MCP _buildInitializeResponse(String id, v26.McpBuilder registry) {
    return v25.InitializeResultResponse(
      id: id,
      result: v25.InitializeResult(
        capabilities: v25.ServerCapabilities({
          'tools': registry.buildToolsResult().toMap(),
          'resources': {'list': true, 'read': true},
          'prompts': {'list': true, 'get': true},
        }),
        serverInfo: v25.Implementation(
          name: 'finch-mcp-server',
          version: '1.0.0',
        ),
      ),
    );
  }

  Future<v26.MCP> _dispatchV26(
    String method,
    String id,
    Map<String, Object?> payload,
  ) async {
    final registry = _registry;
    // Custom handlers registered via mcp.method() take priority.
    final customHandler = registry.methodHandler(method);
    if (customHandler != null) return await customHandler(payload);

    switch (method) {
      case '':
        return v26.JSONRPCResultResponse(result: v26.EmptyResult());

      case 'server/discover':
        var res = _buildDiscoverResponse(id, registry);
        return res;

      case 'tools/list':
        return v26.ListToolsResultResponse(
            id: id, result: registry.buildToolsResult());

      case 'tools/call':
        return await _dispatchToolCall(payload, id, registry);

      case 'resources/list':
        return v26.ListResourcesResultResponse(
            id: id, result: registry.buildResourcesResult());

      case 'resources/read':
        return await _dispatchResourceRead(payload, id, registry);

      case 'resources/templates/list':
        return v26.ListResourceTemplatesResultResponse(
            id: id, result: registry.buildResourceTemplatesResult());

      case 'prompts/list':
        return v26.ListPromptsResultResponse(
            id: id, result: registry.buildPromptsResult());

      case 'prompts/get':
        return await _dispatchPromptGet(payload, id, registry);

      default:
        return v26.JSONRPCErrorResponse(
          id: id,
          error: v26.Error(code: -32601, message: 'Method not found: $method'),
        );
    }
  }

  v26.MCP _buildDiscoverResponse(String id, v26.McpBuilder registry) {
    return v26.DiscoverResultResponse(
      id: id,
      result: v26.DiscoverResult(
        supportedVersions: const ['2026-07-28'],
        capabilities: v26.ServerCapabilities({
          'tools': registry.buildToolsResult().toMap(),
          'resources': {'list': true, 'read': true},
          'prompts': {'list': true, 'get': true},
        }),
        ttlMs: const Duration(minutes: 5).inMilliseconds,
        cacheScope: v26.CacheScope.public,
      ),
    );
  }

  Future<v26.MCP> _dispatchToolCall(
    Map<String, Object?> payload,
    String id,
    v26.McpBuilder registry,
  ) async {
    final request = v26.CallToolRequest.toMCP(payload);
    final handler = registry.toolHandler(request.params.name);
    if (handler == null) {
      return v26.JSONRPCErrorResponse(
        id: id,
        error: v26.Error(
            code: -32601, message: 'Tool not found: ${request.params.name}'),
      );
    }
    return v26.CallToolResultResponse(id: id, result: await handler(request));
  }

  Future<v26.MCP> _dispatchResourceRead(
    Map<String, Object?> payload,
    String id,
    v26.McpBuilder registry,
  ) async {
    final request = v26.ReadResourceRequest.toMCP(payload);
    final handler = registry.resourceHandlerByUri(request.params.uri);
    if (handler == null) {
      return v26.JSONRPCErrorResponse(
        id: id,
        error: v26.Error(
            code: -32601, message: 'Resource not found: ${request.params.uri}'),
      );
    }
    return v26.ReadResourceResultResponse(
        id: id, result: await handler(request));
  }

  Future<v26.MCP> _dispatchPromptGet(
    Map<String, Object?> payload,
    String id,
    v26.McpBuilder registry,
  ) async {
    final request = v26.GetPromptRequest.toMCP(payload);
    final handler = registry.promptHandler(request.params.name);
    if (handler == null) {
      return v26.JSONRPCErrorResponse(
        id: id,
        error: v26.Error(
            code: -32601, message: 'Prompt not found: ${request.params.name}'),
      );
    }
    return v26.GetPromptResultResponse(id: id, result: await handler(request));
  }
}

enum McpProtocolVersion {
  v2025_11_25(
    version: '2025-11-25',
  ),
  v2026_07_28(
    version: '2026-07-28',
  );

  final String version;

  const McpProtocolVersion({
    required this.version,
  });
}
