/// Represents a Tag from a Todo Item
class Tag {
  String _name;
  String _colorString;
  bool _active;

  Tag(this._name, this._colorString, this._active);

  Tag.fromDocument(Map<String, dynamic> tag) {
    this._name = tag['name'];
    this._colorString = tag['colorString'];
    this._active = tag['active'];
  }

  Map<String, dynamic> toDocument() =>
      {'name': name, 'colorString': colorString, 'active': active};

  String get name => _name;
  String get colorString => _colorString;
  bool get active => _active;

  set name(String value) {
    if (value.isNotEmpty) {
      _name = value;
    }
  }

  set colorString(String value) {
    if (value.isNotEmpty) {
      _colorString = value;
    }
  }

  set active(bool value) => _active = value;
}