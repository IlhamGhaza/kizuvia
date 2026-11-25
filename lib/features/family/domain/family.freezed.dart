// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'family.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FamilySummary {

 String get id; String get name; String get role; int get memberCount;
/// Create a copy of FamilySummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilySummaryCopyWith<FamilySummary> get copyWith => _$FamilySummaryCopyWithImpl<FamilySummary>(this as FamilySummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FamilySummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilySummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.memberCount, _this.memberCount) || other.memberCount == _this.memberCount));
}


@override
int get hashCode {
  final _this = this as FamilySummary;
  return Object.hash(runtimeType,_this.id,_this.name,_this.role,_this.memberCount);
}

@override
String toString() {
  final _this = this as FamilySummary;
  return 'FamilySummary(id: ${_this.id}, name: ${_this.name}, role: ${_this.role}, memberCount: ${_this.memberCount})';
}


}

/// @nodoc
abstract mixin class $FamilySummaryCopyWith<$Res>  {
  factory $FamilySummaryCopyWith(FamilySummary value, $Res Function(FamilySummary) _then) = _$FamilySummaryCopyWithImpl;
@useResult
$Res call({
 String id, String name, String role, int memberCount
});




}
/// @nodoc
class _$FamilySummaryCopyWithImpl<$Res>
    implements $FamilySummaryCopyWith<$Res> {
  _$FamilySummaryCopyWithImpl(this._self, this._then);

  final FamilySummary _self;
  final $Res Function(FamilySummary) _then;

/// Create a copy of FamilySummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? role = null,Object? memberCount = null,}) {
  return _then(FamilySummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [FamilySummary].
extension FamilySummaryPatterns on FamilySummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilySummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilySummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilySummary value)  $default,){
final _that = this;
switch (_that) {
case _FamilySummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilySummary value)?  $default,){
final _that = this;
switch (_that) {
case _FamilySummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String role,  int memberCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilySummary() when $default != null:
return $default(_that.id,_that.name,_that.role,_that.memberCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String role,  int memberCount)  $default,) {final _that = this;
switch (_that) {
case _FamilySummary():
return $default(_that.id,_that.name,_that.role,_that.memberCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String role,  int memberCount)?  $default,) {final _that = this;
switch (_that) {
case _FamilySummary() when $default != null:
return $default(_that.id,_that.name,_that.role,_that.memberCount);case _:
  return null;

}
}

}

/// @nodoc


class _FamilySummary implements FamilySummary {
  const _FamilySummary({required this.id, required this.name, required this.role, this.memberCount = 1});
  

@override final  String id;
@override final  String name;
@override final  String role;
@override@JsonKey() final  int memberCount;

/// Create a copy of FamilySummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilySummaryCopyWith<_FamilySummary> get copyWith => __$FamilySummaryCopyWithImpl<_FamilySummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilySummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.role, role) || other.role == role)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,role,memberCount);
}

@override
String toString() {
    return 'FamilySummary(id: $id, name: $name, role: $role, memberCount: $memberCount)';
}


}

