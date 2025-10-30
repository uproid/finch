import 'package:finch/src/render/request.dart';
import 'package:finch/src/core/context.dart';

/// A base class for views in the web application.
/// The [FinchView] class provides the core structure for rendering views and
/// handling data within the application. It includes logic for rendering
/// widgets and allows derived classes to customize how data is processed.
/// Example usage:
/// ```dart
/// class MyCustomView extends FinchView {
///   MyCustomView({
///     required String widget,
///     Map<String, Object?> params = const {},
///   }) : super(widget: widget, params: params);
///   @override
///   Future<Map<String, Object?>> renderData() async {
///     // Custom data processing logic here.
///   }
/// }
/// ```
class FinchView {
  /// Gets the current WebRequest from the request context
  Request get rq => Context.rq;

  /// A map containing parameters that can be passed to the view for rendering.
  Map<String, Object?> params;

  /// The path to the widget or view template.
  String widget;

  /// Creates an instance of [FinchView].
  /// The constructor requires a [widget] path,
  /// with an optional [params] map that can be used to pass additional data
  /// to the view during rendering.
  FinchView({
    required this.widget,
    this.params = const {},
  });

  /// Renders the view.
  /// The [toData] parameter determines whether to render as raw data or
  /// as a fully rendered view using the specified widget template.
  /// If [toData] is `true`, the method returns the data processed by [renderData].
  /// Otherwise, it returns the rendered view content.
  /// If the [widget] path is empty, an error message is returned.
  Future<Object> render({bool toData = false}) async {
    if (toData) {
      return renderData();
    }
    if (widget.isEmpty) {
      return 'Widget of UIView is required.';
    }

    var view = await rq.render(
      path: widget,
      viewParams: {r'$v': await renderData()},
    );
    rq.removeParam(r'$v');

    return view;
  }

  /// Processes and returns the data for the view.
  /// This method returns the [params] map by default, but can be overridden
  /// in derived classes to implement custom data processing logic.
  /// Example:
  /// ```dart
  /// @override
  /// Future<Map<String, Object?>> renderData() async {
  ///   return {'key': 'value'};
  /// }
  /// ```
  Future<Map<String, Object?>> renderData() async {
    return params;
  }
}
