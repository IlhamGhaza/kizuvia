// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dose_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DoseLog {

 String get id; String get scheduleId; String get patientId;/// UTC instant of the planned dose.
 DateTime get scheduledAt; DoseStatus get status; DateTime get createdAt; DateTime? get confirmedAt; String? get note; DoseSource get source;
/// Create a copy of DoseLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoseLogCopyWith<DoseLog> get copyWith => _$DoseLogCopyWithImpl<DoseLog>(this as DoseLog, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DoseLog;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoseLog&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.scheduleId, _this.scheduleId) || other.scheduleId == _this.scheduleId)&&(identical(other.patientId, _this.patientId) || other.patientId == _this.patientId)&&(identical(other.scheduledAt, _this.scheduledAt) || other.scheduledAt == _this.scheduledAt)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.confirmedAt, _this.confirmedAt) || other.confirmedAt == _this.confirmedAt)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.source, _this.source) || other.source == _this.source));
}


@override
int get hashCode {
  final _this = this as DoseLog;
  return Object.hash(runtimeType,_this.id,_this.scheduleId,_this.patientId,_this.scheduledAt,_this.status,_this.createdAt,_this.confirmedAt,_this.note,_this.source);
}

@override
String toString() {
  final _this = this as DoseLog;
  return 'DoseLog(id: ${_this.id}, scheduleId: ${_this.scheduleId}, patientId: ${_this.patientId}, scheduledAt: ${_this.scheduledAt}, status: ${_this.status}, createdAt: ${_this.createdAt}, confirmedAt: ${_this.confirmedAt}, note: ${_this.note}, source: ${_this.source})';
}


}

/// @nodoc
abstract mixin class $DoseLogCopyWith<$Res>  {
  factory $DoseLogCopyWith(DoseLog value, $Res Function(DoseLog) _then) = _$DoseLogCopyWithImpl;
@useResult
$Res call({
 String id, String scheduleId, String patientId, DateTime scheduledAt, DoseStatus status, DateTime createdAt, DateTime? confirmedAt, String? note, DoseSource source
});




}
/// @nodoc
class _$DoseLogCopyWithImpl<$Res>
    implements $DoseLogCopyWith<$Res> {
  _$DoseLogCopyWithImpl(this._self, this._then);

  final DoseLog _self;
  final $Res Function(DoseLog) _then;

/// Create a copy of DoseLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? scheduleId = null,Object? patientId = null,Object? scheduledAt = null,Object? status = null,Object? createdAt = null,Object? confirmedAt = freezed,Object? note = freezed,Object? source = null,}) {
  return _then(DoseLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,scheduleId: null == scheduleId ? _self.scheduleId : scheduleId // ignore: cast_nullable_to_non_nullable
as String,patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DoseStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as DoseSource,
  ));
}

}


/// Adds pattern-matching-related methods to [DoseLog].
extension DoseLogPatterns on DoseLog {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DoseLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DoseLog() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DoseLog value)  $default,){
final _that = this;
switch (_that) {
case _DoseLog():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DoseLog value)?  $default,){
final _that = this;
switch (_that) {
case _DoseLog() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String scheduleId,  String patientId,  DateTime scheduledAt,  DoseStatus status,  DateTime createdAt,  DateTime? confirmedAt,  String? note,  DoseSource source)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DoseLog() when $default != null:
return $default(_that.id,_that.scheduleId,_that.patientId,_that.scheduledAt,_that.status,_that.createdAt,_that.confirmedAt,_that.note,_that.source);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String scheduleId,  String patientId,  DateTime scheduledAt,  DoseStatus status,  DateTime createdAt,  DateTime? confirmedAt,  String? note,  DoseSource source)  $default,) {final _that = this;
switch (_that) {
case _DoseLog():
return $default(_that.id,_that.scheduleId,_that.patientId,_that.scheduledAt,_that.status,_that.createdAt,_that.confirmedAt,_that.note,_that.source);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String scheduleId,  String patientId,  DateTime scheduledAt,  DoseStatus status,  DateTime createdAt,  DateTime? confirmedAt,  String? note,  DoseSource source)?  $default,) {final _that = this;
switch (_that) {
case _DoseLog() when $default != null:
return $default(_that.id,_that.scheduleId,_that.patientId,_that.scheduledAt,_that.status,_that.createdAt,_that.confirmedAt,_that.note,_that.source);case _:
  return null;

}
}

}

/// @nodoc


class _DoseLog implements DoseLog {
  const _DoseLog({required this.id, required this.scheduleId, required this.patientId, required this.scheduledAt, required this.status, required this.createdAt, this.confirmedAt, this.note, this.source = DoseSource.device});
  

@override final  String id;
@override final  String scheduleId;
@override final  String patientId;
/// UTC instant of the planned dose.
@override final  DateTime scheduledAt;
@override final  DoseStatus status;
@override final  DateTime createdAt;
@override final  DateTime? confirmedAt;
@override final  String? note;
@override@JsonKey() final  DoseSource source;

/// Create a copy of DoseLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoseLogCopyWith<_DoseLog> get copyWith => __$DoseLogCopyWithImpl<_DoseLog>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DoseLog&&(identical(other.id, id) || other.id == id)&&(identical(other.scheduleId, scheduleId) || other.scheduleId == scheduleId)&&(identical(other.patientId, patientId) || other.patientId == patientId)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.confirmedAt, confirmedAt) || other.confirmedAt == confirmedAt)&&(identical(other.note, note) || other.note == note)&&(identical(other.source, source) || other.source == source));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,scheduleId,patientId,scheduledAt,status,createdAt,confirmedAt,note,source);
}

@override
String toString() {
    return 'DoseLog(id: $id, scheduleId: $scheduleId, patientId: $patientId, scheduledAt: $scheduledAt, status: $status, createdAt: $createdAt, confirmedAt: $confirmedAt, note: $note, source: $source)';
}


}

/// @nodoc
abstract mixin class _$DoseLogCopyWith<$Res> implements $DoseLogCopyWith<$Res> {
  factory _$DoseLogCopyWith(_DoseLog value, $Res Function(_DoseLog) _then) = __$DoseLogCopyWithImpl;
@override @useResult
$Res call({
 String id, String scheduleId, String patientId, DateTime scheduledAt, DoseStatus status, DateTime createdAt, DateTime? confirmedAt, String? note, DoseSource source
});




}
/// @nodoc
class __$DoseLogCopyWithImpl<$Res>
    implements _$DoseLogCopyWith<$Res> {
  __$DoseLogCopyWithImpl(this._self, this._then);

  final _DoseLog _self;
  final $Res Function(_DoseLog) _then;

/// Create a copy of DoseLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? scheduleId = null,Object? patientId = null,Object? scheduledAt = null,Object? status = null,Object? createdAt = null,Object? confirmedAt = freezed,Object? note = freezed,Object? source = null,}) {
  return _then(_DoseLog(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,scheduleId: null == scheduleId ? _self.scheduleId : scheduleId // ignore: cast_nullable_to_non_nullable
as String,patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,scheduledAt: null == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DoseStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,confirmedAt: freezed == confirmedAt ? _self.confirmedAt : confirmedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as DoseSource,
  ));
}


}

// dart format on
