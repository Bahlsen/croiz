// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'puzzle_stat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PuzzleStat {

/// ID of the puzzle this stat is for
 String get puzzleId;/// When the puzzle was completed
 DateTime get completedAt;/// Time taken to complete the puzzle (in seconds)
 int get timeToCompleteSeconds;/// Total number of words in the puzzle
 int get totalWords;/// Unique identifier for this stat record
 int? get id;/// Number of hints used (words or letters revealed)
 int get hintsUsed;/// Accuracy: ratio of correct letters on first try (0.0 - 1.0)
 double get accuracy;/// Number of words that were revealed (not solved by user)
 int get wordsRevealed;
/// Create a copy of PuzzleStat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PuzzleStatCopyWith<PuzzleStat> get copyWith => _$PuzzleStatCopyWithImpl<PuzzleStat>(this as PuzzleStat, _$identity);

  /// Serializes this PuzzleStat to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PuzzleStat&&(identical(other.puzzleId, puzzleId) || other.puzzleId == puzzleId)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.timeToCompleteSeconds, timeToCompleteSeconds) || other.timeToCompleteSeconds == timeToCompleteSeconds)&&(identical(other.totalWords, totalWords) || other.totalWords == totalWords)&&(identical(other.id, id) || other.id == id)&&(identical(other.hintsUsed, hintsUsed) || other.hintsUsed == hintsUsed)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.wordsRevealed, wordsRevealed) || other.wordsRevealed == wordsRevealed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,puzzleId,completedAt,timeToCompleteSeconds,totalWords,id,hintsUsed,accuracy,wordsRevealed);

@override
String toString() {
  return 'PuzzleStat(puzzleId: $puzzleId, completedAt: $completedAt, timeToCompleteSeconds: $timeToCompleteSeconds, totalWords: $totalWords, id: $id, hintsUsed: $hintsUsed, accuracy: $accuracy, wordsRevealed: $wordsRevealed)';
}


}

