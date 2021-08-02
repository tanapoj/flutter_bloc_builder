import 'package:flutter/material.dart';
import 'package:flutter_live_data/flutter_live_data.dart';

import 'widgets.dart' as w;
import 'bloc_builder_ioc.dart';

/// BLoC Builder watch
Widget $watch<T>(
  LiveData<T> liveData, {
  Symbol id,
  @required Widget Function(BuildContext context, T value) builder,
}) {
  assert(
    liveData != null,
    '\$watch on null, If you create View and run it before create ViewModel, maybe hot-reload fail to bind LiveData from ViewModel --> try run app again',
  );
  return StreamBuilder(
    stream: liveData.stream$(id),
    initialData: liveData.initialValue,
    builder: (BuildContext context, snapshot) {
      var value = liveData.value ?? snapshot.data ?? liveData.initialValue;
      //assert(value is T);
      return builder(context, value);
    },
  );
}

/// BLoC Builder bool
Widget $bool<T extends bool>(
  LiveData<T> liveData, {
  Symbol id,
  bool Function(T) predicate,
  Widget Function(BuildContext context, T value) $true,
  Widget Function(BuildContext context, T value) $false,
}) {
  assert(
    liveData != null,
    '\bool on null, If you create View and run it before create ViewModel, maybe hot-reload fail to bind LiveData from ViewModel --> try run app again',
  );

  $true ??= (_, __) => w.EmptyView();
  $false ??= (_, __) => w.EmptyView();

  return StreamBuilder(
    stream: liveData.stream$(id),
    initialData: liveData.initialValue,
    builder: (BuildContext context, snapshot) {
      var value = liveData.value ?? snapshot.data ?? liveData.initialValue;
      assert(value is T);
      if (predicate == null && value) {
        return $true(context, value);
      }
      if (predicate != null && predicate(value)) {
        return $true(context, value);
      }
      if ($else != null) {
        return $false(context, value);
      }
      return w.EmptyView();
    },
  );
}

/// BLoC Builder switch
Widget $switch<T>(
  LiveData<T> liveData, {
  Symbol id,
  @required Map<T, Widget Function(BuildContext context, T value)> builders,
  Widget Function(BuildContext context, T value) $default,
}) {
  assert(
    liveData != null,
    '\$switch on null, If you create View and run it before create ViewModel, maybe hot-reload fail to bind LiveData from ViewModel --> try run app again',
  );
  return StreamBuilder(
    stream: liveData.stream$(id),
    initialData: liveData.initialValue,
    builder: (BuildContext context, snapshot) {
      var value = liveData.value ?? snapshot.data ?? liveData.initialValue;

      if (builders.containsKey(value)) {
        return builders[value](context, value);
      } else if ($default != null) {
        return $default(context, value);
      }
      return w.EmptyView();
    },
  );
}

/// BLoC Builder if
Widget $if<T>(
  LiveData<T> liveData, {
  Symbol id,
  @required bool Function(T) condition,
  @required Widget Function(BuildContext context, T value) builder,
  Widget Function(BuildContext context, T value) $else,
}) {
  assert(
    liveData != null,
    '\nif on null, If you create View and run it before create ViewModel, maybe hot-reload fail to bind LiveData from ViewModel --> try run app again',
  );

  $else ??= (_, __) => w.EmptyView();

  return StreamBuilder(
    stream: liveData.stream$(id),
    initialData: liveData.initialValue,
    builder: (BuildContext context, snapshot) {
      var value = liveData.value ?? snapshot.data ?? liveData.initialValue;
      if (condition(value)) {
        return builder(context, value);
      } else {
        return $else(context, value);
      }
    },
  );
}

/// BLoC Builder else
Widget $else<T>(
  LiveData<T> liveData, {
  Symbol id,
  @required bool Function(T) condition,
  @required Widget Function(BuildContext context, T value) builder,
}) {
  assert(
    liveData != null,
    '\nelse on null, If you create View and run it before create ViewModel, maybe hot-reload fail to bind LiveData from ViewModel --> try run app again',
  );
  return $if(
    liveData,
    condition: condition,
    builder: (_, __) => w.EmptyView(),
    $else: builder,
  );
}

/// BLoC Builder for
Widget $for<T>(
  LiveData<List<T>> liveData, {
  Symbol id,
  @required Widget Function(BuildContext context, T value, int index) builder,
  Widget Function(BuildContext context, bool isNull) $empty,
  Widget Function(BuildContext context, List<T> list) adapter,
}) {
  assert(
    liveData != null,
    '\nfor on null, If you create View and run it before create ViewModel, maybe hot-reload fail to bind LiveData from ViewModel --> try run app again',
  );
  return $watch<List<T>>(liveData, builder: (context, List<T> list) {
    adapter ??= (BuildContext context, List<T> list) {
      return ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) => builder(context, list[index], index),
      );
    };

    if ($empty != null && list == null) {
      return $empty(context, true);
    }
    if ($empty != null && list.isEmpty) {
      return $empty(context, false);
    }
    return adapter(context, list);
  });
}

/// BLoC Builder guard
BLoCBuilderIoC $guard<T>(
  LiveData<T> liveData, {
  Symbol id,
  bool Function(T) resolve,
  bool Function(T) reject,
  Widget Function(BuildContext context, T value) $elseReturn,
}) {
  return BLoCBuilderIoC<T>().$guard(
    liveData,
    id: id,
    resolve: resolve,
    reject: reject,
    $elseReturn: $elseReturn,
  );
}
