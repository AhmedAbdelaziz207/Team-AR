// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'confirm_subscription_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ConfirmSubscriptionState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(RegisterResponse data) success,
    required TResult Function(ApiErrorModel errorModel) failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(RegisterResponse data)? success,
    TResult? Function(ApiErrorModel errorModel)? failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(RegisterResponse data)? success,
    TResult Function(ApiErrorModel errorModel)? failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(SubscriptionLoading value) loading,
    required TResult Function(SubscriptionSuccess value) success,
    required TResult Function(SubscriptionFailure value) failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(SubscriptionLoading value)? loading,
    TResult? Function(SubscriptionSuccess value)? success,
    TResult? Function(SubscriptionFailure value)? failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(SubscriptionLoading value)? loading,
    TResult Function(SubscriptionSuccess value)? success,
    TResult Function(SubscriptionFailure value)? failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConfirmSubscriptionStateCopyWith<$Res> {
  factory $ConfirmSubscriptionStateCopyWith(ConfirmSubscriptionState value,
          $Res Function(ConfirmSubscriptionState) then) =
      _$ConfirmSubscriptionStateCopyWithImpl<$Res, ConfirmSubscriptionState>;
}

/// @nodoc
class _$ConfirmSubscriptionStateCopyWithImpl<$Res,
        $Val extends ConfirmSubscriptionState>
    implements $ConfirmSubscriptionStateCopyWith<$Res> {
  _$ConfirmSubscriptionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConfirmSubscriptionState
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
    extends _$ConfirmSubscriptionStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConfirmSubscriptionState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'ConfirmSubscriptionState.initial()';
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
    required TResult Function(RegisterResponse data) success,
    required TResult Function(ApiErrorModel errorModel) failure,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(RegisterResponse data)? success,
    TResult? Function(ApiErrorModel errorModel)? failure,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(RegisterResponse data)? success,
    TResult Function(ApiErrorModel errorModel)? failure,
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
    required TResult Function(SubscriptionLoading value) loading,
    required TResult Function(SubscriptionSuccess value) success,
    required TResult Function(SubscriptionFailure value) failure,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(SubscriptionLoading value)? loading,
    TResult? Function(SubscriptionSuccess value)? success,
    TResult? Function(SubscriptionFailure value)? failure,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(SubscriptionLoading value)? loading,
    TResult Function(SubscriptionSuccess value)? success,
    TResult Function(SubscriptionFailure value)? failure,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements ConfirmSubscriptionState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$SubscriptionLoadingImplCopyWith<$Res> {
  factory _$$SubscriptionLoadingImplCopyWith(_$SubscriptionLoadingImpl value,
          $Res Function(_$SubscriptionLoadingImpl) then) =
      __$$SubscriptionLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SubscriptionLoadingImplCopyWithImpl<$Res>
    extends _$ConfirmSubscriptionStateCopyWithImpl<$Res,
        _$SubscriptionLoadingImpl>
    implements _$$SubscriptionLoadingImplCopyWith<$Res> {
  __$$SubscriptionLoadingImplCopyWithImpl(_$SubscriptionLoadingImpl _value,
      $Res Function(_$SubscriptionLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConfirmSubscriptionState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SubscriptionLoadingImpl implements SubscriptionLoading {
  const _$SubscriptionLoadingImpl();

  @override
  String toString() {
    return 'ConfirmSubscriptionState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(RegisterResponse data) success,
    required TResult Function(ApiErrorModel errorModel) failure,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(RegisterResponse data)? success,
    TResult? Function(ApiErrorModel errorModel)? failure,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(RegisterResponse data)? success,
    TResult Function(ApiErrorModel errorModel)? failure,
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
    required TResult Function(SubscriptionLoading value) loading,
    required TResult Function(SubscriptionSuccess value) success,
    required TResult Function(SubscriptionFailure value) failure,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(SubscriptionLoading value)? loading,
    TResult? Function(SubscriptionSuccess value)? success,
    TResult? Function(SubscriptionFailure value)? failure,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(SubscriptionLoading value)? loading,
    TResult Function(SubscriptionSuccess value)? success,
    TResult Function(SubscriptionFailure value)? failure,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class SubscriptionLoading implements ConfirmSubscriptionState {
  const factory SubscriptionLoading() = _$SubscriptionLoadingImpl;
}

/// @nodoc
abstract class _$$SubscriptionSuccessImplCopyWith<$Res> {
  factory _$$SubscriptionSuccessImplCopyWith(_$SubscriptionSuccessImpl value,
          $Res Function(_$SubscriptionSuccessImpl) then) =
      __$$SubscriptionSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({RegisterResponse data});
}

/// @nodoc
class __$$SubscriptionSuccessImplCopyWithImpl<$Res>
    extends _$ConfirmSubscriptionStateCopyWithImpl<$Res,
        _$SubscriptionSuccessImpl>
    implements _$$SubscriptionSuccessImplCopyWith<$Res> {
  __$$SubscriptionSuccessImplCopyWithImpl(_$SubscriptionSuccessImpl _value,
      $Res Function(_$SubscriptionSuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConfirmSubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$SubscriptionSuccessImpl(
      null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as RegisterResponse,
    ));
  }
}

/// @nodoc

class _$SubscriptionSuccessImpl implements SubscriptionSuccess {
  const _$SubscriptionSuccessImpl(this.data);

  @override
  final RegisterResponse data;

  @override
  String toString() {
    return 'ConfirmSubscriptionState.success(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionSuccessImpl &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data);

  /// Create a copy of ConfirmSubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionSuccessImplCopyWith<_$SubscriptionSuccessImpl> get copyWith =>
      __$$SubscriptionSuccessImplCopyWithImpl<_$SubscriptionSuccessImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(RegisterResponse data) success,
    required TResult Function(ApiErrorModel errorModel) failure,
  }) {
    return success(data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(RegisterResponse data)? success,
    TResult? Function(ApiErrorModel errorModel)? failure,
  }) {
    return success?.call(data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(RegisterResponse data)? success,
    TResult Function(ApiErrorModel errorModel)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(SubscriptionLoading value) loading,
    required TResult Function(SubscriptionSuccess value) success,
    required TResult Function(SubscriptionFailure value) failure,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(SubscriptionLoading value)? loading,
    TResult? Function(SubscriptionSuccess value)? success,
    TResult? Function(SubscriptionFailure value)? failure,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(SubscriptionLoading value)? loading,
    TResult Function(SubscriptionSuccess value)? success,
    TResult Function(SubscriptionFailure value)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class SubscriptionSuccess implements ConfirmSubscriptionState {
  const factory SubscriptionSuccess(final RegisterResponse data) =
      _$SubscriptionSuccessImpl;

  RegisterResponse get data;

  /// Create a copy of ConfirmSubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionSuccessImplCopyWith<_$SubscriptionSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SubscriptionFailureImplCopyWith<$Res> {
  factory _$$SubscriptionFailureImplCopyWith(_$SubscriptionFailureImpl value,
          $Res Function(_$SubscriptionFailureImpl) then) =
      __$$SubscriptionFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ApiErrorModel errorModel});
}

/// @nodoc
class __$$SubscriptionFailureImplCopyWithImpl<$Res>
    extends _$ConfirmSubscriptionStateCopyWithImpl<$Res,
        _$SubscriptionFailureImpl>
    implements _$$SubscriptionFailureImplCopyWith<$Res> {
  __$$SubscriptionFailureImplCopyWithImpl(_$SubscriptionFailureImpl _value,
      $Res Function(_$SubscriptionFailureImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConfirmSubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? errorModel = null,
  }) {
    return _then(_$SubscriptionFailureImpl(
      null == errorModel
          ? _value.errorModel
          : errorModel // ignore: cast_nullable_to_non_nullable
              as ApiErrorModel,
    ));
  }
}

/// @nodoc

class _$SubscriptionFailureImpl implements SubscriptionFailure {
  const _$SubscriptionFailureImpl(this.errorModel);

  @override
  final ApiErrorModel errorModel;

  @override
  String toString() {
    return 'ConfirmSubscriptionState.failure(errorModel: $errorModel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionFailureImpl &&
            (identical(other.errorModel, errorModel) ||
                other.errorModel == errorModel));
  }

  @override
  int get hashCode => Object.hash(runtimeType, errorModel);

  /// Create a copy of ConfirmSubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionFailureImplCopyWith<_$SubscriptionFailureImpl> get copyWith =>
      __$$SubscriptionFailureImplCopyWithImpl<_$SubscriptionFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(RegisterResponse data) success,
    required TResult Function(ApiErrorModel errorModel) failure,
  }) {
    return failure(errorModel);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(RegisterResponse data)? success,
    TResult? Function(ApiErrorModel errorModel)? failure,
  }) {
    return failure?.call(errorModel);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(RegisterResponse data)? success,
    TResult Function(ApiErrorModel errorModel)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(errorModel);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(SubscriptionLoading value) loading,
    required TResult Function(SubscriptionSuccess value) success,
    required TResult Function(SubscriptionFailure value) failure,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(SubscriptionLoading value)? loading,
    TResult? Function(SubscriptionSuccess value)? success,
    TResult? Function(SubscriptionFailure value)? failure,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(SubscriptionLoading value)? loading,
    TResult Function(SubscriptionSuccess value)? success,
    TResult Function(SubscriptionFailure value)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class SubscriptionFailure implements ConfirmSubscriptionState {
  const factory SubscriptionFailure(final ApiErrorModel errorModel) =
      _$SubscriptionFailureImpl;

  ApiErrorModel get errorModel;

  /// Create a copy of ConfirmSubscriptionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionFailureImplCopyWith<_$SubscriptionFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
