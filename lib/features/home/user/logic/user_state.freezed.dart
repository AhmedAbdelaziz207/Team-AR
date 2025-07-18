// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UserState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(TraineeModel userData) success,
    required TResult Function(TrainerModel userData) getTrainee,
    required TResult Function(String errorMessage) failure,
    required TResult Function() updateImageSuccess,
    required TResult Function(String message) updateImageFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(TraineeModel userData)? success,
    TResult? Function(TrainerModel userData)? getTrainee,
    TResult? Function(String errorMessage)? failure,
    TResult? Function()? updateImageSuccess,
    TResult? Function(String message)? updateImageFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(TraineeModel userData)? success,
    TResult Function(TrainerModel userData)? getTrainee,
    TResult Function(String errorMessage)? failure,
    TResult Function()? updateImageSuccess,
    TResult Function(String message)? updateImageFailure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UserInitial value) initial,
    required TResult Function(UserLoading value) loading,
    required TResult Function(UserSuccess value) success,
    required TResult Function(GetTrainee value) getTrainee,
    required TResult Function(UserFailure value) failure,
    required TResult Function(UpdateUserImageSuccess value) updateImageSuccess,
    required TResult Function(UpdateUserImageFailure value) updateImageFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UserInitial value)? initial,
    TResult? Function(UserLoading value)? loading,
    TResult? Function(UserSuccess value)? success,
    TResult? Function(GetTrainee value)? getTrainee,
    TResult? Function(UserFailure value)? failure,
    TResult? Function(UpdateUserImageSuccess value)? updateImageSuccess,
    TResult? Function(UpdateUserImageFailure value)? updateImageFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UserInitial value)? initial,
    TResult Function(UserLoading value)? loading,
    TResult Function(UserSuccess value)? success,
    TResult Function(GetTrainee value)? getTrainee,
    TResult Function(UserFailure value)? failure,
    TResult Function(UpdateUserImageSuccess value)? updateImageSuccess,
    TResult Function(UpdateUserImageFailure value)? updateImageFailure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserStateCopyWith<$Res> {
  factory $UserStateCopyWith(UserState value, $Res Function(UserState) then) =
      _$UserStateCopyWithImpl<$Res, UserState>;
}

