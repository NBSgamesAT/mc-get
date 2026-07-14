// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

McGetJson _$McGetJsonFromJson(Map<String, dynamic> json) => McGetJson(
  json['minecraftVersion'] as String,
  json['loader'] as String,
  installFolderOverride: json['installFolderOverride'] as String?,
)..mods = (json['mods'] as List<dynamic>).map((e) => e as String).toList();

Map<String, dynamic> _$McGetJsonToJson(McGetJson instance) => <String, dynamic>{
  'minecraftVersion': instance.minecraftVersion,
  'loader': instance.loader,
  'installFolderOverride': instance.installFolderOverride,
  'mods': instance.mods,
};

McGetLock _$McGetLockFromJson(Map<String, dynamic> json) => McGetLock(
  json['minecraftVersion'] as String,
  json['loader'] as String,
  json['installFolder'] as String,
  mods:
      (json['mods'] as List<dynamic>?)
          ?.map((e) => LockedModData.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$McGetLockToJson(McGetLock instance) => <String, dynamic>{
  'minecraftVersion': instance.minecraftVersion,
  'loader': instance.loader,
  'installFolder': instance.installFolder,
  'mods': instance.mods.map((e) => e.toJson()).toList(),
};

LockedModData _$LockedModDataFromJson(Map<String, dynamic> json) =>
    LockedModData(
      json['modId'] as String,
      json['versionId'] as String,
      json['versionNumber'] as String,
      json['fileName'] as String,
      Hash.fromJson(json['hashes'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LockedModDataToJson(LockedModData instance) =>
    <String, dynamic>{
      'modId': instance.modId,
      'versionId': instance.versionId,
      'versionNumber': instance.versionNumber,
      'fileName': instance.fileName,
      'hashes': instance.hashes.toJson(),
    };
