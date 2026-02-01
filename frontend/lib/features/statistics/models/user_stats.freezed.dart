// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserStats {

/// Unique identifier for the stats record (usually 1)
 int get id;/// Total number of puzzles completed
 int get totalPuzzlesCompleted;/// Total number of words found across all puzzles
 int get totalWordsFound;/// Total play time in seconds
 int get totalPlayTimeSeconds;/// Current consecutive days streak
 int get currentStreak;/// Longest consecutive days streak ever achieved
 int get longestStreak;/// Last date the user played
 DateTime? get lastPlayedDate;/// Date when stats were created
 DateTime? get createdAt;/// Date when stats were last updated
 DateTime? get updatedAt;
/// Create a copy of UserStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserStatsCopyWith<UserStats> get copyWith => _$UserStatsCopyWithImpl<UserStats>(this as UserStats, _$identity);

  /// Serializes this UserStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserStats&&(identical(other.id, id) || other.id == id)&&(identical(other.totalPuzzlesCompleted, totalPuzzlesCompleted) || other.totalPuzzlesCompleted == totalPuzzlesCompleted)&&(identical(other.totalWordsFound, totalWordsFound) || other.totalWordsFound == totalWordsFound)&&(identical(other.totalPlayTimeSeconds, totalPlayTimeSeconds) || other.totalPlayTimeSeconds == totalPlayTimeSeconds)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.lastPlayedDate, lastPlayedDate) || other.lastPlayedDate == lastPlayedDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,totalPuzzlesCompleted,totalWordsFound,totalPlayTimeSeconds,currentStreak,longestStreak,lastPlayedDate,createdAt,updatedAt);