/// @nodoc
class _$UserStateCopyWithImpl<$Res, $Val extends UserState>
    implements $UserStateCopyWith<$Res> {
  _$UserStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$UserInitialImplCopyWith<$Res> {
  factory _$$UserInitialImplCopyWith(
          _$UserInitialImpl value, $Res Function(_$UserInitialImpl) then) =
      __$$UserInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$UserInitialImplCopyWithImpl<$Res>
    extends _$UserStateCopyWithImpl<$Res, _$UserInitialImpl>
    implements _$$UserInitialImplCopyWith<$Res> {
  __$$UserInitialImplCopyWithImpl(
      _$UserInitialImpl _value, $Res Function(_$UserInitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$UserInitialImpl implements UserInitial {
  const _$UserInitialImpl();

  @override
  String toString() {
    return 'UserState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$UserInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(TraineeModel userData) success,
    required TResult Function(TrainerModel userData) getTrainee,
    required TResult Function(String errorMessage) failure,
    required TResult Function() updateImageSuccess,
    required TResult Function(String message) updateImageFailure,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(TraineeModel userData)? success,
    TResult? Function(TrainerModel userData)? getTrainee,
    TResult? Function(String errorMessage)? failure,
    TResult? Function()? updateImageSuccess,
    TResult? Function(String message)? updateImageFailure,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(TraineeModel userData)? success,
    TResult Function(TrainerModel userData)? getTrainee,
    TResult Function(String errorMessage)? failure,
    TResult Function()? updateImageSuccess,
    TResult Function(String message)? updateImageFailure,
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
    required TResult Function(UserInitial value) initial,
    required TResult Function(UserLoading value) loading,
    required TResult Function(UserSuccess value) success,
    required TResult Function(GetTrainee value) getTrainee,
    required TResult Function(UserFailure value) failure,
    required TResult Function(UpdateUserImageSuccess value) updateImageSuccess,
    required TResult Function(UpdateUserImageFailure value) updateImageFailure,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UserInitial value)? initial,
    TResult? Function(UserLoading value)? loading,
    TResult? Function(UserSuccess value)? success,
    TResult? Function(GetTrainee value)? getTrainee,
    TResult? Function(UserFailure value)? failure,
    TResult? Function(UpdateUserImageSuccess value)? updateImageSuccess,
    TResult? Function(UpdateUserImageFailure value)? updateImageFailure,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UserInitial value)? initial,
    TResult Function(UserLoading value)? loading,
    TResult Function(UserSuccess value)? success,
    TResult Function(GetTrainee value)? getTrainee,
    TResult Function(UserFailure value)? failure,
    TResult Function(UpdateUserImageSuccess value)? updateImageSuccess,
    TResult Function(UpdateUserImageFailure value)? updateImageFailure,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class UserInitial implements UserState {
  const factory UserInitial() = _$UserInitialImpl;
}

/// @nodoc
abstract class _$$UserLoadingImplCopyWith<$Res> {
  factory _$$UserLoadingImplCopyWith(
          _$UserLoadingImpl value, $Res Function(_$UserLoadingImpl) then) =
      __$$UserLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$UserLoadingImplCopyWithImpl<$Res>
    extends _$UserStateCopyWithImpl<$Res, _$UserLoadingImpl>
    implements _$$UserLoadingImplCopyWith<$Res> {
  __$$UserLoadingImplCopyWithImpl(
      _$UserLoadingImpl _value, $Res Function(_$UserLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$UserLoadingImpl implements UserLoading {
  const _$UserLoadingImpl();

  @override
  String toString() {
    return 'UserState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$UserLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(TraineeModel userData) success,
    required TResult Function(TrainerModel userData) getTrainee,
    required TResult Function(String errorMessage) failure,
    required TResult Function() updateImageSuccess,
    required TResult Function(String message) updateImageFailure,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(TraineeModel userData)? success,
    TResult? Function(TrainerModel userData)? getTrainee,
    TResult? Function(String errorMessage)? failure,
    TResult? Function()? updateImageSuccess,
    TResult? Function(String message)? updateImageFailure,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(TraineeModel userData)? success,
    TResult Function(TrainerModel userData)? getTrainee,
    TResult Function(String errorMessage)? failure,
    TResult Function()? updateImageSuccess,
    TResult Function(String message)? updateImageFailure,
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
    required TResult Function(UserInitial value) initial,
    required TResult Function(UserLoading value) loading,
    required TResult Function(UserSuccess value) success,
    required TResult Function(GetTrainee value) getTrainee,
    required TResult Function(UserFailure value) failure,
    required TResult Function(UpdateUserImageSuccess value) updateImageSuccess,
    required TResult Function(UpdateUserImageFailure value) updateImageFailure,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UserInitial value)? initial,
    TResult? Function(UserLoading value)? loading,
    TResult? Function(UserSuccess value)? success,
    TResult? Function(GetTrainee value)? getTrainee,
    TResult? Function(UserFailure value)? failure,
    TResult? Function(UpdateUserImageSuccess value)? updateImageSuccess,
    TResult? Function(UpdateUserImageFailure value)? updateImageFailure,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UserInitial value)? initial,
    TResult Function(UserLoading value)? loading,
    TResult Function(UserSuccess value)? success,
    TResult Function(GetTrainee value)? getTrainee,
    TResult Function(UserFailure value)? failure,
    TResult Function(UpdateUserImageSuccess value)? updateImageSuccess,
    TResult Function(UpdateUserImageFailure value)? updateImageFailure,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class UserLoading implements UserState {
  const factory UserLoading() = _$UserLoadingImpl;
}

/// @nodoc
abstract class _$$UserSuccessImplCopyWith<$Res> {
  factory _$$UserSuccessImplCopyWith(
          _$UserSuccessImpl value, $Res Function(_$UserSuccessImpl) then) =
      __$$UserSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({TraineeModel userData});
}

/// @nodoc
class __$$UserSuccessImplCopyWithImpl<$Res>
    extends _$UserStateCopyWithImpl<$Res, _$UserSuccessImpl>
    implements _$$UserSuccessImplCopyWith<$Res> {
  __$$UserSuccessImplCopyWithImpl(
      _$UserSuccessImpl _value, $Res Function(_$UserSuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userData = null,
  }) {
    return _then(_$UserSuccessImpl(
      null == userData
          ? _value.userData
          : userData // ignore: cast_nullable_to_non_nullable
              as TraineeModel,
    ));
  }
}

/// @nodoc

class _$UserSuccessImpl implements UserSuccess {
  const _$UserSuccessImpl(this.userData);

  @override
  final TraineeModel userData;

  @override
  String toString() {
    return 'UserState.success(userData: $userData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSuccessImpl &&
            (identical(other.userData, userData) ||
                other.userData == userData));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userData);

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSuccessImplCopyWith<_$UserSuccessImpl> get copyWith =>
      __$$UserSuccessImplCopyWithImpl<_$UserSuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(TraineeModel userData) success,
    required TResult Function(TrainerModel userData) getTrainee,
    required TResult Function(String errorMessage) failure,
    required TResult Function() updateImageSuccess,
    required TResult Function(String message) updateImageFailure,
  }) {
    return success(userData);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(TraineeModel userData)? success,
    TResult? Function(TrainerModel userData)? getTrainee,
    TResult? Function(String errorMessage)? failure,
    TResult? Function()? updateImageSuccess,
    TResult? Function(String message)? updateImageFailure,
  }) {
    return success?.call(userData);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(TraineeModel userData)? success,
    TResult Function(TrainerModel userData)? getTrainee,
    TResult Function(String errorMessage)? failure,
    TResult Function()? updateImageSuccess,
    TResult Function(String message)? updateImageFailure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(userData);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UserInitial value) initial,
    required TResult Function(UserLoading value) loading,
    required TResult Function(UserSuccess value) success,
    required TResult Function(GetTrainee value) getTrainee,
    required TResult Function(UserFailure value) failure,
    required TResult Function(UpdateUserImageSuccess value) updateImageSuccess,
    required TResult Function(UpdateUserImageFailure value) updateImageFailure,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UserInitial value)? initial,
    TResult? Function(UserLoading value)? loading,
    TResult? Function(UserSuccess value)? success,
    TResult? Function(GetTrainee value)? getTrainee,
    TResult? Function(UserFailure value)? failure,
    TResult? Function(UpdateUserImageSuccess value)? updateImageSuccess,
    TResult? Function(UpdateUserImageFailure value)? updateImageFailure,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UserInitial value)? initial,
    TResult Function(UserLoading value)? loading,
    TResult Function(UserSuccess value)? success,
    TResult Function(GetTrainee value)? getTrainee,
    TResult Function(UserFailure value)? failure,
    TResult Function(UpdateUserImageSuccess value)? updateImageSuccess,
    TResult Function(UpdateUserImageFailure value)? updateImageFailure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class UserSuccess implements UserState {
  const factory UserSuccess(final TraineeModel userData) = _$UserSuccessImpl;

  TraineeModel get userData;

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserSuccessImplCopyWith<_$UserSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GetTraineeImplCopyWith<$Res> {
  factory _$$GetTraineeImplCopyWith(
          _$GetTraineeImpl value, $Res Function(_$GetTraineeImpl) then) =
      __$$GetTraineeImplCopyWithImpl<$Res>;
  @useResult
  $Res call({TrainerModel userData});
}

/// @nodoc
class __$$GetTraineeImplCopyWithImpl<$Res>
    extends _$UserStateCopyWithImpl<$Res, _$GetTraineeImpl>
    implements _$$GetTraineeImplCopyWith<$Res> {
  __$$GetTraineeImplCopyWithImpl(
      _$GetTraineeImpl _value, $Res Function(_$GetTraineeImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userData = null,
  }) {
    return _then(_$GetTraineeImpl(
      null == userData
          ? _value.userData
          : userData // ignore: cast_nullable_to_non_nullable
              as TrainerModel,
    ));
  }
}

/// @nodoc

class _$GetTraineeImpl implements GetTrainee {
  const _$GetTraineeImpl(this.userData);

  @override
  final TrainerModel userData;

  @override
  String toString() {
    return 'UserState.getTrainee(userData: $userData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GetTraineeImpl &&
            (identical(other.userData, userData) ||
                other.userData == userData));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userData);

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GetTraineeImplCopyWith<_$GetTraineeImpl> get copyWith =>
      __$$GetTraineeImplCopyWithImpl<_$GetTraineeImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(TraineeModel userData) success,
    required TResult Function(TrainerModel userData) getTrainee,
    required TResult Function(String errorMessage) failure,
    required TResult Function() updateImageSuccess,
    required TResult Function(String message) updateImageFailure,
  }) {
    return getTrainee(userData);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(TraineeModel userData)? success,
    TResult? Function(TrainerModel userData)? getTrainee,
    TResult? Function(String errorMessage)? failure,
    TResult? Function()? updateImageSuccess,
    TResult? Function(String message)? updateImageFailure,
  }) {
    return getTrainee?.call(userData);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(TraineeModel userData)? success,
    TResult Function(TrainerModel userData)? getTrainee,
    TResult Function(String errorMessage)? failure,
    TResult Function()? updateImageSuccess,
    TResult Function(String message)? updateImageFailure,
    required TResult orElse(),
  }) {
    if (getTrainee != null) {
      return getTrainee(userData);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UserInitial value) initial,
    required TResult Function(UserLoading value) loading,
    required TResult Function(UserSuccess value) success,
    required TResult Function(GetTrainee value) getTrainee,
    required TResult Function(UserFailure value) failure,
    required TResult Function(UpdateUserImageSuccess value) updateImageSuccess,
    required TResult Function(UpdateUserImageFailure value) updateImageFailure,
  }) {
    return getTrainee(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UserInitial value)? initial,
    TResult? Function(UserLoading value)? loading,
    TResult? Function(UserSuccess value)? success,
    TResult? Function(GetTrainee value)? getTrainee,
    TResult? Function(UserFailure value)? failure,
    TResult? Function(UpdateUserImageSuccess value)? updateImageSuccess,
    TResult? Function(UpdateUserImageFailure value)? updateImageFailure,
  }) {
    return getTrainee?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UserInitial value)? initial,
    TResult Function(UserLoading value)? loading,
    TResult Function(UserSuccess value)? success,
    TResult Function(GetTrainee value)? getTrainee,
    TResult Function(UserFailure value)? failure,
    TResult Function(UpdateUserImageSuccess value)? updateImageSuccess,
    TResult Function(UpdateUserImageFailure value)? updateImageFailure,
    required TResult orElse(),
  }) {
    if (getTrainee != null) {
      return getTrainee(this);
    }
    return orElse();
  }
}

