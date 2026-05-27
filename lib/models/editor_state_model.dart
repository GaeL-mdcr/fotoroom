enum EditorFilterType {
  none,
  grayscale,
  warm,
  cool,
}

extension EditorFilterTypeExtension on EditorFilterType {
  String get label {
    switch (this) {
      case EditorFilterType.none:
        return 'Normal';
      case EditorFilterType.grayscale:
        return 'Cinza';
      case EditorFilterType.warm:
        return 'Quente';
      case EditorFilterType.cool:
        return 'Frio';
    }
  }
}

class EditorStateModel {
  final double brightness;
  final double contrast;
  final double saturation;

  final EditorFilterType filterType;

  final int rotationTurns;
  final bool flipHorizontal;
  final bool flipVertical;

  const EditorStateModel({
    this.brightness = 0,
    this.contrast = 0,
    this.saturation = 0,
    this.filterType = EditorFilterType.none,
    this.rotationTurns = 0,
    this.flipHorizontal = false,
    this.flipVertical = false,
  });

  EditorStateModel copyWith({
    double? brightness,
    double? contrast,
    double? saturation,
    EditorFilterType? filterType,
    int? rotationTurns,
    bool? flipHorizontal,
    bool? flipVertical,
  }) {
    return EditorStateModel(
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      filterType: filterType ?? this.filterType,
      rotationTurns: rotationTurns ?? this.rotationTurns,
      flipHorizontal: flipHorizontal ?? this.flipHorizontal,
      flipVertical: flipVertical ?? this.flipVertical,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'brightness': brightness,
      'contrast': contrast,
      'saturation': saturation,
      'filterType': filterType.name,
      'rotationTurns': rotationTurns,
      'flipHorizontal': flipHorizontal,
      'flipVertical': flipVertical,
    };
  }

  factory EditorStateModel.fromMap(Map<String, dynamic> map) {
    return EditorStateModel(
      brightness: _toDouble(map['brightness']),
      contrast: _toDouble(map['contrast']),
      saturation: _toDouble(map['saturation']),
      filterType: _filterTypeFromMap(map),
      rotationTurns: map['rotationTurns'] as int? ?? 0,
      flipHorizontal: map['flipHorizontal'] as bool? ?? false,
      flipVertical: map['flipVertical'] as bool? ?? false,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return 0;
  }

  static EditorFilterType _filterTypeFromMap(Map<String, dynamic> map) {
    final value = map['filterType'] ?? map['filterName'];

    if (value is! String) {
      return EditorFilterType.none;
    }

    return EditorFilterType.values.firstWhere(
      (filter) => filter.name == value,
      orElse: () => EditorFilterType.none,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EditorStateModel &&
        other.brightness == brightness &&
        other.contrast == contrast &&
        other.saturation == saturation &&
        other.filterType == filterType &&
        other.rotationTurns == rotationTurns &&
        other.flipHorizontal == flipHorizontal &&
        other.flipVertical == flipVertical;
  }

  @override
  int get hashCode {
    return Object.hash(
      brightness,
      contrast,
      saturation,
      filterType,
      rotationTurns,
      flipHorizontal,
      flipVertical,
    );
  }
}
