// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainees_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TraineeState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<TraineeModel> trainees) success,
    required TResult Function(String errorMessage) failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<TraineeModel> trainees)? success,
    TResult? Function(String errorMessage)? failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<TraineeModel> trainees)? success,
    TResult Function(String errorMessage)? failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(TraineeLoading value) loading,
    required TResult Function(TraineeSuccess value) success,
    required TResult Function(TraineeFailure value) failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(TraineeLoading value)? loading,
    TResult? Function(TraineeSuccess value)? success,
    TResult? Function(TraineeFailure value)? failure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(TraineeLoading value)? loading,
    TResult Function(TraineeSuccess value)? success,
    TResult Function(TraineeFailure value)? failure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TraineeStateCopyWith<$Res> {
  factory $TraineeStateCopyWith(
          TraineeState value, $Res Function(TraineeState) then) =
      _$TraineeStateCopyWithImpl<$Res, TraineeState>;
}

/// @nodoc
class _$TraineeStateCopyWithImpl<$Res, $Val extends TraineeState>
    implements $TraineeStateCopyWith<$Res> {
  _$TraineeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TraineeState
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
    extends _$TraineeStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of TraineeState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'TraineeState.initial()';
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
    required TResult Function(List<TraineeModel> trainees) success,
    required TResult Function(String errorMessage) failure,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<TraineeModel> trainees)? success,
    TResult? Function(String errorMessage)? failure,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<TraineeModel> trainees)? success,
    TResult Function(String errorMessage)? failure,
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
    required TResult Function(TraineeLoading value) loading,
    required TResult Function(TraineeSuccess value) success,
    required TResult Function(TraineeFailure value) failure,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(TraineeLoading value)? loading,
    TResult? Function(TraineeSuccess value)? success,
    TResult? Function(TraineeFailure value)? failure,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(TraineeLoading value)? loading,
    TResult Function(TraineeSuccess value)? success,
    TResult Function(TraineeFailure value)? failure,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements TraineeState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$TraineeLoadingImplCopyWith<$Res> {
  factory _$$TraineeLoadingImplCopyWith(_$TraineeLoadingImpl value,
          $Res Function(_$TraineeLoadingImpl) then) =
      __$$TraineeLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$TraineeLoadingImplCopyWithImpl<$Res>
    extends _$TraineeStateCopyWithImpl<$Res, _$TraineeLoadingImpl>
    implements _$$TraineeLoadingImplCopyWith<$Res> {
  __$$TraineeLoadingImplCopyWithImpl(
      _$TraineeLoadingImpl _value, $Res Function(_$TraineeLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of TraineeState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$TraineeLoadingImpl implements TraineeLoading {
  const _$TraineeLoadingImpl();

  @override
  String toString() {
    return 'TraineeState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$TraineeLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<TraineeModel> trainees) success,
    required TResult Function(String errorMessage) failure,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<TraineeModel> trainees)? success,
    TResult? Function(String errorMessage)? failure,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<TraineeModel> trainees)? success,
    TResult Function(String errorMessage)? failure,
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
    required TResult Function(TraineeLoading value) loading,
    required TResult Function(TraineeSuccess value) success,
    required TResult Function(TraineeFailure value) failure,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(TraineeLoading value)? loading,
    TResult? Function(TraineeSuccess value)? success,
    TResult? Function(TraineeFailure value)? failure,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(TraineeLoading value)? loading,
    TResult Function(TraineeSuccess value)? success,
    TResult Function(TraineeFailure value)? failure,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class TraineeLoading implements TraineeState {
  const factory TraineeLoading() = _$TraineeLoadingImpl;
}

/// @nodoc
abstract class _$$TraineeSuccessImplCopyWith<$Res> {
  factory _$$TraineeSuccessImplCopyWith(_$TraineeSuccessImpl value,
          $Res Function(_$TraineeSuccessImpl) then) =
      __$$TraineeSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<TraineeModel> trainees});
}

/// @nodoc
class __$$TraineeSuccessImplCopyWithImpl<$Res>
    extends _$TraineeStateCopyWithImpl<$Res, _$TraineeSuccessImpl>
    implements _$$TraineeSuccessImplCopyWith<$Res> {
  __$$TraineeSuccessImplCopyWithImpl(
      _$TraineeSuccessImpl _value, $Res Function(_$TraineeSuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of TraineeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trainees = null,
  }) {
    return _then(_$TraineeSuccessImpl(
      null == trainees
          ? _value._trainees
          : trainees // ignore: cast_nullable_to_non_nullable
              as List<TraineeModel>,
    ));
  }
}

/// @nodoc

class _$TraineeSuccessImpl implements TraineeSuccess {
  const _$TraineeSuccessImpl(final List<TraineeModel> trainees)
      : _trainees = trainees;

  final List<TraineeModel> _trainees;
  @override
  List<TraineeModel> get trainees {
    if (_trainees is EqualUnmodifiableListView) return _trainees;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trainees);
  }

  @override
  String toString() {
    return 'TraineeState.success(trainees: $trainees)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TraineeSuccessImpl &&
            const DeepCollectionEquality().equals(other._trainees, _trainees));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_trainees));

  /// Create a copy of TraineeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TraineeSuccessImplCopyWith<_$TraineeSuccessImpl> get copyWith =>
      __$$TraineeSuccessImplCopyWithImpl<_$TraineeSuccessImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<TraineeModel> trainees) success,
    required TResult Function(String errorMessage) failure,
  }) {
    return success(trainees);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<TraineeModel> trainees)? success,
    TResult? Function(String errorMessage)? failure,
  }) {
    return success?.call(trainees);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<TraineeModel> trainees)? success,
    TResult Function(String errorMessage)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(trainees);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(TraineeLoading value) loading,
    required TResult Function(TraineeSuccess value) success,
    required TResult Function(TraineeFailure value) failure,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(TraineeLoading value)? loading,
    TResult? Function(TraineeSuccess value)? success,
    TResult? Function(TraineeFailure value)? failure,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(TraineeLoading value)? loading,
    TResult Function(TraineeSuccess value)? success,
    TResult Function(TraineeFailure value)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class TraineeSuccess implements TraineeState {
  const factory TraineeSuccess(final List<TraineeModel> trainees) =
      _$TraineeSuccessImpl;

  List<TraineeModel> get trainees;

  /// Create a copy of TraineeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TraineeSuccessImplCopyWith<_$TraineeSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TraineeFailureImplCopyWith<$Res> {
  factory _$$TraineeFailureImplCopyWith(_$TraineeFailureImpl value,
          $Res Function(_$TraineeFailureImpl) then) =
      __$$TraineeFailureImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String errorMessage});
}