abstract class GetTrainee implements UserState {
  const factory GetTrainee(final TrainerModel userData) = _$GetTraineeImpl;

  TrainerModel get userData;

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GetTraineeImplCopyWith<_$GetTraineeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UserFailureImplCopyWith<$Res> {
  factory _$$UserFailureImplCopyWith(
          _$UserFailureImpl value, $Res Function(_$UserFailureImpl) then) =
      __$$UserFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String errorMessage});
}

/// @nodoc
class __$$UserFailureImplCopyWithImpl<$Res>
    extends _$UserStateCopyWithImpl<$Res, _$UserFailureImpl>
    implements _$$UserFailureImplCopyWith<$Res> {
  __$$UserFailureImplCopyWithImpl(
      _$UserFailureImpl _value, $Res Function(_$UserFailureImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? errorMessage = null,
  }) {
    return _then(_$UserFailureImpl(
      null == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$UserFailureImpl implements UserFailure {
  const _$UserFailureImpl(this.errorMessage);

  @override
  final String errorMessage;

  @override
  String toString() {
    return 'UserState.failure(errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserFailureImpl &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, errorMessage);

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserFailureImplCopyWith<_$UserFailureImpl> get copyWith =>
      __$$UserFailureImplCopyWithImpl<_$UserFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(TraineeModel userData) success,
    required TResult Function(TrainerModel userData) getTrainee,
    required TResult Function(String errorMessage) failure,
    required TResult Function() updateImageSuccess,
    required TResult Function(String message) updateImageFailure,
  }) {
    return failure(errorMessage);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(TraineeModel userData)? success,
    TResult? Function(TrainerModel userData)? getTrainee,
    TResult? Function(String errorMessage)? failure,
    TResult? Function()? updateImageSuccess,
    TResult? Function(String message)? updateImageFailure,
  }) {
    return failure?.call(errorMessage);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(TraineeModel userData)? success,
    TResult Function(TrainerModel userData)? getTrainee,
    TResult Function(String errorMessage)? failure,
    TResult Function()? updateImageSuccess,
    TResult Function(String message)? updateImageFailure,
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
    required TResult Function(UserInitial value) initial,
    required TResult Function(UserLoading value) loading,
    required TResult Function(UserSuccess value) success,
    required TResult Function(GetTrainee value) getTrainee,
    required TResult Function(UserFailure value) failure,
    required TResult Function(UpdateUserImageSuccess value) updateImageSuccess,
    required TResult Function(UpdateUserImageFailure value) updateImageFailure,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UserInitial value)? initial,
    TResult? Function(UserLoading value)? loading,
    TResult? Function(UserSuccess value)? success,
    TResult? Function(GetTrainee value)? getTrainee,
    TResult? Function(UserFailure value)? failure,
    TResult? Function(UpdateUserImageSuccess value)? updateImageSuccess,
    TResult? Function(UpdateUserImageFailure value)? updateImageFailure,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UserInitial value)? initial,
    TResult Function(UserLoading value)? loading,
    TResult Function(UserSuccess value)? success,
    TResult Function(GetTrainee value)? getTrainee,
    TResult Function(UserFailure value)? failure,
    TResult Function(UpdateUserImageSuccess value)? updateImageSuccess,
    TResult Function(UpdateUserImageFailure value)? updateImageFailure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class UserFailure implements UserState {
  const factory UserFailure(final String errorMessage) = _$UserFailureImpl;

  String get errorMessage;

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserFailureImplCopyWith<_$UserFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UpdateUserImageSuccessImplCopyWith<$Res> {
  factory _$$UpdateUserImageSuccessImplCopyWith(
          _$UpdateUserImageSuccessImpl value,
          $Res Function(_$UpdateUserImageSuccessImpl) then) =
      __$$UpdateUserImageSuccessImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$UpdateUserImageSuccessImplCopyWithImpl<$Res>
    extends _$UserStateCopyWithImpl<$Res, _$UpdateUserImageSuccessImpl>
    implements _$$UpdateUserImageSuccessImplCopyWith<$Res> {
  __$$UpdateUserImageSuccessImplCopyWithImpl(
      _$UpdateUserImageSuccessImpl _value,
      $Res Function(_$UpdateUserImageSuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$UpdateUserImageSuccessImpl implements UpdateUserImageSuccess {
  const _$UpdateUserImageSuccessImpl();

  @override
  String toString() {
    return 'UserState.updateImageSuccess()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateUserImageSuccessImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(TraineeModel userData) success,
    required TResult Function(TrainerModel userData) getTrainee,
    required TResult Function(String errorMessage) failure,
    required TResult Function() updateImageSuccess,
    required TResult Function(String message) updateImageFailure,
  }) {
    return updateImageSuccess();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(TraineeModel userData)? success,
    TResult? Function(TrainerModel userData)? getTrainee,
    TResult? Function(String errorMessage)? failure,
    TResult? Function()? updateImageSuccess,
    TResult? Function(String message)? updateImageFailure,
  }) {
    return updateImageSuccess?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(TraineeModel userData)? success,
    TResult Function(TrainerModel userData)? getTrainee,
    TResult Function(String errorMessage)? failure,
    TResult Function()? updateImageSuccess,
    TResult Function(String message)? updateImageFailure,
    required TResult orElse(),
  }) {
    if (updateImageSuccess != null) {
      return updateImageSuccess();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UserInitial value) initial,
    required TResult Function(UserLoading value) loading,
    required TResult Function(UserSuccess value) success,
    required TResult Function(GetTrainee value) getTrainee,
    required TResult Function(UserFailure value) failure,
    required TResult Function(UpdateUserImageSuccess value) updateImageSuccess,
    required TResult Function(UpdateUserImageFailure value) updateImageFailure,
  }) {
    return updateImageSuccess(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UserInitial value)? initial,
    TResult? Function(UserLoading value)? loading,
    TResult? Function(UserSuccess value)? success,
    TResult? Function(GetTrainee value)? getTrainee,
    TResult? Function(UserFailure value)? failure,
    TResult? Function(UpdateUserImageSuccess value)? updateImageSuccess,
    TResult? Function(UpdateUserImageFailure value)? updateImageFailure,
  }) {
    return updateImageSuccess?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UserInitial value)? initial,
    TResult Function(UserLoading value)? loading,
    TResult Function(UserSuccess value)? success,
    TResult Function(GetTrainee value)? getTrainee,
    TResult Function(UserFailure value)? failure,
    TResult Function(UpdateUserImageSuccess value)? updateImageSuccess,
    TResult Function(UpdateUserImageFailure value)? updateImageFailure,
    required TResult orElse(),
  }) {
    if (updateImageSuccess != null) {
      return updateImageSuccess(this);
    }
    return orElse();
  }
}