@override
String toString() {
  return 'UserStats(id: $id, totalPuzzlesCompleted: $totalPuzzlesCompleted, totalWordsFound: $totalWordsFound, totalPlayTimeSeconds: $totalPlayTimeSeconds, currentStreak: $currentStreak, longestStreak: $longestStreak, lastPlayedDate: $lastPlayedDate, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UserStatsCopyWith<$Res>  {
  factory $UserStatsCopyWith(UserStats value, $Res Function(UserStats) _then) = _$UserStatsCopyWithImpl;
@useResult
$Res call({
 int id, int totalPuzzlesCompleted, int totalWordsFound, int totalPlayTimeSeconds, int currentStreak, int longestStreak, DateTime? lastPlayedDate, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$UserStatsCopyWithImpl<$Res>
    implements $UserStatsCopyWith<$Res> {
  _$UserStatsCopyWithImpl(this._self, this._then);

  final UserStats _self;
  final $Res Function(UserStats) _then;

/// Create a copy of UserStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? totalPuzzlesCompleted = null,Object? totalWordsFound = null,Object? totalPlayTimeSeconds = null,Object? currentStreak = null,Object? longestStreak = null,Object? lastPlayedDate = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,totalPuzzlesCompleted: null == totalPuzzlesCompleted ? _self.totalPuzzlesCompleted : totalPuzzlesCompleted // ignore: cast_nullable_to_non_nullable
as int,totalWordsFound: null == totalWordsFound ? _self.totalWordsFound : totalWordsFound // ignore: cast_nullable_to_non_nullable
as int,totalPlayTimeSeconds: null == totalPlayTimeSeconds ? _self.totalPlayTimeSeconds : totalPlayTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,lastPlayedDate: freezed == lastPlayedDate ? _self.lastPlayedDate : lastPlayedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserStats].
extension UserStatsPatterns on UserStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserStats value)  $default,){
final _that = this;
switch (_that) {
case _UserStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserStats value)?  $default,){
final _that = this;
switch (_that) {
case _UserStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int totalPuzzlesCompleted,  int totalWordsFound,  int totalPlayTimeSeconds,  int currentStreak,  int longestStreak,  DateTime? lastPlayedDate,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserStats() when $default != null:
return $default(_that.id,_that.totalPuzzlesCompleted,_that.totalWordsFound,_that.totalPlayTimeSeconds,_that.currentStreak,_that.longestStreak,_that.lastPlayedDate,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int totalPuzzlesCompleted,  int totalWordsFound,  int totalPlayTimeSeconds,  int currentStreak,  int longestStreak,  DateTime? lastPlayedDate,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _UserStats():
return $default(_that.id,_that.totalPuzzlesCompleted,_that.totalWordsFound,_that.totalPlayTimeSeconds,_that.currentStreak,_that.longestStreak,_that.lastPlayedDate,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int totalPuzzlesCompleted,  int totalWordsFound,  int totalPlayTimeSeconds,  int currentStreak,  int longestStreak,  DateTime? lastPlayedDate,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserStats() when $default != null:
return $default(_that.id,_that.totalPuzzlesCompleted,_that.totalWordsFound,_that.totalPlayTimeSeconds,_that.currentStreak,_that.longestStreak,_that.lastPlayedDate,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserStats extends UserStats {
  const _UserStats({this.id = 1, this.totalPuzzlesCompleted = 0, this.totalWordsFound = 0, this.totalPlayTimeSeconds = 0, this.currentStreak = 0, this.longestStreak = 0, this.lastPlayedDate, this.createdAt, this.updatedAt}): super._();
  factory _UserStats.fromJson(Map<String, dynamic> json) => _$UserStatsFromJson(json);

/// Unique identifier for the stats record (usually 1)
@override@JsonKey() final  int id;
/// Total number of puzzles completed
@override@JsonKey() final  int totalPuzzlesCompleted;
/// Total number of words found across all puzzles
@override@JsonKey() final  int totalWordsFound;
/// Total play time in seconds
@override@JsonKey() final  int totalPlayTimeSeconds;
/// Current consecutive days streak
@override@JsonKey() final  int currentStreak;
/// Longest consecutive days streak ever achieved
@override@JsonKey() final  int longestStreak;
/// Last date the user played
@override final  DateTime? lastPlayedDate;
/// Date when stats were created
@override final  DateTime? createdAt;
/// Date when stats were last updated
@override final  DateTime? updatedAt;

/// Create a copy of UserStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserStatsCopyWith<_UserStats> get copyWith => __$UserStatsCopyWithImpl<_UserStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserStats&&(identical(other.id, id) || other.id == id)&&(identical(other.totalPuzzlesCompleted, totalPuzzlesCompleted) || other.totalPuzzlesCompleted == totalPuzzlesCompleted)&&(identical(other.totalWordsFound, totalWordsFound) || other.totalWordsFound == totalWordsFound)&&(identical(other.totalPlayTimeSeconds, totalPlayTimeSeconds) || other.totalPlayTimeSeconds == totalPlayTimeSeconds)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&(identical(other.lastPlayedDate, lastPlayedDate) || other.lastPlayedDate == lastPlayedDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,totalPuzzlesCompleted,totalWordsFound,totalPlayTimeSeconds,currentStreak,longestStreak,lastPlayedDate,createdAt,updatedAt);

@override
String toString() {
  return 'UserStats(id: $id, totalPuzzlesCompleted: $totalPuzzlesCompleted, totalWordsFound: $totalWordsFound, totalPlayTimeSeconds: $totalPlayTimeSeconds, currentStreak: $currentStreak, longestStreak: $longestStreak, lastPlayedDate: $lastPlayedDate, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserStatsCopyWith<$Res> implements $UserStatsCopyWith<$Res> {
  factory _$UserStatsCopyWith(_UserStats value, $Res Function(_UserStats) _then) = __$UserStatsCopyWithImpl;
@override @useResult
$Res call({
 int id, int totalPuzzlesCompleted, int totalWordsFound, int totalPlayTimeSeconds, int currentStreak, int longestStreak, DateTime? lastPlayedDate, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$UserStatsCopyWithImpl<$Res>
    implements _$UserStatsCopyWith<$Res> {
  __$UserStatsCopyWithImpl(this._self, this._then);

  final _UserStats _self;
  final $Res Function(_UserStats) _then;

/// Create a copy of UserStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? totalPuzzlesCompleted = null,Object? totalWordsFound = null,Object? totalPlayTimeSeconds = null,Object? currentStreak = null,Object? longestStreak = null,Object? lastPlayedDate = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_UserStats(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,totalPuzzlesCompleted: null == totalPuzzlesCompleted ? _self.totalPuzzlesCompleted : totalPuzzlesCompleted // ignore: cast_nullable_to_non_nullable
as int,totalWordsFound: null == totalWordsFound ? _self.totalWordsFound : totalWordsFound // ignore: cast_nullable_to_non_nullable
as int,totalPlayTimeSeconds: null == totalPlayTimeSeconds ? _self.totalPlayTimeSeconds : totalPlayTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,lastPlayedDate: freezed == lastPlayedDate ? _self.lastPlayedDate : lastPlayedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
