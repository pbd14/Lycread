import 'package:flutter_tagging/flutter_tagging.dart';

class Tag extends Taggable {
  ///
  String name;
  int number;

  /// Creates Language
  Tag({this.name, this.number});

  @override
  List<Object> get props => [name];

  /// Converts the class to json string.
  String get() => this.name;
  int getNumber() => this.number;
}
