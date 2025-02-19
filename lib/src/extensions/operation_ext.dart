import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:dart_quill_delta_simplify/src/exceptions/illegal_operation_passed_exception.dart';
import 'package:dart_quill_delta_simplify/src/extensions/string_ext.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:meta/meta.dart';

/// Extension that adds a getter to the [Operation] class to retrieve the effective length
/// of the operation. The length is only valid for insert operations and throws an exception
/// if the operation is a retain or delete.
///
/// If the operation is a retain or delete, an [IllegalOperationPassedException] is thrown.
///
/// Example usage:
/// ```dart
/// final length = myOperation.getEffectiveLength;
/// ```
extension OffsetOperationLength on Operation {
  /// Gets the effective length of the operation.
  ///
  /// - Returns the length of the operation if it is valid.
  /// - Throws [IllegalOperationPassedException] if the operation is a retain or delete.
  int get getEffectiveLength {
    if (isRetain || isDelete) {
      throw IllegalOperationPassedException(illegal: this, expected: clone(''));
    }
    return length!;
  }
}

/// Extension that calculates the total effective length of a list of [Operation]s.
/// It accumulates the length of each operation in the list to return the total length.
extension ListOperationLength on Iterable<Operation> {
  /// Gets the total effective length of the list of operations.
  int get getEffectiveLength =>
      fold(0, (value, op) => value + op.getEffectiveLength);
}

/// Extension that converts an [Operation] to its plain text representation.
extension OperationToPlain on Operation {
  static const String _kObjectReplacementCharacter = '\uFFFC';

  /// Converts the operation to its plain text representation.
  String toPlain({String Function(Object embedData)? embedBuilder}) {
    if (isRetain || isDelete || isEmpty || data == null) return '';
    return data is String
        ? '$data'
        : embedBuilder?.call(data!) ?? _kObjectReplacementCharacter;
  }

  /// Checks if the operation's data is empty.
  bool get ignoreIfEmpty {
    return data == null ||
        data is String && (data.toString().trim().isEmpty) ||
        (data is Map && (data as Map).isEmpty);
  }
}

/// Extension that provides various utility methods for [Operation]s, such as checking
/// if an operation is a block-level insertion, a new line, or contains embedded data.
extension CheckOperation on Operation {
  /// Checks if the operation represents a block-level insertion (e.g., a newline with attributes).
  bool get isBlockLevelInsertion =>
      data is String &&
      ('$data'.hasOnlyNewLines || '$data' == '\n') &&
      attributes != null;

  /// Checks if the operation represents a new line.
  bool get isNewLine =>
      data is String && ('$data'.hasOnlyNewLines || '$data' == '\n');

  /// Checks if the operation contains embedded data.
  bool get isEmbed => data is Map;

  /// Checks if the operation contains a new line.
  bool containsNewLine() => !isEmbed && (data as String).contains('\n');

  /// Checks if the operation represents a new line or a block insertion.
  bool get isNewLineOrBlockInsertion => isBlockLevelInsertion || isNewLine;

  /// Returns the opposite of [isBlockLevelInsertion].
  bool get nonIsBlockLevelInsertion => !isBlockLevelInsertion;
}

/// Extension that adds a `clone` method to the [Operation] class for cloning an operation
/// with potentially new data and attributes. The method allows for replacing the current
/// attributes with new ones, or adding/clearing attributes as necessary.
@internal
extension CloneOperation on Operation {
  /// Creates a new clone of the operation with the specified new data and optional attributes.
  ///
  /// * [newData]: The new data to replace the current data. If null, the current data is used.
  /// * [attribute]: An optional attribute to replace or add to the operation.
  /// * [replaceCurrentByNewAttr]: If true, the existing attributes are replaced by the new attribute.
  Operation clone(Object? newData,
      // we can't specify the generic type by default
      // because this Attribute can be a custom one created by the dev
      // ignore: strict_raw_type
      [Attribute? attribute,
      bool replaceCurrentByNewAttr = false,
      bool withoutAttrs = false]) {
    final Map<String, dynamic> attrs = <String, dynamic>{...?attributes};
    if (attribute != null) {
      if (attribute.value == null) {
        attrs.removeWhere((String k, dynamic v) => k == attribute.key);
      } else if (attribute.value != null) {
        if (replaceCurrentByNewAttr) attrs.clear();
        attrs[attribute.key] = attribute.value;
      }
    }
    return Operation.insert(
      newData ?? data,
      withoutAttrs
          ? null
          : attrs.isEmpty
              ? null
              : attrs,
    );
  }
}
