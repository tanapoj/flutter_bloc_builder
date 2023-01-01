import 'package:flutter/widgets.dart';
import 'package:flutter_live_data/index.dart';
import 'widgets/for_bloc_widget.dart';
import 'widgets/match_bloc_widget.dart';
import 'widgets/watch_bloc_widget.dart';
import 'widgets/when_bloc_widget.dart';
import 'package:async/async.dart' show StreamGroup;

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

/// Memorize

class Memorize {
  final Map<Symbol, dynamic> _symbol = {};

  Memorize({Map<Symbol, LiveData>? init}) {
    if (init != null) {
      for (var entry in init.entries) {
        put(entry.key, entry.value.value);
      }
    }
  }

  T put<T>(Symbol symbol, T value) {
    _symbol[symbol] = value;
    return value;
  }

  T get<T>(Symbol symbol) => _symbol.containsKey(symbol) ? _symbol[symbol] : null;

  dynamic operator [](Symbol symbol) => get(symbol);

  @override
  String toString() {
    return 'Memorize{$_symbol}';
  }
}

class _Pair<F extends dynamic, S extends dynamic> {
  final F first;
  final S second;

  _Pair(this.first, this.second);

  @override
  String toString() {
    return 'Pair{(${first.runtimeType}) $first, (${second.runtimeType}) $second}';
  }
}

WatchBLoCWidget $watchMany(
  Map<Symbol, LiveData> liveDataMap, {
  required Widget Function(BuildContext context, Memorize memorize) build,
  LifeCycleOwner? owner,
}) {
  if (owner != null) {
    return $watch(makeMemorize(liveDataMap).owner(owner), build: build);
  } else {
    return $watch(makeMemorize(liveDataMap), build: build);
  }
}

LiveData<Memorize> makeMemorize(
  Map<Symbol, LiveData> liveDataMap, {
  String? name,
  bool verifyDataChange = false,
}) {
  Iterable<Stream<dynamic>> streams = liveDataMap
      .map((name, lv) {
        return MapEntry(name, lv.stream?.map((stream) => _Pair(name, stream)));
      })
      .values
      .map((e) => e!);
  var streamGroup = StreamGroup.merge(streams);
  var m = Memorize(init: liveDataMap);
  var memorizeBarrier = streamGroup.map((pair) => m..put(pair.first, pair.second));
  LiveData<Memorize> liveData = LiveData.stream(
    m,
    memorizeBarrier,
    name: name,
    verifyDataChange: verifyDataChange,
  );
  return liveData;
}
