// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExampleModel _$ExampleModelFromJson(Map<String, dynamic> json) => ExampleModel(
      id: json['_id'] == null
          ? ""
          : const IDConverter().fromJson(json['_id'] as ObjectId?),
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
    );

Map<String, dynamic> _$ExampleModelToJson(ExampleModel instance) =>
    <String, dynamic>{
      '_id': const IDConverter().toJson(instance.id),
      'title': instance.title,
      'slug': instance.slug,
    };
