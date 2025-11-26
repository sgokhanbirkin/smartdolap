/// TONL (Token-Optimized Notation Language) encoder/decoder
/// Reduces token costs by 32-50% compared to JSON
/// See: https://tonl.dev/
class TONLEncoder {
  TONLEncoder._();

  /// Encode a Map or List to TONL format
  static String encode(Object data, {bool includeTypes = false}) {
    if (data is Map<String, dynamic>) {
      return _encodeMap(data, includeTypes: includeTypes);
    } else if (data is List<dynamic>) {
      return _encodeList(data, includeTypes: includeTypes);
    }
    throw ArgumentError('TONL encoding only supports Map and List');
  }

  /// Decode TONL format to Map or List
  static dynamic decode(String tonl) {
    final List<String> lines = tonl
        .split('\n')
        .where(
          (String line) =>
              line.trim().isNotEmpty && !line.trim().startsWith('#'),
        )
        .toList();

    if (lines.isEmpty) {
      return <String, dynamic>{};
    }

    // Check if it's an array format (starts with key[count]{fields}:)
    final RegExp arrayHeaderRegex = RegExp(r'^(\w+)\[(\d+)\]\{([^}]+)\}:');
    final RegExp objectHeaderRegex = RegExp(r'^(\w+)\{([^}]+)\}:');

    final String firstLine = lines.first.trim();
    final Match? arrayMatch = arrayHeaderRegex.firstMatch(firstLine);
    final Match? objectMatch = objectHeaderRegex.firstMatch(firstLine);

    if (arrayMatch != null) {
      return _decodeArray(lines);
    } else if (objectMatch != null) {
      return _decodeObject(lines);
    } else {
      // Try to parse as simple object
      return _decodeSimpleObject(lines);
    }
  }

  static String _encodeMap(
    Map<String, dynamic> map, {
    bool includeTypes = false,
  }) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('#version 1.0');

    for (final MapEntry<String, dynamic> entry in map.entries) {
      if (entry.value is List) {
        buffer.writeln(
          _encodeArray(
            entry.key,
            entry.value as List<dynamic>,
            includeTypes: includeTypes,
          ),
        );
      } else if (entry.value is Map) {
        buffer.writeln(
          _encodeNestedObject(
            entry.key,
            entry.value as Map<String, dynamic>,
            includeTypes: includeTypes,
          ),
        );
      } else {
        buffer.writeln('${entry.key}: ${_encodeValue(entry.value)}');
      }
    }

