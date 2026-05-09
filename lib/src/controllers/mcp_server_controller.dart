import 'dart:async';
import 'package:finch/finch_route.dart';
import 'package:finch/finch_tools.dart';
import 'package:mcp_models/mcp_models.dart';

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
///     mcp.method('notifications/initialized', (p) async =>
///         JSONRPCNotification(method: 'notifications/initialized'));
///   }
/// }
/// ```
abstract class McpServerController extends Controller {
  McpBuilder? _mcpBuilder;

  /// Lazily built once per controller instance.
  /// Since Finch controllers are per-request, [configure] is always called
  /// with the live [rq] object, making request-scoped values (e.g. `rq.url()`)
  /// safe to use inside [configure].
  McpBuilder get _registry {
    if (_mcpBuilder == null) {
      _mcpBuilder = McpBuilder();
      configure(_mcpBuilder!);
    }
    return _mcpBuilder!;
  }

  /// Register all MCPP capabilities for this server.
  ///
  /// Implement this method to register tools, resources, prompts, resource
  /// templates, and custom method handlers via [McpBuilder].
  void configure(McpBuilder mcp);

  @override
  Future<String> index() async {
    final payload = rq.getAll().removeAll(['POST', 'GET', 'FILE']);
    try {
      final JSONRPCRequest rpcRequest = JSONRPCRequest.toMCP(payload);

      final stream = Stream.fromFuture(Future(() async {
        final response = await _dispatch(
          rpcRequest.method,
          rpcRequest.id,
          payload,
        );
        return SSE(data: FinchJson.jsonEncoder(response.toMap()));
      }));
      return await rq.renderSSE(stream);
    } catch (e) {
      final errorResponse = JSONRPCErrorResponse(
        id: payload['id']?.toString() ?? '-1',
        error: Error(code: -32600, message: 'Invalid Request: $e'),
      );

      final stream = Stream.fromIterable([
        SSE(
          data: FinchJson.jsonEncoder(errorResponse.toMap()),
        ),
      ]);

      return await rq.renderSSE(stream, status: 400);
    }
  }

  // ── Central dispatcher ────────────────────────────────────────────────────

  Future<MCP> _dispatch(
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
        return JSONRPCResultResponse(result: EmptyResult());

      case 'initialize':
        return _buildInitializeResponse(id, registry);

      case 'tools/list':
        return ListToolsResultResponse(
            id: id, result: registry.buildToolsResult());

      case 'tools/call':
        return await _dispatchToolCall(payload, id, registry);

      case 'resources/list':
        return ListResourcesResultResponse(
            id: id, result: registry.buildResourcesResult());

      case 'resources/read':
        return await _dispatchResourceRead(payload, id, registry);

      case 'resources/templates/list':
        return ListResourceTemplatesResultResponse(
            id: id, result: registry.buildResourceTemplatesResult());

      case 'prompts/list':
        return ListPromptsResultResponse(
            id: id, result: registry.buildPromptsResult());

      case 'prompts/get':
        return await _dispatchPromptGet(payload, id, registry);

      case 'notifications/initialized':
        return JSONRPCNotification(method: 'notifications/initialized');

      case 'logging/setLevel':
        return SetLevelResultResponse(id: id, result: Result());

      default:
        return JSONRPCErrorResponse(
          id: id,
          error: Error(code: -32601, message: 'Method not found: $method'),
        );
    }
  }

  // ── Built-in handlers ────────────────────────────────────────────────────

  MCP _buildInitializeResponse(String id, McpBuilder registry) {
    return InitializeResultResponse(
      id: id,
      result: InitializeResult(
        capabilities: ServerCapabilities({
          'tools': registry.buildToolsResult().toMap(),
          'resources': {'list': true, 'read': true},
          'prompts': {'list': true, 'get': true},
        }),
        serverInfo: Implementation(
          name: 'finch-mcp-server',
          version: '1.0.0',
        ),
      ),
    );
  }

  Future<MCP> _dispatchToolCall(
    Map<String, Object?> payload,
    String id,
    McpBuilder registry,
  ) async {
    final request = CallToolRequest.toMCP(payload);
    final handler = registry.toolHandler(request.params.name);
    if (handler == null) {
      return JSONRPCErrorResponse(
        id: id,
        error: Error(
            code: -32601, message: 'Tool not found: ${request.params.name}'),
      );
    }
    return CallToolResultResponse(id: id, result: await handler(request));
  }

  Future<MCP> _dispatchResourceRead(
    Map<String, Object?> payload,
    String id,
    McpBuilder registry,
  ) async {
    final request = ReadResourceRequest.toMCP(payload);
    final handler = registry.resourceHandlerByUri(request.params.uri);
    if (handler == null) {
      return JSONRPCErrorResponse(
        id: id,
        error: Error(
            code: -32601, message: 'Resource not found: ${request.params.uri}'),
      );
    }
    return ReadResourceResultResponse(id: id, result: await handler(request));
  }

  Future<MCP> _dispatchPromptGet(
    Map<String, Object?> payload,
    String id,
    McpBuilder registry,
  ) async {
    final request = GetPromptRequest.toMCP(payload);
    final handler = registry.promptHandler(request.params.name);
    if (handler == null) {
      return JSONRPCErrorResponse(
        id: id,
        error: Error(
            code: -32601, message: 'Prompt not found: ${request.params.name}'),
      );
    }
    return GetPromptResultResponse(id: id, result: await handler(request));
  }
}