/// @nodoc
abstract mixin class _$FamilySummaryCopyWith<$Res> implements $FamilySummaryCopyWith<$Res> {
  factory _$FamilySummaryCopyWith(_FamilySummary value, $Res Function(_FamilySummary) _then) = __$FamilySummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String role, int memberCount
});




}
/// @nodoc
class __$FamilySummaryCopyWithImpl<$Res>
    implements _$FamilySummaryCopyWith<$Res> {
  __$FamilySummaryCopyWithImpl(this._self, this._then);

  final _FamilySummary _self;
  final $Res Function(_FamilySummary) _then;

/// Create a copy of FamilySummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? role = null,Object? memberCount = null,}) {
  return _then(_FamilySummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$FamilyMember {

 String get userId; String get role; String? get displayName; bool get notifyMissed;
/// Create a copy of FamilyMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FamilyMemberCopyWith<FamilyMember> get copyWith => _$FamilyMemberCopyWithImpl<FamilyMember>(this as FamilyMember, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FamilyMember;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyMember&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.notifyMissed, _this.notifyMissed) || other.notifyMissed == _this.notifyMissed));
}


@override
int get hashCode {
  final _this = this as FamilyMember;
  return Object.hash(runtimeType,_this.userId,_this.role,_this.displayName,_this.notifyMissed);
}

@override
String toString() {
  final _this = this as FamilyMember;
  return 'FamilyMember(userId: ${_this.userId}, role: ${_this.role}, displayName: ${_this.displayName}, notifyMissed: ${_this.notifyMissed})';
}


}

/// @nodoc
abstract mixin class $FamilyMemberCopyWith<$Res>  {
  factory $FamilyMemberCopyWith(FamilyMember value, $Res Function(FamilyMember) _then) = _$FamilyMemberCopyWithImpl;
@useResult
$Res call({
 String userId, String role, String? displayName, bool notifyMissed
});




}
/// @nodoc
class _$FamilyMemberCopyWithImpl<$Res>
    implements $FamilyMemberCopyWith<$Res> {
  _$FamilyMemberCopyWithImpl(this._self, this._then);

  final FamilyMember _self;
  final $Res Function(FamilyMember) _then;

/// Create a copy of FamilyMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? role = null,Object? displayName = freezed,Object? notifyMissed = null,}) {
  return _then(FamilyMember(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,notifyMissed: null == notifyMissed ? _self.notifyMissed : notifyMissed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [FamilyMember].
extension FamilyMemberPatterns on FamilyMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FamilyMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FamilyMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FamilyMember value)  $default,){
final _that = this;
switch (_that) {
case _FamilyMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FamilyMember value)?  $default,){
final _that = this;
switch (_that) {
case _FamilyMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String role,  String? displayName,  bool notifyMissed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FamilyMember() when $default != null:
return $default(_that.userId,_that.role,_that.displayName,_that.notifyMissed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String role,  String? displayName,  bool notifyMissed)  $default,) {final _that = this;
switch (_that) {
case _FamilyMember():
return $default(_that.userId,_that.role,_that.displayName,_that.notifyMissed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String role,  String? displayName,  bool notifyMissed)?  $default,) {final _that = this;
switch (_that) {
case _FamilyMember() when $default != null:
return $default(_that.userId,_that.role,_that.displayName,_that.notifyMissed);case _:
  return null;

}
}

}

/// @nodoc


class _FamilyMember implements FamilyMember {
  const _FamilyMember({required this.userId, required this.role, this.displayName, this.notifyMissed = true});
  

@override final  String userId;
@override final  String role;
@override final  String? displayName;
@override@JsonKey() final  bool notifyMissed;

/// Create a copy of FamilyMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FamilyMemberCopyWith<_FamilyMember> get copyWith => __$FamilyMemberCopyWithImpl<_FamilyMember>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FamilyMember&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.role, role) || other.role == role)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.notifyMissed, notifyMissed) || other.notifyMissed == notifyMissed));
}


@override
int get hashCode {
    return Object.hash(runtimeType,userId,role,displayName,notifyMissed);
}

@override
String toString() {
    return 'FamilyMember(userId: $userId, role: $role, displayName: $displayName, notifyMissed: $notifyMissed)';
}


}

/// @nodoc
abstract mixin class _$FamilyMemberCopyWith<$Res> implements $FamilyMemberCopyWith<$Res> {
  factory _$FamilyMemberCopyWith(_FamilyMember value, $Res Function(_FamilyMember) _then) = __$FamilyMemberCopyWithImpl;
@override @useResult
$Res call({
 String userId, String role, String? displayName, bool notifyMissed
});




}
/// @nodoc
class __$FamilyMemberCopyWithImpl<$Res>
    implements _$FamilyMemberCopyWith<$Res> {
  __$FamilyMemberCopyWithImpl(this._self, this._then);

  final _FamilyMember _self;
  final $Res Function(_FamilyMember) _then;

/// Create a copy of FamilyMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? role = null,Object? displayName = freezed,Object? notifyMissed = null,}) {
  return _then(_FamilyMember(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,notifyMissed: null == notifyMissed ? _self.notifyMissed : notifyMissed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
