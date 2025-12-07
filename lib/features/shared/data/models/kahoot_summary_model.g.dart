// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kahoot_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KahootSummaryModel _$KahootSummaryModelFromJson(Map<String, dynamic> json) =>
    KahootSummaryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      coverImageUrl: json['coverImageUrl'] as String?,
      authorName: json['authorName'] as String,
      status: json['status'] as String,
      playCount: (json['playCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      visibility: json['visibility'] as String,
    );

Map<String, dynamic> _$KahootSummaryModelToJson(KahootSummaryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'coverImageUrl': instance.coverImageUrl,
      'authorName': instance.authorName,
      'status': instance.status,
      'playCount': instance.playCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'visibility': instance.visibility,
    };
