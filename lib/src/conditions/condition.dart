import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:dart_quill_delta_simplify/dart_quill_delta_simplify.dart';
import 'package:meta/meta.dart';
import 'package:uuid/v6.dart';

const UuidV6 _generator = UuidV6();

/// An abstract class representing a condition that can be applied to a `Delta` object.
///
/// This class is used to define a condition based on a `target` that can either be a `String` or a `Map`.
/// It provides utility methods for checking whether the target is valid or not and can be extended to build
/// specific conditions for processing `Delta` objects.
///
/// The `Condition` class is intended to be subclassed, as it contains an abstract `build` method that must
/// be implemented by subclasses to define the behavior of the condition.
abstract class Condition<T extends Object?> {
  // This is the key of the condition that need to be unique
  final String key;

  /// The target value that the condition is based on.
  ///
  /// The target can either be a `String` or a `Map`. This value is required when constructing
  /// the condition and is used to evaluate the condition logic.
  final Object? target;

  /// Indicates whether the condition should be case sensitive when comparing the `target`.
  ///
  /// This flag determines if string comparisons should be case sensitive. If set to `true`, the
  /// comparison will be case sensitive; otherwise, it will be case insensitive.
  final bool caseSensitive;

  Condition({
    required this.target,
    required this.caseSensitive,
    String? key,
  })  : assert(key == null || key.trim().isNotEmpty, 'key cannot be empty'),
        key = key ?? _generator.generate(),
        assert(
          target == null || target is String || target is Map,
          'Condition class only accepts "String" and "Map" types to be assigned for "target" param',
        );

  /// A getter that returns whether the `target` is valid.
  ///
  /// This is a convenience property that checks if the `target` is neither `null`, nor an empty `String`,
  /// nor an empty `Map`. It returns `true` if the target is valid.
  bool get checkIfTargetIsValid => !checkIfTargetIsinvalid;

  /// A getter that returns whether the `target` is invalid.
  ///
  /// This property checks if the `target` is either `null`, an empty `String`, or an empty `Map`.
  /// It returns `true` if the target is invalid.
  bool get checkIfTargetIsinvalid =>
      target == null ||
      target is String && '$target'.isEmpty ||
      target is Map && (target as Map).isEmpty;

  /// A getter that checks if the `target` can be used as a pattern.
  ///
  /// This property checks if the `target` is a non-empty `String` that can potentially be used
  /// as a pattern for matching. It returns `true` if the `target` is a valid pattern.
  bool get checkIfTargetIsValidToBePattern =>
      target != null && target is String && '$target'.isNotEmpty;

  /// This method is responsible for building the result based on the `Delta` object
  ///
  /// * [delta]: The `Delta` object to evaluate against.
  /// * [partsToIgnore]: An optional list of `DeltaRange` objects that represent parts to be ignored
  ///   during evaluation. Default is an empty list.
  /// * [onCatch]: An optional callback function to catch any exception that occur during the evaluation.
  T build(
    Delta delta, [
    List<DeltaRange> partsToIgnore = const [],
    void Function(Exception err)? onCatch,
  ]);

  @override
  @mustBeOverridden
  bool operator ==(covariant Condition other) {
    if (identical(other, this)) return true;
    return other.key == key &&
        other.target == target &&
        other.caseSensitive == caseSensitive;
  }

  @override
  @mustBeOverridden
  int get hashCode => target.hashCode ^ key.hashCode ^ caseSensitive.hashCode;
}
