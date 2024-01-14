import 'package:fixnum/fixnum.dart';

import '../utils/statics.dart';
import '../utils/types_def.dart';
import 'base/bson_object.dart';
import 'bson_binary.dart';

class BsonDouble extends BsonObject {
  BsonDouble(this.data);
  BsonDouble.fromInt(int data) : data = data.toDouble();
  BsonDouble.fromBuffer(BsonBinary buffer) : data = extractData(buffer);
  BsonDouble.fromEJson(Map<String, dynamic> eJsonMap)
      : data = extractEJson(eJsonMap);

  static double extractEJson(Map<String, dynamic> eJsonMap) {
    var entry = eJsonMap.entries.first;
    if (entry.key != type$double) {
      throw ArgumentError(
          'The received Map is not a avalid EJson Double representation');
    }

    if (entry.value is! String) {
      throw ArgumentError(
          'The received Map is not a valid EJson Double representation');
    }
    if (entry.value == 'NaN') {
      return double.nan;
    }
    if (entry.value == 'Infinity') {
      return double.infinity;
    }
    if (entry.value == '-Infinity') {
      return double.negativeInfinity;
    }
    return double.parse(entry.value);
  }

  double data;

  static double extractData(BsonBinary buffer) => buffer.readDouble();

  @override
  double get value => data;
  @override
  int get totalByteLength => 8;
  @override
  int get typeByte => bsonDataNumber;
  @override
  void packValue(BsonBinary buffer) {
    // This is needed because the JS Nan is `0x7ff8000000000000`
    // instead of `0xfff8000000000000'.
    // This way encodings in VM and JS will be equal.
    if (data.isNaN && Statics.isWebInt) {
      var nan = Int64(0xfff8000000000000);
      buffer.writeFixInt64(nan);
    } else {
      buffer.writeDouble(data);
    }
  }

  @override
  eJson({bool relaxed = false}) {
    if (data.isNaN) {
      return {type$double: 'NaN'};
    }
    if (data.isInfinite) {
      if (data.isNegative) {
        return {type$double: '-Infinity'};
      } else {
        return {type$double: 'Infinity'};
      }
    }
    return relaxed ? data : {type$double: '$data'};
  }
}