abstract class UpdateUserImageSuccess implements UserState {
  const factory UpdateUserImageSuccess() = _$UpdateUserImageSuccessImpl;
}

/// @nodoc
abstract class _$$UpdateUserImageFailureImplCopyWith<$Res> {
  factory _$$UpdateUserImageFailureImplCopyWith(
          _$UpdateUserImageFailureImpl value,
          $Res Function(_$UpdateUserImageFailureImpl) then) =
      __$$UpdateUserImageFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$UpdateUserImageFailureImplCopyWithImpl<$Res>
    extends _$UserStateCopyWithImpl<$Res, _$UpdateUserImageFailureImpl>
    implements _$$UpdateUserImageFailureImplCopyWith<$Res> {
  __$$UpdateUserImageFailureImplCopyWithImpl(
      _$UpdateUserImageFailureImpl _value,
      $Res Function(_$UpdateUserImageFailureImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$UpdateUserImageFailureImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$UpdateUserImageFailureImpl implements UpdateUserImageFailure {
  const _$UpdateUserImageFailureImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'UserState.updateImageFailure(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateUserImageFailureImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateUserImageFailureImplCopyWith<_$UpdateUserImageFailureImpl>
      get copyWith => __$$UpdateUserImageFailureImplCopyWithImpl<
          _$UpdateUserImageFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(TraineeModel userData) success,
    required TResult Function(TrainerModel userData) getTrainee,
    required TResult Function(String errorMessage) failure,
    required TResult Function() updateImageSuccess,
    required TResult Function(String message) updateImageFailure,
  }) {
    return updateImageFailure(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(TraineeModel userData)? success,
    TResult? Function(TrainerModel userData)? getTrainee,
    TResult? Function(String errorMessage)? failure,
    TResult? Function()? updateImageSuccess,
    TResult? Function(String message)? updateImageFailure,
  }) {
    return updateImageFailure?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(TraineeModel userData)? success,
    TResult Function(TrainerModel userData)? getTrainee,
    TResult Function(String errorMessage)? failure,
    TResult Function()? updateImageSuccess,
    TResult Function(String message)? updateImageFailure,
    required TResult orElse(),
  }) {
    if (updateImageFailure != null) {
      return updateImageFailure(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(UserInitial value) initial,
    required TResult Function(UserLoading value) loading,
    required TResult Function(UserSuccess value) success,
    required TResult Function(GetTrainee value) getTrainee,
    required TResult Function(UserFailure value) failure,
    required TResult Function(UpdateUserImageSuccess value) updateImageSuccess,
    required TResult Function(UpdateUserImageFailure value) updateImageFailure,
  }) {
    return updateImageFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(UserInitial value)? initial,
    TResult? Function(UserLoading value)? loading,
    TResult? Function(UserSuccess value)? success,
    TResult? Function(GetTrainee value)? getTrainee,
    TResult? Function(UserFailure value)? failure,
    TResult? Function(UpdateUserImageSuccess value)? updateImageSuccess,
    TResult? Function(UpdateUserImageFailure value)? updateImageFailure,
  }) {
    return updateImageFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(UserInitial value)? initial,
    TResult Function(UserLoading value)? loading,
    TResult Function(UserSuccess value)? success,
    TResult Function(GetTrainee value)? getTrainee,
    TResult Function(UserFailure value)? failure,
    TResult Function(UpdateUserImageSuccess value)? updateImageSuccess,
    TResult Function(UpdateUserImageFailure value)? updateImageFailure,
    required TResult orElse(),
  }) {
    if (updateImageFailure != null) {
      return updateImageFailure(this);
    }
    return orElse();
  }
}

abstract class UpdateUserImageFailure implements UserState {
  const factory UpdateUserImageFailure(final String message) =
      _$UpdateUserImageFailureImpl;

  String get message;

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateUserImageFailureImplCopyWith<_$UpdateUserImageFailureImpl>
      get copyWith => throw _privateConstructorUsedError;
}
