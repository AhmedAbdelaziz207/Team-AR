// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_diet_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UserDietState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<UserDiet> diet) success,
    required TResult Function(ApiErrorModel errorMessage) failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<UserDiet> diet)? success,
    TResult? Function(ApiErrorModel errorMessage)? failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<UserDiet> diet)? success,
    TResult Function(ApiErrorModel errorMessage)? failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(UserDietLoading value) loading,
    required TResult Function(UserDietSuccess value) success,
    required TResult Function(UserDietFailure value) failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(UserDietLoading value)? loading,
    TResult? Function(UserDietSuccess value)? success,
    TResult? Function(UserDietFailure value)? failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(UserDietLoading value)? loading,
    TResult Function(UserDietSuccess value)? success,
    TResult Function(UserDietFailure value)? failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserDietStateCopyWith<$Res> {
  factory $UserDietStateCopyWith(
          UserDietState value, $Res Function(UserDietState) then) =
      _$UserDietStateCopyWithImpl<$Res, UserDietState>;
}

/// @nodoc
class _$UserDietStateCopyWithImpl<$Res, $Val extends UserDietState>
    implements $UserDietStateCopyWith<$Res> {
  _$UserDietStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserDietState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$UserDietStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserDietState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'UserDietState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<UserDiet> diet) success,
    required TResult Function(ApiErrorModel errorMessage) failure,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<UserDiet> diet)? success,
    TResult? Function(ApiErrorModel errorMessage)? failure,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<UserDiet> diet)? success,
    TResult Function(ApiErrorModel errorMessage)? failure,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(UserDietLoading value) loading,
    required TResult Function(UserDietSuccess value) success,
    required TResult Function(UserDietFailure value) failure,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(UserDietLoading value)? loading,
    TResult? Function(UserDietSuccess value)? success,
    TResult? Function(UserDietFailure value)? failure,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(UserDietLoading value)? loading,
    TResult Function(UserDietSuccess value)? success,
    TResult Function(UserDietFailure value)? failure,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements UserDietState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$UserDietLoadingImplCopyWith<$Res> {
  factory _$$UserDietLoadingImplCopyWith(_$UserDietLoadingImpl value,
          $Res Function(_$UserDietLoadingImpl) then) =
      __$$UserDietLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$UserDietLoadingImplCopyWithImpl<$Res>
    extends _$UserDietStateCopyWithImpl<$Res, _$UserDietLoadingImpl>
    implements _$$UserDietLoadingImplCopyWith<$Res> {
  __$$UserDietLoadingImplCopyWithImpl(
      _$UserDietLoadingImpl _value, $Res Function(_$UserDietLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserDietState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$UserDietLoadingImpl implements UserDietLoading {
  const _$UserDietLoadingImpl();

  @override
  String toString() {
    return 'UserDietState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$UserDietLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<UserDiet> diet) success,
    required TResult Function(ApiErrorModel errorMessage) failure,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<UserDiet> diet)? success,
    TResult? Function(ApiErrorModel errorMessage)? failure,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<UserDiet> diet)? success,
    TResult Function(ApiErrorModel errorMessage)? failure,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(UserDietLoading value) loading,
    required TResult Function(UserDietSuccess value) success,
    required TResult Function(UserDietFailure value) failure,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(UserDietLoading value)? loading,
    TResult? Function(UserDietSuccess value)? success,
    TResult? Function(UserDietFailure value)? failure,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(UserDietLoading value)? loading,
    TResult Function(UserDietSuccess value)? success,
    TResult Function(UserDietFailure value)? failure,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class UserDietLoading implements UserDietState {
  const factory UserDietLoading() = _$UserDietLoadingImpl;
}

/// @nodoc
abstract class _$$UserDietSuccessImplCopyWith<$Res> {
  factory _$$UserDietSuccessImplCopyWith(_$UserDietSuccessImpl value,
          $Res Function(_$UserDietSuccessImpl) then) =
      __$$UserDietSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<UserDiet> diet});
}

/// @nodoc
class __$$UserDietSuccessImplCopyWithImpl<$Res>
    extends _$UserDietStateCopyWithImpl<$Res, _$UserDietSuccessImpl>
    implements _$$UserDietSuccessImplCopyWith<$Res> {
  __$$UserDietSuccessImplCopyWithImpl(
      _$UserDietSuccessImpl _value, $Res Function(_$UserDietSuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserDietState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? diet = null,
  }) {
    return _then(_$UserDietSuccessImpl(
      null == diet
          ? _value._diet
          : diet // ignore: cast_nullable_to_non_nullable
              as List<UserDiet>,
    ));
  }
}

/// @nodoc

class _$UserDietSuccessImpl implements UserDietSuccess {
  const _$UserDietSuccessImpl(final List<UserDiet> diet) : _diet = diet;

  final List<UserDiet> _diet;
  @override
  List<UserDiet> get diet {
    if (_diet is EqualUnmodifiableListView) return _diet;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_diet);
  }

  @override
  String toString() {
    return 'UserDietState.success(diet: $diet)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserDietSuccessImpl &&
            const DeepCollectionEquality().equals(other._diet, _diet));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_diet));

  /// Create a copy of UserDietState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserDietSuccessImplCopyWith<_$UserDietSuccessImpl> get copyWith =>
      __$$UserDietSuccessImplCopyWithImpl<_$UserDietSuccessImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<UserDiet> diet) success,
    required TResult Function(ApiErrorModel errorMessage) failure,
  }) {
    return success(diet);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<UserDiet> diet)? success,
    TResult? Function(ApiErrorModel errorMessage)? failure,
  }) {
    return success?.call(diet);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<UserDiet> diet)? success,
    TResult Function(ApiErrorModel errorMessage)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(diet);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(UserDietLoading value) loading,
    required TResult Function(UserDietSuccess value) success,
    required TResult Function(UserDietFailure value) failure,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(UserDietLoading value)? loading,
    TResult? Function(UserDietSuccess value)? success,
    TResult? Function(UserDietFailure value)? failure,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(UserDietLoading value)? loading,
    TResult Function(UserDietSuccess value)? success,
    TResult Function(UserDietFailure value)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class UserDietSuccess implements UserDietState {
  const factory UserDietSuccess(final List<UserDiet> diet) =
      _$UserDietSuccessImpl;

  List<UserDiet> get diet;

  /// Create a copy of UserDietState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserDietSuccessImplCopyWith<_$UserDietSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UserDietFailureImplCopyWith<$Res> {
  factory _$$UserDietFailureImplCopyWith(_$UserDietFailureImpl value,
          $Res Function(_$UserDietFailureImpl) then) =
      __$$UserDietFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ApiErrorModel errorMessage});
}

