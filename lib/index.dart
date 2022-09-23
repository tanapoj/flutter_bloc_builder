import 'package:flutter/widgets.dart';
import 'package:flutter_live_data/flutter_live_data.dart';
import 'widgets/for_bloc_widget.dart';
import 'widgets/match_bloc_widget.dart';
import 'widgets/watch_bloc_widget.dart';
import 'widgets/when_bloc_widget.dart';

import 'base_widget.dart';

WatchBLoCWidget $watch<T>(
  LiveData<T>? lv, {
  Key? key,
  required Widget Function(BuildContext context, T value) build,
}) {
  return WatchBLoCWidget<T>(
    liveData: lv,
    builder: build,
    key: key,
  );
}

extension LiveDataWatch<T> on LiveData<T> {
  BaseBLoCWidget build(Widget Function(BuildContext context, T value) build) {
    return $watch(this, build: build);
  }

  BaseBLoCWidget $(Widget Function(BuildContext context, T value) build) {
    return $watch(this, build: build);
  }
}

WhenBLoCWidget<T> $when<T>(
  LiveData<T> lv, {
  Key? key,
}) {
  return WhenBLoCWidget<T>(
    liveData: lv,
    key: key,
  );
}

CaseBLoCWidget<T> $case<T>(
  bool Function(T value) predicate, {
  Key? key,
  required Widget Function(BuildContext context, T value) build,
}) {
  return CaseBLoCWidget<T>(
    key: key,
    predicate: predicate,
    builder: build,
  );
}

MatchBLoCWidget<T> _$guard<T>(
  LiveData<T> lv, {
  Key? key,
  required bool Function(T value) rejectWhen,
  required Widget Function(BuildContext context, T value) build,
}) {
  return MatchBLoCWidget<T>(
    key: key,
    liveData: lv,
    when: rejectWhen,
    builder: build,
  );
}

class GuardBuilder<T> extends MatchBLoCWidget<T> {
  GuardBuilder(
    LiveData<T> lv, {
    Key? key,
    required bool Function(T value) when,
    required Widget Function(BuildContext context, T value) build,
  }) : super(
          key: key,
          liveData: lv,
          when: when,
          builder: build,
        );
}

ForBLoCWidget<T> $for<T>(
  LiveData<List<T>> lv, {
  Key? key,
  Widget Function(BuildContext context, List<ItemViewHolder<T>> list)? buildList,
  Widget Function(BuildContext context, T value, int index)? buildItem,
  Widget Function(BuildContext context, List<T> list)? buildEmpty,
}) {
  buildList ??= (
    BuildContext _context,
    List<ItemViewHolder<T>> items,
  ) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, i) => items[i].widget,
    );
  };

  buildItem ??= (BuildContext _context, T value, int _index) {
    return Text('$value');
  };

  return ForBLoCWidget<T>(
    liveData: lv,
    listBuilder: buildList,
    itemBuilder: buildItem,
    emptyBuilder: buildEmpty ?? (_, list) => EmptyWidget(key: key),
  );
}

//
//
//
//
//
//
//
// Custom
//
//
//
//
//
//
//

bool Function(T value) $isNullFn<T>() {
  return (T value) => value == null;
}

bool Function(List<T> value) $isEmptyFn<T>() {
  return (List<T> value) => value.isEmpty;
}

BaseBLoCWidget<T> $true<T extends bool>({
  Key? key,
  required Widget Function(BuildContext context, T value) build,
}) {
  return CaseBLoCWidget<T>(
    key: key,
    predicate: (T value) => value,
    builder: build,
  );
}

BaseBLoCWidget<T> $false<T extends bool>({
  Key? key,
  required Widget Function(BuildContext context, T value) build,
}) {
  return CaseBLoCWidget<T>(
    key: key,
    predicate: (T value) => !value,
    builder: build,
  );
}

BaseBLoCWidget<T> $if<T>(
  LiveData<T> lv, {
  bool Function(T value)? condition,
  Key? key,
  required Widget Function(BuildContext context, T value) build,
}) {
  condition ??= (T v) {
    if (v is bool) return v;
    return false;
  };
  return $when<T>(lv) | $case<T>(condition, build: build);
}

BaseBLoCWidget<T> $else<T>({
  Key? key,
  required Widget Function(BuildContext context, T value) build,
}) {
  return $case<T>(
    (T value) => true,
    key: key,
    build: build,
  );
}

class $guard<T> extends GuardBuilder<T> {
  $guard(
    LiveData<T> lv, {
    Key? key,
    required bool Function(T value) when,
    required Widget Function(BuildContext context, T value) build,
  }) : super(
          lv,
          key: key,
          when: when,
          build: build,
        );

  factory $guard.isNull(
    LiveData<T> lv, {
    Key? key,
    required Widget Function(BuildContext context, T value) build,
  }) =>
      $guard<T>(
        lv,
        key: key,
        when: (T t) => t == null,
        build: build,
      );

  factory $guard.isNotNull(
    LiveData<T> lv, {
    Key? key,
    required Widget Function(BuildContext context, T value) build,
  }) =>
      $guard<T>(
        lv,
        key: key,
        when: (T t) => t != null,
        build: build,
      );

  factory $guard.isEmpty(
    LiveData<T> lv, {
    Key? key,
    required Widget Function(BuildContext context, T value) build,
  }) =>
      $guard<T>(
        lv,
        key: key,
        when: (T t) {
          if (t is List) return t.isEmpty;
          return true;
        },
        build: build,
      );

  factory $guard.isNotEmpty(
    LiveData<T> lv, {
    Key? key,
    required Widget Function(BuildContext context, T value) build,
  }) =>
      $guard<T>(
        lv,
        key: key,
        when: (T t) {
          if (t is List) return t.isNotEmpty;
          return true;
        },
        build: build,
      );

  factory $guard.isTrue(
    LiveData<T> lv, {
    Key? key,
    required Widget Function(BuildContext context, T value) build,
  }) =>
      $guard<T>(
        lv,
        key: key,
        when: (T t) {
          if (t is bool) return t == true;
          return false;
        },
        build: build,
      );

  factory $guard.isFalse(
    LiveData<T> lv, {
    Key? key,
    required Widget Function(BuildContext context, T value) build,
  }) =>
      $guard<T>(
        lv,
        key: key,
        when: (T t) {
          if (t is bool) return t == false;
          return true;
        },
        build: build,
      );
}
