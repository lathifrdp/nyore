class FeatureModel {
  final int? id;
  final String? name;
  final String? description;
  final bool? isActive;
  final String? pathRoute;

  FeatureModel({
    this.id,
    this.name,
    this.description,
    this.isActive,
    this.pathRoute,
  });

  factory FeatureModel.fromJson(Map<String, dynamic> json) {
    return FeatureModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool?,
      pathRoute: json['pathRoute'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isActive': isActive,
      'pathRoute': pathRoute,
    };
  }
}
