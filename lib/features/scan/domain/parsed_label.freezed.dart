// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parsed_label.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ParsedLabel {

 String get rawText;/// Per field, 0..1. Includes fields that were dropped for low confidence.
 Map<String, double> get confidence; String? get name; String? get strength; int? get timesPerDay; double? get doseQty; MedForm? get form; MealRelation? get mealRelation; bool? get isPrn;
/// Create a copy of ParsedLabel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParsedLabelCopyWith<ParsedLabel> get copyWith => _$ParsedLabelCopyWithImpl<ParsedLabel>(this as ParsedLabel, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ParsedLabel;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParsedLabel&&(identical(other.rawText, _this.rawText) || other.rawText == _this.rawText)&&const DeepCollectionEquality().equals(other.confidence, _this.confidence)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.strength, _this.strength) || other.strength == _this.strength)&&(identical(other.timesPerDay, _this.timesPerDay) || other.timesPerDay == _this.timesPerDay)&&(identical(other.doseQty, _this.doseQty) || other.doseQty == _this.doseQty)&&(identical(other.form, _this.form) || other.form == _this.form)&&(identical(other.mealRelation, _this.mealRelation) || other.mealRelation == _this.mealRelation)&&(identical(other.isPrn, _this.isPrn) || other.isPrn == _this.isPrn));
}


@override
int get hashCode {
  final _this = this as ParsedLabel;
  return Object.hash(runtimeType,_this.rawText,const DeepCollectionEquality().hash(_this.confidence),_this.name,_this.strength,_this.timesPerDay,_this.doseQty,_this.form,_this.mealRelation,_this.isPrn);
}

@override
String toString() {
  final _this = this as ParsedLabel;
  return 'ParsedLabel(rawText: ${_this.rawText}, confidence: ${_this.confidence}, name: ${_this.name}, strength: ${_this.strength}, timesPerDay: ${_this.timesPerDay}, doseQty: ${_this.doseQty}, form: ${_this.form}, mealRelation: ${_this.mealRelation}, isPrn: ${_this.isPrn})';
}


}

