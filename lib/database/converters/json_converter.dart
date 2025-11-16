import 'dart:convert';
import 'package:drift/drift.dart';

/// Type converter for storing Map<String, dynamic> as JSON string in database
class JsonMapConverter extends TypeConverter<Map<String, dynamic>, String> {
  const JsonMapConverter();

  @override
  Map<String, dynamic> fromSql(String fromDb) {
    return json.decode(fromDb) as Map<String, dynamic>;
  }

  @override
  String toSql(Map<String, dynamic> value) {
    return json.encode(value);
  }
}

/// Type converter for storing List<dynamic> as JSON string in database
class JsonListConverter extends TypeConverter<List<dynamic>, String> {
  const JsonListConverter();

  @override
  List<dynamic> fromSql(String fromDb) {
    return json.decode(fromDb) as List<dynamic>;
  }

  @override
  String toSql(List<dynamic> value) {
    return json.encode(value);
  }
}

/// Type converter for storing nullable Map<String, dynamic> as JSON string
class NullableJsonMapConverter extends TypeConverter<Map<String, dynamic>?, String?> {
  const NullableJsonMapConverter();

  @override
  Map<String, dynamic>? fromSql(String? fromDb) {
    if (fromDb == null) return null;
    return json.decode(fromDb) as Map<String, dynamic>;
  }

  @override
  String? toSql(Map<String, dynamic>? value) {
    if (value == null) return null;
    return json.encode(value);
  }
}
