// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'med_schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MedSchedule {

 String get id; String get medicationId;/// Local times, `HH:mm`.
 List<String> get times; List<int> get daysOfWeek; String get timezone; int get graceMinutes;
/// Create a copy of MedSchedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedScheduleCopyWith<MedSchedule> get copyWith => _$MedScheduleCopyWithImpl<MedSchedule>(this as MedSchedule, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MedSchedule;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedSchedule&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.medicationId, _this.medicationId) || other.medicationId == _this.medicationId)&&const DeepCollectionEquality().equals(other.times, _this.times)&&const DeepCollectionEquality().equals(other.daysOfWeek, _this.daysOfWeek)&&(identical(other.timezone, _this.timezone) || other.timezone == _this.timezone)&&(identical(other.graceMinutes, _this.graceMinutes) || other.graceMinutes == _this.graceMinutes));
}


@override
int get hashCode {
  final _this = this as MedSchedule;
  return Object.hash(runtimeType,_this.id,_this.medicationId,const DeepCollectionEquality().hash(_this.times),const DeepCollectionEquality().hash(_this.daysOfWeek),_this.timezone,_this.graceMinutes);
}

@override
String toString() {
  final _this = this as MedSchedule;
  return 'MedSchedule(id: ${_this.id}, medicationId: ${_this.medicationId}, times: ${_this.times}, daysOfWeek: ${_this.daysOfWeek}, timezone: ${_this.timezone}, graceMinutes: ${_this.graceMinutes})';
}


}

/// @nodoc
abstract mixin class $MedScheduleCopyWith<$Res>  {
  factory $MedScheduleCopyWith(MedSchedule value, $Res Function(MedSchedule) _then) = _$MedScheduleCopyWithImpl;
@useResult
$Res call({
 String id, String medicationId, List<String> times, List<int> daysOfWeek, String timezone, int graceMinutes
});




}
/// @nodoc
class _$MedScheduleCopyWithImpl<$Res>
    implements $MedScheduleCopyWith<$Res> {
  _$MedScheduleCopyWithImpl(this._self, this._then);

  final MedSchedule _self;
  final $Res Function(MedSchedule) _then;

/// Create a copy of MedSchedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? medicationId = null,Object? times = null,Object? daysOfWeek = null,Object? timezone = null,Object? graceMinutes = null,}) {
  return _then(MedSchedule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,medicationId: null == medicationId ? _self.medicationId : medicationId // ignore: cast_nullable_to_non_nullable
as String,times: null == times ? _self.times : times // ignore: cast_nullable_to_non_nullable
as List<String>,daysOfWeek: null == daysOfWeek ? _self.daysOfWeek : daysOfWeek // ignore: cast_nullable_to_non_nullable
as List<int>,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,graceMinutes: null == graceMinutes ? _self.graceMinutes : graceMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MedSchedule].
extension MedSchedulePatterns on MedSchedule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedSchedule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedSchedule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedSchedule value)  $default,){
final _that = this;
switch (_that) {
case _MedSchedule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedSchedule value)?  $default,){
final _that = this;
switch (_that) {
case _MedSchedule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String medicationId,  List<String> times,  List<int> daysOfWeek,  String timezone,  int graceMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedSchedule() when $default != null:
return $default(_that.id,_that.medicationId,_that.times,_that.daysOfWeek,_that.timezone,_that.graceMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String medicationId,  List<String> times,  List<int> daysOfWeek,  String timezone,  int graceMinutes)  $default,) {final _that = this;
switch (_that) {
case _MedSchedule():
return $default(_that.id,_that.medicationId,_that.times,_that.daysOfWeek,_that.timezone,_that.graceMinutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String medicationId,  List<String> times,  List<int> daysOfWeek,  String timezone,  int graceMinutes)?  $default,) {final _that = this;
switch (_that) {
case _MedSchedule() when $default != null:
return $default(_that.id,_that.medicationId,_that.times,_that.daysOfWeek,_that.timezone,_that.graceMinutes);case _:
  return null;

}
}

}

/// @nodoc


class _MedSchedule implements MedSchedule {
  const _MedSchedule({required this.id, required this.medicationId, required  List<String> times,  List<int> daysOfWeek = const <int>[1, 2, 3, 4, 5, 6, 7], this.timezone = 'Asia/Jakarta', this.graceMinutes = 30}): _times = times,_daysOfWeek = daysOfWeek;
  

@override final  String id;
@override final  String medicationId;
/// Local times, `HH:mm`.
 final  List<String> _times;
/// Local times, `HH:mm`.
@override List<String> get times {
  if (_times is EqualUnmodifiableListView) return _times;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_times);
}

 final  List<int> _daysOfWeek;
@override@JsonKey() List<int> get daysOfWeek {
  if (_daysOfWeek is EqualUnmodifiableListView) return _daysOfWeek;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_daysOfWeek);
}

@override@JsonKey() final  String timezone;
@override@JsonKey() final  int graceMinutes;

/// Create a copy of MedSchedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedScheduleCopyWith<_MedSchedule> get copyWith => __$MedScheduleCopyWithImpl<_MedSchedule>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedSchedule&&(identical(other.id, id) || other.id == id)&&(identical(other.medicationId, medicationId) || other.medicationId == medicationId)&&const DeepCollectionEquality().equals(other.times, _times)&&const DeepCollectionEquality().equals(other.daysOfWeek, _daysOfWeek)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.graceMinutes, graceMinutes) || other.graceMinutes == graceMinutes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,medicationId,const DeepCollectionEquality().hash(_times),const DeepCollectionEquality().hash(_daysOfWeek),timezone,graceMinutes);
}

@override
String toString() {
    return 'MedSchedule(id: $id, medicationId: $medicationId, times: $times, daysOfWeek: $daysOfWeek, timezone: $timezone, graceMinutes: $graceMinutes)';
}


}

/// @nodoc
abstract mixin class _$MedScheduleCopyWith<$Res> implements $MedScheduleCopyWith<$Res> {
  factory _$MedScheduleCopyWith(_MedSchedule value, $Res Function(_MedSchedule) _then) = __$MedScheduleCopyWithImpl;
@override @useResult
$Res call({
 String id, String medicationId, List<String> times, List<int> daysOfWeek, String timezone, int graceMinutes
});




}
/// @nodoc
class __$MedScheduleCopyWithImpl<$Res>
    implements _$MedScheduleCopyWith<$Res> {
  __$MedScheduleCopyWithImpl(this._self, this._then);

  final _MedSchedule _self;
  final $Res Function(_MedSchedule) _then;

/// Create a copy of MedSchedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? medicationId = null,Object? times = null,Object? daysOfWeek = null,Object? timezone = null,Object? graceMinutes = null,}) {
  return _then(_MedSchedule(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,medicationId: null == medicationId ? _self.medicationId : medicationId // ignore: cast_nullable_to_non_nullable
as String,times: null == times ? _self._times : times // ignore: cast_nullable_to_non_nullable
as List<String>,daysOfWeek: null == daysOfWeek ? _self._daysOfWeek : daysOfWeek // ignore: cast_nullable_to_non_nullable
as List<int>,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as String,graceMinutes: null == graceMinutes ? _self.graceMinutes : graceMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
