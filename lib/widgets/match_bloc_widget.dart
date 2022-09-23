import 'package:flutter/widgets.dart';
import 'package:flutter_live_data/flutter_live_data.dart';
import '../base_widget.dart';

// ignore: must_be_immutable
class MatchBLoCWidget<T> extends BaseBLoCWidget {
  final LiveData<T> liveData;
  final bool Function(T value) when;
  final Widget Function(BuildContext context, T value) builder;
  BaseBLoCWidget? prev;
  BaseBLoCWidget? next;

  MatchBLoCWidget({
    Key? key,
    required this.liveData,
    required this.when,
    required this.builder,
    this.prev,
    this.next,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      key: key,
      stream: liveData.stream,
      initialData: liveData.initialValue,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        var value = liveData.value ?? snapshot.data ?? liveData.initialValue;
        var mWhen = when(value);
        if (mWhen) {
          return builder(context, value);
        }
        return next?.build(context) ?? EmptyWidget(key: key);
      },
    );
  }

  @override
  operator |(BaseBLoCWidget next) {
    MatchBLoCWidget<dynamic> lastGuardBuilder = this;
    var limit = 100;
    while (lastGuardBuilder is MatchBLoCWidget) {
      if (lastGuardBuilder.next is! MatchBLoCWidget) {
        break;
      }
      lastGuardBuilder = lastGuardBuilder.next as MatchBLoCWidget;
    }

    if (next is MatchBLoCWidget) {
      next.prev = lastGuardBuilder;
    }
    lastGuardBuilder.next = next;
    return this;
  }
}
