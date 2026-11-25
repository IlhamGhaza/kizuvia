// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medication.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Medication {

 String get id; String get patientId; String get name; DateTime get startDate; double get doseQty; int get refillThresholdDays; bool get isPrn; bool get isActive; String get source; String? get strength; MedForm? get form; String? get instructions; MealRelation? get mealRelation; String? get prescribedBy; double? get stockQty; String? get photoPath;/// Key in the private photo bucket; set by sync, not by the form.
 String? get photoRemotePath;/// Inclusive instant: no occurrence is created after it.
 DateTime? get endDate;
/// Create a copy of Medication
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicationCopyWith<Medication> get copyWith => _$MedicationCopyWithImpl<Medication>(this as Medication, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Medication;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Medication&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.patientId, _this.patientId) || other.patientId == _this.patientId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.startDate, _this.startDate) || other.startDate == _this.startDate)&&(identical(other.doseQty, _this.doseQty) || other.doseQty == _this.doseQty)&&(identical(other.refillThresholdDays, _this.refillThresholdDays) || other.refillThresholdDays == _this.refillThresholdDays)&&(identical(other.isPrn, _this.isPrn) || other.isPrn == _this.isPrn)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.source, _this.source) || other.source == _this.source)&&(identical(other.strength, _this.strength) || other.strength == _this.strength)&&(identical(other.form, _this.form) || other.form == _this.form)&&(identical(other.instructions, _this.instructions) || other.instructions == _this.instructions)&&(identical(other.mealRelation, _this.mealRelation) || other.mealRelation == _this.mealRelation)&&(identical(other.prescribedBy, _this.prescribedBy) || other.prescribedBy == _this.prescribedBy)&&(identical(other.stockQty, _this.stockQty) || other.stockQty == _this.stockQty)&&(identical(other.photoPath, _this.photoPath) || other.photoPath == _this.photoPath)&&(identical(other.photoRemotePath, _this.photoRemotePath) || other.photoRemotePath == _this.photoRemotePath)&&(identical(other.endDate, _this.endDate) || other.endDate == _this.endDate));
}


@override
int get hashCode {
  final _this = this as Medication;
  return Object.hash(runtimeType,_this.id,_this.patientId,_this.name,_this.startDate,_this.doseQty,_this.refillThresholdDays,_this.isPrn,_this.isActive,_this.source,_this.strength,_this.form,_this.instructions,_this.mealRelation,_this.prescribedBy,_this.stockQty,_this.photoPath,_this.photoRemotePath,_this.endDate);
}

@override
String toString() {
  final _this = this as Medication;
  return 'Medication(id: ${_this.id}, patientId: ${_this.patientId}, name: ${_this.name}, startDate: ${_this.startDate}, doseQty: ${_this.doseQty}, refillThresholdDays: ${_this.refillThresholdDays}, isPrn: ${_this.isPrn}, isActive: ${_this.isActive}, source: ${_this.source}, strength: ${_this.strength}, form: ${_this.form}, instructions: ${_this.instructions}, mealRelation: ${_this.mealRelation}, prescribedBy: ${_this.prescribedBy}, stockQty: ${_this.stockQty}, photoPath: ${_this.photoPath}, photoRemotePath: ${_this.photoRemotePath}, endDate: ${_this.endDate})';
}


}