/// @nodoc
class __$$TraineeFailureImplCopyWithImpl<$Res>
    extends _$TraineeStateCopyWithImpl<$Res, _$TraineeFailureImpl>
    implements _$$TraineeFailureImplCopyWith<$Res> {
  __$$TraineeFailureImplCopyWithImpl(
      _$TraineeFailureImpl _value, $Res Function(_$TraineeFailureImpl) _then)
      : super(_value, _then);

  /// Create a copy of TraineeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? errorMessage = null,
  }) {
    return _then(_$TraineeFailureImpl(
      null == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$TraineeFailureImpl implements TraineeFailure {
  const _$TraineeFailureImpl(this.errorMessage);

  @override
  final String errorMessage;

  @override
  String toString() {
    return 'TraineeState.failure(errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TraineeFailureImpl &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, errorMessage);

  /// Create a copy of TraineeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TraineeFailureImplCopyWith<_$TraineeFailureImpl> get copyWith =>
      __$$TraineeFailureImplCopyWithImpl<_$TraineeFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<TraineeModel> trainees) success,
    required TResult Function(String errorMessage) failure,
  }) {
    return failure(errorMessage);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<TraineeModel> trainees)? success,
    TResult? Function(String errorMessage)? failure,
  }) {
    return failure?.call(errorMessage);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<TraineeModel> trainees)? success,
    TResult Function(String errorMessage)? failure,
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
    required TResult Function(TraineeLoading value) loading,
    required TResult Function(TraineeSuccess value) success,
    required TResult Function(TraineeFailure value) failure,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(TraineeLoading value)? loading,
    TResult? Function(TraineeSuccess value)? success,
    TResult? Function(TraineeFailure value)? failure,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(TraineeLoading value)? loading,
    TResult Function(TraineeSuccess value)? success,
    TResult Function(TraineeFailure value)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class TraineeFailure implements TraineeState {
  const factory TraineeFailure(final String errorMessage) =
      _$TraineeFailureImpl;

  String get errorMessage;

  /// Create a copy of TraineeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TraineeFailureImplCopyWith<_$TraineeFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
