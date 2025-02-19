/// A class that represents a part of the difference between two Deltas.
///
/// Example usage:
/// ```dart
/// final diffPart = DeltaDiffPart(
///   before: 'old text',
///   after: 'new text',
///   start: 0,
///   end: 10,
/// );
/// ```
class DeltaDiffPart {
  /// The text before the change.
  final Object? before;

  /// The text after the change, or `null` if no change was made.
  final Object? after;

  /// The starting position of the change in the Delta.
  final int start;

  /// The ending position of the change in the Delta.
  final int end;

  /// Additional arguments that describe the type of change. The allowed keys are:
  /// * [isRemovedPart]: `true` if this part was removed.
  /// * [isUpdatedPart]: `true` if this part was updated.
  /// * [isAddedPart]: `true` if this part was added.
  /// * [isEquals]: `true` if this part was exactly equals than the before.
  @Deprecated('args will not be longer used, and it will be removed on 10.8.5')
  final Map<String, dynamic>? args;

  /// The type of the diff, it can be "equals", "delete", "insert", "format"
  final String type;
  final Map<String, dynamic>? attributes;

  DeltaDiffPart({
    required this.before,
    required this.after,
    required this.start,
    required this.end,
    required this.type,
    this.attributes,
    this.args,
  });

  factory DeltaDiffPart.format(
      Object? content, int start, int end, Map<String, dynamic> attributes) {
    return DeltaDiffPart(
      before: content,
      after: content,
      start: start,
      end: end,
      type: 'format',
      attributes: attributes,
    );
  }

  factory DeltaDiffPart.equals(Object? content, int start, int end) {
    return DeltaDiffPart(
      before: content,
      after: content,
      start: start,
      end: end,
      type: 'equals',
    );
  }

  factory DeltaDiffPart.delete(Object? part, int start, int end) {
    return DeltaDiffPart(
      before: part,
      after: null,
      start: start,
      end: end,
      type: 'delete',
    );
  }

  factory DeltaDiffPart.insert(
      Object? before, Object? insert, int start, int end,
      [Map<String, dynamic>? attributes]) {
    return DeltaDiffPart(
      before: before,
      after: insert,
      start: start,
      end: end,
      type: 'insert',
      attributes: attributes,
    );
  }

  @override
  bool operator ==(covariant DeltaDiffPart other) {
    if (identical(this, other)) return true;
    return before == other.before &&
        after == other.after &&
        start == other.start &&
        end == other.end;
  }

  @override
  int get hashCode =>
      before.hashCode ^ after.hashCode ^ start.hashCode ^ end.hashCode;

  @override
  String toString() {
    return 'DeltaDiffPart(before: "${before == null ? "" : before.toString().replaceAll('\n', '\\n')}", '
        'after: "${after == null ? "" : after.toString().replaceAll('\n', '\\n')}", '
        'start: $start, end: $end, '
        'type: $type'
        '${attributes != null ? ', attributes: $attributes)' : ')'}';
  }
}