/// @nodoc
abstract mixin class $PuzzleStatCopyWith<$Res>  {
  factory $PuzzleStatCopyWith(PuzzleStat value, $Res Function(PuzzleStat) _then) = _$PuzzleStatCopyWithImpl;
@useResult
$Res call({
 String puzzleId, DateTime completedAt, int timeToCompleteSeconds, int totalWords, int? id, int hintsUsed, double accuracy, int wordsRevealed
});




}
/// @nodoc
class _$PuzzleStatCopyWithImpl<$Res>
    implements $PuzzleStatCopyWith<$Res> {
  _$PuzzleStatCopyWithImpl(this._self, this._then);

  final PuzzleStat _self;
  final $Res Function(PuzzleStat) _then;

/// Create a copy of PuzzleStat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? puzzleId = null,Object? completedAt = null,Object? timeToCompleteSeconds = null,Object? totalWords = null,Object? id = freezed,Object? hintsUsed = null,Object? accuracy = null,Object? wordsRevealed = null,}) {
  return _then(_self.copyWith(
puzzleId: null == puzzleId ? _self.puzzleId : puzzleId // ignore: cast_nullable_to_non_nullable
as String,completedAt: null == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime,timeToCompleteSeconds: null == timeToCompleteSeconds ? _self.timeToCompleteSeconds : timeToCompleteSeconds // ignore: cast_nullable_to_non_nullable
as int,totalWords: null == totalWords ? _self.totalWords : totalWords // ignore: cast_nullable_to_non_nullable
as int,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,hintsUsed: null == hintsUsed ? _self.hintsUsed : hintsUsed // ignore: cast_nullable_to_non_nullable
as int,accuracy: null == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double,wordsRevealed: null == wordsRevealed ? _self.wordsRevealed : wordsRevealed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PuzzleStat].
extension PuzzleStatPatterns on PuzzleStat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PuzzleStat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PuzzleStat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PuzzleStat value)  $default,){
final _that = this;
switch (_that) {
case _PuzzleStat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PuzzleStat value)?  $default,){
final _that = this;
switch (_that) {
case _PuzzleStat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String puzzleId,  DateTime completedAt,  int timeToCompleteSeconds,  int totalWords,  int? id,  int hintsUsed,  double accuracy,  int wordsRevealed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PuzzleStat() when $default != null:
return $default(_that.puzzleId,_that.completedAt,_that.timeToCompleteSeconds,_that.totalWords,_that.id,_that.hintsUsed,_that.accuracy,_that.wordsRevealed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String puzzleId,  DateTime completedAt,  int timeToCompleteSeconds,  int totalWords,  int? id,  int hintsUsed,  double accuracy,  int wordsRevealed)  $default,) {final _that = this;
switch (_that) {
case _PuzzleStat():
return $default(_that.puzzleId,_that.completedAt,_that.timeToCompleteSeconds,_that.totalWords,_that.id,_that.hintsUsed,_that.accuracy,_that.wordsRevealed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String puzzleId,  DateTime completedAt,  int timeToCompleteSeconds,  int totalWords,  int? id,  int hintsUsed,  double accuracy,  int wordsRevealed)?  $default,) {final _that = this;
switch (_that) {
case _PuzzleStat() when $default != null:
return $default(_that.puzzleId,_that.completedAt,_that.timeToCompleteSeconds,_that.totalWords,_that.id,_that.hintsUsed,_that.accuracy,_that.wordsRevealed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PuzzleStat extends PuzzleStat {
  const _PuzzleStat({required this.puzzleId, required this.completedAt, required this.timeToCompleteSeconds, required this.totalWords, this.id, this.hintsUsed = 0, this.accuracy = 1, this.wordsRevealed = 0}): super._();
  factory _PuzzleStat.fromJson(Map<String, dynamic> json) => _$PuzzleStatFromJson(json);

/// ID of the puzzle this stat is for
@override final  String puzzleId;
/// When the puzzle was completed
@override final  DateTime completedAt;
/// Time taken to complete the puzzle (in seconds)
@override final  int timeToCompleteSeconds;
/// Total number of words in the puzzle
@override final  int totalWords;
/// Unique identifier for this stat record
@override final  int? id;
/// Number of hints used (words or letters revealed)
@override@JsonKey() final  int hintsUsed;
/// Accuracy: ratio of correct letters on first try (0.0 - 1.0)
@override@JsonKey() final  double accuracy;
/// Number of words that were revealed (not solved by user)
@override@JsonKey() final  int wordsRevealed;

/// Create a copy of PuzzleStat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PuzzleStatCopyWith<_PuzzleStat> get copyWith => __$PuzzleStatCopyWithImpl<_PuzzleStat>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PuzzleStatToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PuzzleStat&&(identical(other.puzzleId, puzzleId) || other.puzzleId == puzzleId)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.timeToCompleteSeconds, timeToCompleteSeconds) || other.timeToCompleteSeconds == timeToCompleteSeconds)&&(identical(other.totalWords, totalWords) || other.totalWords == totalWords)&&(identical(other.id, id) || other.id == id)&&(identical(other.hintsUsed, hintsUsed) || other.hintsUsed == hintsUsed)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.wordsRevealed, wordsRevealed) || other.wordsRevealed == wordsRevealed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,puzzleId,completedAt,timeToCompleteSeconds,totalWords,id,hintsUsed,accuracy,wordsRevealed);

@override
String toString() {
  return 'PuzzleStat(puzzleId: $puzzleId, completedAt: $completedAt, timeToCompleteSeconds: $timeToCompleteSeconds, totalWords: $totalWords, id: $id, hintsUsed: $hintsUsed, accuracy: $accuracy, wordsRevealed: $wordsRevealed)';
}


}

/// @nodoc
abstract mixin class _$PuzzleStatCopyWith<$Res> implements $PuzzleStatCopyWith<$Res> {
  factory _$PuzzleStatCopyWith(_PuzzleStat value, $Res Function(_PuzzleStat) _then) = __$PuzzleStatCopyWithImpl;
@override @useResult
$Res call({
 String puzzleId, DateTime completedAt, int timeToCompleteSeconds, int totalWords, int? id, int hintsUsed, double accuracy, int wordsRevealed
});




}
/// @nodoc
class __$PuzzleStatCopyWithImpl<$Res>
    implements _$PuzzleStatCopyWith<$Res> {
  __$PuzzleStatCopyWithImpl(this._self, this._then);

  final _PuzzleStat _self;
  final $Res Function(_PuzzleStat) _then;

/// Create a copy of PuzzleStat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? puzzleId = null,Object? completedAt = null,Object? timeToCompleteSeconds = null,Object? totalWords = null,Object? id = freezed,Object? hintsUsed = null,Object? accuracy = null,Object? wordsRevealed = null,}) {
  return _then(_PuzzleStat(
puzzleId: null == puzzleId ? _self.puzzleId : puzzleId // ignore: cast_nullable_to_non_nullable
as String,completedAt: null == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime,timeToCompleteSeconds: null == timeToCompleteSeconds ? _self.timeToCompleteSeconds : timeToCompleteSeconds // ignore: cast_nullable_to_non_nullable
as int,totalWords: null == totalWords ? _self.totalWords : totalWords // ignore: cast_nullable_to_non_nullable
as int,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,hintsUsed: null == hintsUsed ? _self.hintsUsed : hintsUsed // ignore: cast_nullable_to_non_nullable
as int,accuracy: null == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double,wordsRevealed: null == wordsRevealed ? _self.wordsRevealed : wordsRevealed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