/// @nodoc
abstract mixin class $MedicationCopyWith<$Res>  {
  factory $MedicationCopyWith(Medication value, $Res Function(Medication) _then) = _$MedicationCopyWithImpl;
@useResult
$Res call({
 String id, String patientId, String name, DateTime startDate, double doseQty, int refillThresholdDays, bool isPrn, bool isActive, String source, String? strength, MedForm? form, String? instructions, MealRelation? mealRelation, String? prescribedBy, double? stockQty, String? photoPath, String? photoRemotePath, DateTime? endDate
});




}
/// @nodoc
class _$MedicationCopyWithImpl<$Res>
    implements $MedicationCopyWith<$Res> {
  _$MedicationCopyWithImpl(this._self, this._then);

  final Medication _self;
  final $Res Function(Medication) _then;

/// Create a copy of Medication
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? patientId = null,Object? name = null,Object? startDate = null,Object? doseQty = null,Object? refillThresholdDays = null,Object? isPrn = null,Object? isActive = null,Object? source = null,Object? strength = freezed,Object? form = freezed,Object? instructions = freezed,Object? mealRelation = freezed,Object? prescribedBy = freezed,Object? stockQty = freezed,Object? photoPath = freezed,Object? photoRemotePath = freezed,Object? endDate = freezed,}) {
  return _then(Medication(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,doseQty: null == doseQty ? _self.doseQty : doseQty // ignore: cast_nullable_to_non_nullable
as double,refillThresholdDays: null == refillThresholdDays ? _self.refillThresholdDays : refillThresholdDays // ignore: cast_nullable_to_non_nullable
as int,isPrn: null == isPrn ? _self.isPrn : isPrn // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,strength: freezed == strength ? _self.strength : strength // ignore: cast_nullable_to_non_nullable
as String?,form: freezed == form ? _self.form : form // ignore: cast_nullable_to_non_nullable
as MedForm?,instructions: freezed == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String?,mealRelation: freezed == mealRelation ? _self.mealRelation : mealRelation // ignore: cast_nullable_to_non_nullable
as MealRelation?,prescribedBy: freezed == prescribedBy ? _self.prescribedBy : prescribedBy // ignore: cast_nullable_to_non_nullable
as String?,stockQty: freezed == stockQty ? _self.stockQty : stockQty // ignore: cast_nullable_to_non_nullable
as double?,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,photoRemotePath: freezed == photoRemotePath ? _self.photoRemotePath : photoRemotePath // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Medication].
extension MedicationPatterns on Medication {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Medication value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Medication() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Medication value)  $default,){
final _that = this;
switch (_that) {
case _Medication():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Medication value)?  $default,){
final _that = this;
switch (_that) {
case _Medication() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String patientId,  String name,  DateTime startDate,  double doseQty,  int refillThresholdDays,  bool isPrn,  bool isActive,  String source,  String? strength,  MedForm? form,  String? instructions,  MealRelation? mealRelation,  String? prescribedBy,  double? stockQty,  String? photoPath,  String? photoRemotePath,  DateTime? endDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Medication() when $default != null:
return $default(_that.id,_that.patientId,_that.name,_that.startDate,_that.doseQty,_that.refillThresholdDays,_that.isPrn,_that.isActive,_that.source,_that.strength,_that.form,_that.instructions,_that.mealRelation,_that.prescribedBy,_that.stockQty,_that.photoPath,_that.photoRemotePath,_that.endDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String patientId,  String name,  DateTime startDate,  double doseQty,  int refillThresholdDays,  bool isPrn,  bool isActive,  String source,  String? strength,  MedForm? form,  String? instructions,  MealRelation? mealRelation,  String? prescribedBy,  double? stockQty,  String? photoPath,  String? photoRemotePath,  DateTime? endDate)  $default,) {final _that = this;
switch (_that) {
case _Medication():
return $default(_that.id,_that.patientId,_that.name,_that.startDate,_that.doseQty,_that.refillThresholdDays,_that.isPrn,_that.isActive,_that.source,_that.strength,_that.form,_that.instructions,_that.mealRelation,_that.prescribedBy,_that.stockQty,_that.photoPath,_that.photoRemotePath,_that.endDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String patientId,  String name,  DateTime startDate,  double doseQty,  int refillThresholdDays,  bool isPrn,  bool isActive,  String source,  String? strength,  MedForm? form,  String? instructions,  MealRelation? mealRelation,  String? prescribedBy,  double? stockQty,  String? photoPath,  String? photoRemotePath,  DateTime? endDate)?  $default,) {final _that = this;
switch (_that) {
case _Medication() when $default != null:
return $default(_that.id,_that.patientId,_that.name,_that.startDate,_that.doseQty,_that.refillThresholdDays,_that.isPrn,_that.isActive,_that.source,_that.strength,_that.form,_that.instructions,_that.mealRelation,_that.prescribedBy,_that.stockQty,_that.photoPath,_that.photoRemotePath,_that.endDate);case _:
  return null;

}
}

}

/// @nodoc


class _Medication implements Medication {
  const _Medication({required this.id, required this.patientId, required this.name, required this.startDate, this.doseQty = 1.0, this.refillThresholdDays = 3, this.isPrn = false, this.isActive = true, this.source = 'manual', this.strength, this.form, this.instructions, this.mealRelation, this.prescribedBy, this.stockQty, this.photoPath, this.photoRemotePath, this.endDate});
  

@override final  String id;
@override final  String patientId;
@override final  String name;
@override final  DateTime startDate;
@override@JsonKey() final  double doseQty;
@override@JsonKey() final  int refillThresholdDays;
@override@JsonKey() final  bool isPrn;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  String source;
@override final  String? strength;
@override final  MedForm? form;
@override final  String? instructions;
@override final  MealRelation? mealRelation;
@override final  String? prescribedBy;
@override final  double? stockQty;
@override final  String? photoPath;
/// Key in the private photo bucket; set by sync, not by the form.
@override final  String? photoRemotePath;
/// Inclusive instant: no occurrence is created after it.
@override final  DateTime? endDate;

/// Create a copy of Medication
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicationCopyWith<_Medication> get copyWith => __$MedicationCopyWithImpl<_Medication>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Medication&&(identical(other.id, id) || other.id == id)&&(identical(other.patientId, patientId) || other.patientId == patientId)&&(identical(other.name, name) || other.name == name)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.doseQty, doseQty) || other.doseQty == doseQty)&&(identical(other.refillThresholdDays, refillThresholdDays) || other.refillThresholdDays == refillThresholdDays)&&(identical(other.isPrn, isPrn) || other.isPrn == isPrn)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.source, source) || other.source == source)&&(identical(other.strength, strength) || other.strength == strength)&&(identical(other.form, form) || other.form == form)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.mealRelation, mealRelation) || other.mealRelation == mealRelation)&&(identical(other.prescribedBy, prescribedBy) || other.prescribedBy == prescribedBy)&&(identical(other.stockQty, stockQty) || other.stockQty == stockQty)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath)&&(identical(other.photoRemotePath, photoRemotePath) || other.photoRemotePath == photoRemotePath)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,patientId,name,startDate,doseQty,refillThresholdDays,isPrn,isActive,source,strength,form,instructions,mealRelation,prescribedBy,stockQty,photoPath,photoRemotePath,endDate);
}

