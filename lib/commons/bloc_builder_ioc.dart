import 'package:flutter/material.dart';
import 'package:flutter_live_data/flutter_live_data.dart';

import 'widgets.dart' as w;
import 'bloc_livedata.dart' as bloc;

class BLoCBuilderIoC<E> extends StatelessWidget {
  final LiveData<E> liveData;
  final Symbol id;
  final bool Function(E) predicate;
  final Widget Function(BuildContext context, E value) $elseReturn;
  final Widget Function(Widget widget) wrapperWidget;

  const BLoCBuilderIoC({
    Key key,
    this.liveData,
    this.id,
    this.predicate,
    this.$elseReturn,
    this.wrapperWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => _build(() => w.EmptyView());

  BLoCBuilderIoC $guard<T>(
    LiveData<T> liveData, {
    Symbol id,
    bool Function(T) resolve,
    bool Function(T) reject,
    Widget Function(BuildContext context, T value) $elseReturn,
  }) {
    resolve ??= (reject != null ? (T t) => !reject(t) : null) ??
        (T t) {
          if (t == null) return false;
          if (t is bool) return t;
          if (t is List) return t.isNotEmpty;
          return true;
        };

    $elseReturn ??= (_, __) => w.EmptyView();

    var liveData2 = liveData;
    var id2 = id;
    var predicate2 = resolve;
    var $elseReturn2 = $elseReturn;

    if (this.liveData == null) {
      return BLoCBuilderIoC(
        liveData: liveData2,
        id: id2,
        predicate: (v) => predicate2(v),
        $elseReturn: $elseReturn2,
      );
    }

    var liveData1 = this.liveData;
    var id1 = this.id;
    var predicate1 = this.predicate;
    var $elseReturn1 = this.$elseReturn;

    return BLoCBuilderIoC(
      liveData: liveData2,
      id: id2,
      predicate: (v) => predicate2(v),
      $elseReturn: $elseReturn2,
      wrapperWidget: (Widget widget) {
        return StreamBuilder(
          stream: liveData1.stream$(id1),
          initialData: liveData1.initialValue,
          builder: (BuildContext context, snapshot) {
            var value = liveData1.value ?? snapshot.data ?? liveData1.initialValue;
            if (!predicate1(value)) {
              return $elseReturn1(context, value);
            }
            return widget;
          },
        );
      },
    );
  }

  Widget _build(Widget Function() $render) {
    var wrapper = wrapperWidget ?? (w) => w;
    return wrapper(
      StreamBuilder(
        stream: liveData.stream$(id),
        initialData: liveData.initialValue,
        builder: (BuildContext context, snapshot) {
          var value = liveData.value ?? snapshot.data ?? liveData.initialValue;
          if (!predicate(value)) {
            return $elseReturn(context, value);
          }
          return $render();
        },
      ),
    );
  }

  Widget $watch<T>(
    LiveData<T> $vm, {
    Symbol id,
    @required Widget Function(BuildContext context, T value) builder,
  }) {
    return _build(() => bloc.$watch<T>($vm, id: id, builder: builder));
  }

  Widget $bool<T extends bool>(
    LiveData<T> $vm, {
    Symbol id,
    bool Function(T) predicate,
    Widget Function(BuildContext context, T value) $true,
    Widget Function(BuildContext context, T value) $false,
  }) {
    return _build(
        () => bloc.$bool($vm, id: id, predicate: predicate, $true: $true, $false: $false));
  }

  Widget $switch<T>(
    LiveData<T> $vm, {
    Symbol id,
    @required Map<T, Widget Function(BuildContext context, T value)> builders,
    Widget Function(BuildContext context, T value) $default,
  }) {
    return _build(() => bloc.$switch($vm, id: id, builders: builders, $default: $default));
  }

  Widget $if<T>(
    LiveData<T> $vm, {
    Symbol id,
    bool Function(T) condition,
    @required Widget Function(BuildContext context, T value) builder,
    Widget Function(BuildContext context, T value) $else,
  }) {
    return _build(
        () => bloc.$if($vm, id: id, condition: condition, $else: $else, builder: builder));
  }

  Widget $else<T>(
    LiveData<T> $vm, {
    Symbol id,
    bool Function(T) condition,
    @required Widget Function(BuildContext context, T value) builder,
  }) {
    return _build(() => bloc.$else($vm, id: id, condition: condition, builder: builder));
  }

  Widget $for<T>(
    LiveData<List<T>> $vm, {
    Symbol id,
    @required Widget Function(BuildContext context, T value, int index) builder,
    Widget Function(BuildContext context, bool isNull) $empty,
    Widget Function(BuildContext context, List<T> list) adapter,
  }) {
    return _build(() => bloc.$for($vm, id: id, builder: builder, $empty: $empty, adapter: adapter));
  }
}