/// @nodoc
abstract mixin class $ParsedLabelCopyWith<$Res>  {
  factory $ParsedLabelCopyWith(ParsedLabel value, $Res Function(ParsedLabel) _then) = _$ParsedLabelCopyWithImpl;
@useResult
$Res call({
 String rawText, Map<String, double> confidence, String? name, String? strength, int? timesPerDay, double? doseQty, MedForm? form, MealRelation? mealRelation, bool? isPrn
});




}
/// @nodoc
class _$ParsedLabelCopyWithImpl<$Res>
    implements $ParsedLabelCopyWith<$Res> {
  _$ParsedLabelCopyWithImpl(this._self, this._then);

  final ParsedLabel _self;
  final $Res Function(ParsedLabel) _then;

/// Create a copy of ParsedLabel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rawText = null,Object? confidence = null,Object? name = freezed,Object? strength = freezed,Object? timesPerDay = freezed,Object? doseQty = freezed,Object? form = freezed,Object? mealRelation = freezed,Object? isPrn = freezed,}) {
  return _then(ParsedLabel(
rawText: null == rawText ? _self.rawText : rawText // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as Map<String, double>,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,strength: freezed == strength ? _self.strength : strength // ignore: cast_nullable_to_non_nullable
as String?,timesPerDay: freezed == timesPerDay ? _self.timesPerDay : timesPerDay // ignore: cast_nullable_to_non_nullable
as int?,doseQty: freezed == doseQty ? _self.doseQty : doseQty // ignore: cast_nullable_to_non_nullable
as double?,form: freezed == form ? _self.form : form // ignore: cast_nullable_to_non_nullable
as MedForm?,mealRelation: freezed == mealRelation ? _self.mealRelation : mealRelation // ignore: cast_nullable_to_non_nullable
as MealRelation?,isPrn: freezed == isPrn ? _self.isPrn : isPrn // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [ParsedLabel].
extension ParsedLabelPatterns on ParsedLabel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParsedLabel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParsedLabel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParsedLabel value)  $default,){
final _that = this;
switch (_that) {
case _ParsedLabel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParsedLabel value)?  $default,){
final _that = this;
switch (_that) {
case _ParsedLabel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String rawText,  Map<String, double> confidence,  String? name,  String? strength,  int? timesPerDay,  double? doseQty,  MedForm? form,  MealRelation? mealRelation,  bool? isPrn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParsedLabel() when $default != null:
return $default(_that.rawText,_that.confidence,_that.name,_that.strength,_that.timesPerDay,_that.doseQty,_that.form,_that.mealRelation,_that.isPrn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String rawText,  Map<String, double> confidence,  String? name,  String? strength,  int? timesPerDay,  double? doseQty,  MedForm? form,  MealRelation? mealRelation,  bool? isPrn)  $default,) {final _that = this;
switch (_that) {
case _ParsedLabel():
return $default(_that.rawText,_that.confidence,_that.name,_that.strength,_that.timesPerDay,_that.doseQty,_that.form,_that.mealRelation,_that.isPrn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String rawText,  Map<String, double> confidence,  String? name,  String? strength,  int? timesPerDay,  double? doseQty,  MedForm? form,  MealRelation? mealRelation,  bool? isPrn)?  $default,) {final _that = this;
switch (_that) {
case _ParsedLabel() when $default != null:
return $default(_that.rawText,_that.confidence,_that.name,_that.strength,_that.timesPerDay,_that.doseQty,_that.form,_that.mealRelation,_that.isPrn);case _:
  return null;

}
}

}

/// @nodoc


class _ParsedLabel implements ParsedLabel {
  const _ParsedLabel({required this.rawText, required  Map<String, double> confidence, this.name, this.strength, this.timesPerDay, this.doseQty, this.form, this.mealRelation, this.isPrn}): _confidence = confidence;
  

@override final  String rawText;
/// Per field, 0..1. Includes fields that were dropped for low confidence.
 final  Map<String, double> _confidence;
/// Per field, 0..1. Includes fields that were dropped for low confidence.
@override Map<String, double> get confidence {
  if (_confidence is EqualUnmodifiableMapView) return _confidence;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_confidence);
}

@override final  String? name;
@override final  String? strength;
@override final  int? timesPerDay;
@override final  double? doseQty;
@override final  MedForm? form;
@override final  MealRelation? mealRelation;
@override final  bool? isPrn;

/// Create a copy of ParsedLabel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParsedLabelCopyWith<_ParsedLabel> get copyWith => __$ParsedLabelCopyWithImpl<_ParsedLabel>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParsedLabel&&(identical(other.rawText, rawText) || other.rawText == rawText)&&const DeepCollectionEquality().equals(other.confidence, _confidence)&&(identical(other.name, name) || other.name == name)&&(identical(other.strength, strength) || other.strength == strength)&&(identical(other.timesPerDay, timesPerDay) || other.timesPerDay == timesPerDay)&&(identical(other.doseQty, doseQty) || other.doseQty == doseQty)&&(identical(other.form, form) || other.form == form)&&(identical(other.mealRelation, mealRelation) || other.mealRelation == mealRelation)&&(identical(other.isPrn, isPrn) || other.isPrn == isPrn));
}


@override
int get hashCode {
    return Object.hash(runtimeType,rawText,const DeepCollectionEquality().hash(_confidence),name,strength,timesPerDay,doseQty,form,mealRelation,isPrn);
}

@override
String toString() {
    return 'ParsedLabel(rawText: $rawText, confidence: $confidence, name: $name, strength: $strength, timesPerDay: $timesPerDay, doseQty: $doseQty, form: $form, mealRelation: $mealRelation, isPrn: $isPrn)';
}


}

/// @nodoc
abstract mixin class _$ParsedLabelCopyWith<$Res> implements $ParsedLabelCopyWith<$Res> {
  factory _$ParsedLabelCopyWith(_ParsedLabel value, $Res Function(_ParsedLabel) _then) = __$ParsedLabelCopyWithImpl;
@override @useResult
$Res call({
 String rawText, Map<String, double> confidence, String? name, String? strength, int? timesPerDay, double? doseQty, MedForm? form, MealRelation? mealRelation, bool? isPrn
});




}
/// @nodoc
class __$ParsedLabelCopyWithImpl<$Res>
    implements _$ParsedLabelCopyWith<$Res> {
  __$ParsedLabelCopyWithImpl(this._self, this._then);

  final _ParsedLabel _self;
  final $Res Function(_ParsedLabel) _then;

/// Create a copy of ParsedLabel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rawText = null,Object? confidence = null,Object? name = freezed,Object? strength = freezed,Object? timesPerDay = freezed,Object? doseQty = freezed,Object? form = freezed,Object? mealRelation = freezed,Object? isPrn = freezed,}) {
  return _then(_ParsedLabel(
rawText: null == rawText ? _self.rawText : rawText // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self._confidence : confidence // ignore: cast_nullable_to_non_nullable
as Map<String, double>,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,strength: freezed == strength ? _self.strength : strength // ignore: cast_nullable_to_non_nullable
as String?,timesPerDay: freezed == timesPerDay ? _self.timesPerDay : timesPerDay // ignore: cast_nullable_to_non_nullable
as int?,doseQty: freezed == doseQty ? _self.doseQty : doseQty // ignore: cast_nullable_to_non_nullable
as double?,form: freezed == form ? _self.form : form // ignore: cast_nullable_to_non_nullable
as MedForm?,mealRelation: freezed == mealRelation ? _self.mealRelation : mealRelation // ignore: cast_nullable_to_non_nullable
as MealRelation?,isPrn: freezed == isPrn ? _self.isPrn : isPrn // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