/// @nodoc
class __$$UserDietFailureImplCopyWithImpl<$Res>
    extends _$UserDietStateCopyWithImpl<$Res, _$UserDietFailureImpl>
    implements _$$UserDietFailureImplCopyWith<$Res> {
  __$$UserDietFailureImplCopyWithImpl(
      _$UserDietFailureImpl _value, $Res Function(_$UserDietFailureImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserDietState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? errorMessage = null,
  }) {
    return _then(_$UserDietFailureImpl(
      null == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as ApiErrorModel,
    ));
  }
}

/// @nodoc

class _$UserDietFailureImpl implements UserDietFailure {
  const _$UserDietFailureImpl(this.errorMessage);

  @override
  final ApiErrorModel errorMessage;

  @override
  String toString() {
    return 'UserDietState.failure(errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserDietFailureImpl &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, errorMessage);

  /// Create a copy of UserDietState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserDietFailureImplCopyWith<_$UserDietFailureImpl> get copyWith =>
      __$$UserDietFailureImplCopyWithImpl<_$UserDietFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<UserDiet> diet) success,
    required TResult Function(ApiErrorModel errorMessage) failure,
  }) {
    return failure(errorMessage);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<UserDiet> diet)? success,
    TResult? Function(ApiErrorModel errorMessage)? failure,
  }) {
    return failure?.call(errorMessage);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<UserDiet> diet)? success,
    TResult Function(ApiErrorModel errorMessage)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(errorMessage);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(UserDietLoading value) loading,
    required TResult Function(UserDietSuccess value) success,
    required TResult Function(UserDietFailure value) failure,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(UserDietLoading value)? loading,
    TResult? Function(UserDietSuccess value)? success,
    TResult? Function(UserDietFailure value)? failure,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(UserDietLoading value)? loading,
    TResult Function(UserDietSuccess value)? success,
    TResult Function(UserDietFailure value)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class UserDietFailure implements UserDietState {
  const factory UserDietFailure(final ApiErrorModel errorMessage) =
      _$UserDietFailureImpl;

  ApiErrorModel get errorMessage;

  /// Create a copy of UserDietState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserDietFailureImplCopyWith<_$UserDietFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
