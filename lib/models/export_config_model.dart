enum ExportImageFormat {
  png,
  jpg,
}

class ExportConfigModel {
  final ExportImageFormat format;
  final int quality;

  const ExportConfigModel({
    this.format = ExportImageFormat.jpg,
    this.quality = 90,
  });

  ExportConfigModel copyWith({
    ExportImageFormat? format,
    int? quality,
  }) {
    return ExportConfigModel(
      format: format ?? this.format,
      quality: quality ?? this.quality,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'format': format.name,
      'quality': quality,
    };
  }

  factory ExportConfigModel.fromMap(Map<String, dynamic> map) {
    return ExportConfigModel(
      format: ExportImageFormat.values.firstWhere(
        (item) => item.name == map['format'],
        orElse: () => ExportImageFormat.jpg,
      ),
      quality: map['quality'] as int? ?? 90,
    );
  }
}