@override
String toString() {
    return 'Medication(id: $id, patientId: $patientId, name: $name, startDate: $startDate, doseQty: $doseQty, refillThresholdDays: $refillThresholdDays, isPrn: $isPrn, isActive: $isActive, source: $source, strength: $strength, form: $form, instructions: $instructions, mealRelation: $mealRelation, prescribedBy: $prescribedBy, stockQty: $stockQty, photoPath: $photoPath, photoRemotePath: $photoRemotePath, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class _$MedicationCopyWith<$Res> implements $MedicationCopyWith<$Res> {
  factory _$MedicationCopyWith(_Medication value, $Res Function(_Medication) _then) = __$MedicationCopyWithImpl;
@override @useResult
$Res call({
 String id, String patientId, String name, DateTime startDate, double doseQty, int refillThresholdDays, bool isPrn, bool isActive, String source, String? strength, MedForm? form, String? instructions, MealRelation? mealRelation, String? prescribedBy, double? stockQty, String? photoPath, String? photoRemotePath, DateTime? endDate
});




}
/// @nodoc
class __$MedicationCopyWithImpl<$Res>
    implements _$MedicationCopyWith<$Res> {
  __$MedicationCopyWithImpl(this._self, this._then);

  final _Medication _self;
  final $Res Function(_Medication) _then;

/// Create a copy of Medication
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? patientId = null,Object? name = null,Object? startDate = null,Object? doseQty = null,Object? refillThresholdDays = null,Object? isPrn = null,Object? isActive = null,Object? source = null,Object? strength = freezed,Object? form = freezed,Object? instructions = freezed,Object? mealRelation = freezed,Object? prescribedBy = freezed,Object? stockQty = freezed,Object? photoPath = freezed,Object? photoRemotePath = freezed,Object? endDate = freezed,}) {
  return _then(_Medication(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,patientId: null == patientId ? _self.patientId : patientId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,doseQty: null == doseQty ? _self.doseQty : doseQty // ignore: cast_nullable_to_non_nullable
as double,refillThresholdDays: null == refillThresholdDays ? _self.refillThresholdDays : refillThresholdDays // ignore: cast_nullable_to_non_nullable
as int,isPrn: null == isPrn ? _self.isPrn : isPrn // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,strength: freezed == strength ? _self.strength : strength // ignore: cast_nullable_to_non_nullable
as String?,form: freezed == form ? _self.form : form // ignore: cast_nullable_to_non_nullable
as MedForm?,instructions: freezed == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String?,mealRelation: freezed == mealRelation ? _self.mealRelation : mealRelation // ignore: cast_nullable_to_non_nullable
as MealRelation?,prescribedBy: freezed == prescribedBy ? _self.prescribedBy : prescribedBy // ignore: cast_nullable_to_non_nullable
as String?,stockQty: freezed == stockQty ? _self.stockQty : stockQty // ignore: cast_nullable_to_non_nullable
as double?,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,photoRemotePath: freezed == photoRemotePath ? _self.photoRemotePath : photoRemotePath // ignore: cast_nullable_to_non_nullable
as String?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
