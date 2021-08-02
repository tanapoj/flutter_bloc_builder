import 'package:flutter/material.dart';
import 'package:flutter_live_data/flutter_live_data.dart';

import 'bloc_builder_ioc.dart';
import 'bloc_livedata.dart' as lv;

/// BLoC Builder watch
Widget $watch<T>(
  Stream<T> stream, {
  Symbol id,
  @required Widget Function(BuildContext context, T value) builder,
}) =>
    lv.$watch(LiveData<T>.fromStream(stream), id: id, builder: builder);

/// BLoC Builder bool
Widget $bool<T extends bool>(
  Stream<T> stream, {
  Symbol id,
  bool Function(T) predicate,
  Widget Function(BuildContext context, T value) $true,
  Widget Function(BuildContext context, T value) $false,
}) =>
    lv.$bool(LiveData<T>.fromStream(stream),
        id: id, predicate: predicate, $true: $true, $false: $false);

/// BLoC Builder switch
Widget $switch<T>(
  Stream<T> stream, {
  Symbol id,
  @required Map<T, Widget Function(BuildContext context, T value)> builders,
  Widget Function(BuildContext context, T value) $default,
}) =>
    lv.$switch(LiveData<T>.fromStream(stream), id: id, builders: builders);

/// BLoC Builder if
Widget $if<T>(
  Stream<T> stream, {
  Symbol id,
  @required bool Function(T) condition,
  @required Widget Function(BuildContext context, T value) builder,
  Widget Function(BuildContext context, T value) $else,
}) =>
    lv.$if(LiveData<T>.fromStream(stream), id: id, condition: condition, builder: builder);

/// BLoC Builder else
Widget $else<T>(
  Stream<T> stream, {
  Symbol id,
  @required bool Function(T) condition,
  @required Widget Function(BuildContext context, T value) builder,
}) =>
    lv.$else(LiveData<T>.fromStream(stream), id: id, condition: condition, builder: builder);

/// BLoC Builder for
Widget $for<T>(
  Stream<List<T>> stream, {
  Symbol id,
  @required Widget Function(BuildContext context, T value, int index) builder,
  Widget Function(BuildContext context, bool isNull) $empty,
  Widget Function(BuildContext context, List<T> list) adapter,
}) =>
    lv.$for(LiveData<List<T>>.fromStream(stream),
        id: id, builder: builder, $empty: $empty, adapter: adapter);

/// BLoC Builder guard
BLoCBuilderIoC $guard<T>(
  Stream<T> stream, {
  Symbol id,
  bool Function(T) resolve,
  bool Function(T) reject,
  Widget Function(BuildContext context, T value) $elseReturn,
}) =>
    lv.$guard(LiveData<T>.fromStream(stream),
        id: id, resolve: resolve, reject: reject, $elseReturn: $elseReturn);
