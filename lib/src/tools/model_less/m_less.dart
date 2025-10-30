import 'model_less.dart';

/// A class that wraps around [ModelLess] and provides additional functionality or abstraction.
/// This class is designed to manage and interact with an instance of [ModelLess].
/// It initializes with a [ModelLess] object or creates a default instance from an empty JSON string if none is provided.
class MLess {
  /// The [ModelLess] instance associated with this class.
  late ModelLess model;

  /// Creates an instance of [MLess] with the specified [ModelLess] object.
  ///
  /// If no [ModelLess] object is provided, a default instance is created using an empty JSON string.
  ///
  /// [model] The optional [ModelLess] object to initialize with. If `null`, a default instance will be used.
  MLess({ModelLess? model}) {
    this.model = model ?? ModelLess.fromJson("{}");
  }

  /// Returns a string representation of the [MLess] instance.
  ///
  /// This method delegates the string conversion to the underlying [ModelLess] instance.
  ///
  /// Returns: A string representation of the [ModelLess] instance, as defined by its `toString()` method.
  @override
  String toString() {
    return model.toString();
  }
}
