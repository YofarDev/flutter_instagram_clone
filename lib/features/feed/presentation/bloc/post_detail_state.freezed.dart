// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostDetailState {

 Post? get post; PostDetailStatus get status; bool get isLiked; List<Comment> get comments; bool get sending; String? get error;
/// Create a copy of PostDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostDetailStateCopyWith<PostDetailState> get copyWith => _$PostDetailStateCopyWithImpl<PostDetailState>(this as PostDetailState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostDetailState&&(identical(other.post, post) || other.post == post)&&(identical(other.status, status) || other.status == status)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked)&&const DeepCollectionEquality().equals(other.comments, comments)&&(identical(other.sending, sending) || other.sending == sending)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,post,status,isLiked,const DeepCollectionEquality().hash(comments),sending,error);

@override
String toString() {
  return 'PostDetailState(post: $post, status: $status, isLiked: $isLiked, comments: $comments, sending: $sending, error: $error)';
}


}

/// @nodoc
abstract mixin class $PostDetailStateCopyWith<$Res>  {
  factory $PostDetailStateCopyWith(PostDetailState value, $Res Function(PostDetailState) _then) = _$PostDetailStateCopyWithImpl;
@useResult
$Res call({
 Post? post, PostDetailStatus status, bool isLiked, List<Comment> comments, bool sending, String? error
});


$PostCopyWith<$Res>? get post;

}
/// @nodoc
class _$PostDetailStateCopyWithImpl<$Res>
    implements $PostDetailStateCopyWith<$Res> {
  _$PostDetailStateCopyWithImpl(this._self, this._then);

  final PostDetailState _self;
  final $Res Function(PostDetailState) _then;

/// Create a copy of PostDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? post = freezed,Object? status = null,Object? isLiked = null,Object? comments = null,Object? sending = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
post: freezed == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as Post?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PostDetailStatus,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as List<Comment>,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of PostDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostCopyWith<$Res>? get post {
    if (_self.post == null) {
    return null;
  }

  return $PostCopyWith<$Res>(_self.post!, (value) {
    return _then(_self.copyWith(post: value));
  });
}
}


/// Adds pattern-matching-related methods to [PostDetailState].
extension PostDetailStatePatterns on PostDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostDetailState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostDetailState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostDetailState value)  $default,){
final _that = this;
switch (_that) {
case _PostDetailState():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostDetailState value)?  $default,){
final _that = this;
switch (_that) {
case _PostDetailState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Post? post,  PostDetailStatus status,  bool isLiked,  List<Comment> comments,  bool sending,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostDetailState() when $default != null:
return $default(_that.post,_that.status,_that.isLiked,_that.comments,_that.sending,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Post? post,  PostDetailStatus status,  bool isLiked,  List<Comment> comments,  bool sending,  String? error)  $default,) {final _that = this;
switch (_that) {
case _PostDetailState():
return $default(_that.post,_that.status,_that.isLiked,_that.comments,_that.sending,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Post? post,  PostDetailStatus status,  bool isLiked,  List<Comment> comments,  bool sending,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _PostDetailState() when $default != null:
return $default(_that.post,_that.status,_that.isLiked,_that.comments,_that.sending,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _PostDetailState implements PostDetailState {
  const _PostDetailState({this.post, this.status = PostDetailStatus.loading, this.isLiked = false, final  List<Comment> comments = const <Comment>[], this.sending = false, this.error}): _comments = comments;
  

@override final  Post? post;
@override@JsonKey() final  PostDetailStatus status;
@override@JsonKey() final  bool isLiked;
 final  List<Comment> _comments;
@override@JsonKey() List<Comment> get comments {
  if (_comments is EqualUnmodifiableListView) return _comments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_comments);
}

@override@JsonKey() final  bool sending;
@override final  String? error;

/// Create a copy of PostDetailState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostDetailStateCopyWith<_PostDetailState> get copyWith => __$PostDetailStateCopyWithImpl<_PostDetailState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostDetailState&&(identical(other.post, post) || other.post == post)&&(identical(other.status, status) || other.status == status)&&(identical(other.isLiked, isLiked) || other.isLiked == isLiked)&&const DeepCollectionEquality().equals(other._comments, _comments)&&(identical(other.sending, sending) || other.sending == sending)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,post,status,isLiked,const DeepCollectionEquality().hash(_comments),sending,error);

@override
String toString() {
  return 'PostDetailState(post: $post, status: $status, isLiked: $isLiked, comments: $comments, sending: $sending, error: $error)';
}


}

/// @nodoc
abstract mixin class _$PostDetailStateCopyWith<$Res> implements $PostDetailStateCopyWith<$Res> {
  factory _$PostDetailStateCopyWith(_PostDetailState value, $Res Function(_PostDetailState) _then) = __$PostDetailStateCopyWithImpl;
@override @useResult
$Res call({
 Post? post, PostDetailStatus status, bool isLiked, List<Comment> comments, bool sending, String? error
});


@override $PostCopyWith<$Res>? get post;

}
/// @nodoc
class __$PostDetailStateCopyWithImpl<$Res>
    implements _$PostDetailStateCopyWith<$Res> {
  __$PostDetailStateCopyWithImpl(this._self, this._then);

  final _PostDetailState _self;
  final $Res Function(_PostDetailState) _then;

/// Create a copy of PostDetailState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? post = freezed,Object? status = null,Object? isLiked = null,Object? comments = null,Object? sending = null,Object? error = freezed,}) {
  return _then(_PostDetailState(
post: freezed == post ? _self.post : post // ignore: cast_nullable_to_non_nullable
as Post?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PostDetailStatus,isLiked: null == isLiked ? _self.isLiked : isLiked // ignore: cast_nullable_to_non_nullable
as bool,comments: null == comments ? _self._comments : comments // ignore: cast_nullable_to_non_nullable
as List<Comment>,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of PostDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostCopyWith<$Res>? get post {
    if (_self.post == null) {
    return null;
  }

  return $PostCopyWith<$Res>(_self.post!, (value) {
    return _then(_self.copyWith(post: value));
  });
}
}

// dart format on