    return buffer.toString().trim();
  }

  static String _encodeList(List<dynamic> list, {bool includeTypes = false}) {
    if (list.isEmpty) {
      return '#version 1.0\nitems[0]{}:';
    }

    // Check if all items are maps with same keys
    if (list.first is Map<String, dynamic>) {
      final Map<String, dynamic> firstItem = list.first as Map<String, dynamic>;
      final List<String> keys = firstItem.keys.toList();
      final StringBuffer buffer = StringBuffer();
      buffer.writeln('#version 1.0');
      buffer.writeln('items[${list.length}]{${keys.join(',')}}:');

      for (final dynamic item in list) {
        if (item is Map<String, dynamic>) {
          final List<String> values = keys
              .map((String key) => _encodeValue(item[key]))
              .toList();
          buffer.writeln('  ${values.join(', ')}');
        }
      }

      return buffer.toString().trim();
    }

    // Simple list
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('#version 1.0');
    buffer.writeln('items[${list.length}]:');
    for (final dynamic item in list) {
      buffer.writeln('  ${_encodeValue(item)}');
    }
    return buffer.toString().trim();
  }

  static String _encodeArray(
    String key,
    List<dynamic> list, {
    bool includeTypes = false,
  }) {
    if (list.isEmpty) {
      return '$key[0]{}:';
    }

    if (list.first is Map<String, dynamic>) {
      final Map<String, dynamic> firstItem = list.first as Map<String, dynamic>;
      final List<String> fields = firstItem.keys.toList();
      final StringBuffer buffer = StringBuffer();
      buffer.writeln('$key[${list.length}]{${fields.join(',')}}:');

      for (final dynamic item in list) {
        if (item is Map<String, dynamic>) {
          final List<String> values = fields
              .map((String field) => _encodeValue(item[field]))
              .toList();
          buffer.writeln('  ${values.join(', ')}');
        }
      }

      return buffer.toString();
    }

    // Simple array
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('$key[${list.length}]:');
    for (final dynamic item in list) {
      buffer.writeln('  ${_encodeValue(item)}');
    }
    return buffer.toString();
  }

  static String _encodeNestedObject(
    String key,
    Map<String, dynamic> map, {
    bool includeTypes = false,
  }) {
    final List<String> fields = map.keys.toList();
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('$key{${fields.join(',')}}:');
    final List<String> values = fields
        .map((String field) => _encodeValue(map[field]))
        .toList();
    buffer.writeln('  ${values.join(', ')}');
    return buffer.toString();
  }

  static String _encodeValue(Object? value) {
    if (value == null) {
      return 'null';
    } else if (value is String) {
      // Escape commas and newlines in strings
      if (value.contains(',') || value.contains('\n')) {
        return '"$value"';
      }
      return value;
    } else if (value is num) {
      return value.toString();
    } else if (value is bool) {
      return value.toString();
    } else if (value is List) {
      return '[${value.map(_encodeValue).join(',')}]';
    } else if (value is Map) {
      return '{${value.entries.map((MapEntry<Object?, Object?> e) => '${_encodeValue(e.key)}:${_encodeValue(e.value)}').join(',')}}';
    } else {
      return value.toString();
    }
  }

  static Map<String, dynamic> _decodeArray(List<String> lines) {
    final Map<String, dynamic> result = <String, dynamic>{};
    String? currentKey;
    List<Map<String, dynamic>>? currentArray;
    List<String>? currentFields;

    for (final String line in lines) {
      final String trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) {
        continue;
      }

      // Check for array header: key[count]{fields}:
      final RegExp arrayHeaderRegex = RegExp(r'^(\w+)\[(\d+)\]\{([^}]+)\}:');
      final Match? headerMatch = arrayHeaderRegex.firstMatch(trimmed);

      if (headerMatch != null) {
        // Save previous array if exists
        if (currentKey != null && currentArray != null) {
          result[currentKey] = currentArray;
        }

        currentKey = headerMatch.group(1);
        // count is parsed but not used - that's OK, we'll use actual row count
        final String fieldsStr = headerMatch.group(3)!;
        currentFields = fieldsStr
            .split(',')
            .map((String s) => s.trim())
            .toList();
        currentArray = <Map<String, dynamic>>[];
      } else if (currentFields != null &&
          currentArray != null &&
          trimmed.isNotEmpty) {
        // Parse data row (remove leading spaces if present)
        final String cleanRow = trimmed.startsWith('  ')
            ? trimmed.substring(2)
            : trimmed;
        final List<String> values = _parseRow(cleanRow);

        if (values.length == currentFields.length) {
          final Map<String, dynamic> item = <String, dynamic>{};
          for (int i = 0; i < currentFields.length; i++) {
            item[currentFields[i]] = _parseValue(values[i]);
          }
          currentArray.add(item);
        } else if (values.length > currentFields.length) {
          // Try to handle extra commas in values (e.g., in step descriptions)
          final Map<String, dynamic> item = <String, dynamic>{};
          int valueIndex = 0;
          for (int i = 0; i < currentFields.length; i++) {
            if (valueIndex < values.length) {
              item[currentFields[i]] = _parseValue(values[valueIndex]);
              valueIndex++;
            }
          }
          if (item.isNotEmpty) {
            currentArray.add(item);
          }
        }
      }
    }

    // Save last array
    if (currentKey != null && currentArray != null) {
      result[currentKey] = currentArray;
    }

    return result;
  }

  static Map<String, dynamic> _decodeObject(List<String> lines) {
    final Map<String, dynamic> result = <String, dynamic>{};
    String? currentKey;
    List<String>? currentFields;

    for (final String line in lines) {
      final String trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) {
        continue;
      }

      final RegExp objectHeaderRegex = RegExp(r'^(\w+)\{([^}]+)\}:');
      final Match? headerMatch = objectHeaderRegex.firstMatch(trimmed);

      if (headerMatch != null) {
        currentKey = headerMatch.group(1);
        final String fieldsStr = headerMatch.group(2)!;
        currentFields = fieldsStr
            .split(',')
            .map((String s) => s.trim())
            .toList();
      } else if (currentKey != null &&
          currentFields != null &&
          trimmed.isNotEmpty) {
        final List<String> values = _parseRow(trimmed);
        if (values.length == currentFields.length) {
          final Map<String, dynamic> item = <String, dynamic>{};
          for (int i = 0; i < currentFields.length; i++) {
            item[currentFields[i]] = _parseValue(values[i]);
          }
          result[currentKey] = item;
        }
      }
    }

    return result;
  }

  static Map<String, dynamic> _decodeSimpleObject(List<String> lines) {
    final Map<String, dynamic> result = <String, dynamic>{};
    for (final String line in lines) {
      final String trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) {
        continue;
      }
      final int colonIndex = trimmed.indexOf(':');
      if (colonIndex > 0) {
        final String key = trimmed.substring(0, colonIndex).trim();
        final String value = trimmed.substring(colonIndex + 1).trim();
        result[key] = _parseValue(value);
      }
    }
    return result;
  }

  static List<String> _parseRow(String row) {
    final List<String> result = <String>[];
    final StringBuffer current = StringBuffer();
    bool inQuotes = false;
    bool inBrackets = false;
    int bracketDepth = 0;

    for (int i = 0; i < row.length; i++) {
      final String char = row[i];
      if (char == '"') {
        inQuotes = !inQuotes;
        current.write(char);
      } else if (char == '[') {
        inBrackets = true;
        bracketDepth++;
        current.write(char);
      } else if (char == ']') {
        bracketDepth--;
        if (bracketDepth == 0) {
          inBrackets = false;
        }
        current.write(char);
      } else if (char == ',' && !inQuotes && !inBrackets) {
        result.add(current.toString().trim());
        current.clear();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString().trim());

    return result;
  }

  static dynamic _parseValue(String value) {
    final String trimmed = value.trim();
    if (trimmed == 'null') {
      return null;
    } else if (trimmed == 'true') {
      return true;
    } else if (trimmed == 'false') {
      return false;
    } else if (trimmed.startsWith('"') && trimmed.endsWith('"')) {
      return trimmed.substring(1, trimmed.length - 1);
    } else if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
      // Parse array format: [item1,item2,item3]
      final String arrayContent = trimmed
          .substring(1, trimmed.length - 1)
          .trim();
      if (arrayContent.isEmpty) {
        return <String>[];
      }
      return arrayContent
          .split(',')
          .map((String e) => e.trim())
          .where((String e) => e.isNotEmpty)
          .toList();
    } else if (RegExp(r'^-?\d+$').hasMatch(trimmed)) {
      return int.parse(trimmed);
    } else if (RegExp(r'^-?\d+\.\d+$').hasMatch(trimmed)) {
      return double.parse(trimmed);
    } else {
      return trimmed;
    }
  }
}
