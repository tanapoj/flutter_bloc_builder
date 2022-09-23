import 'package:flutter/widgets.dart';
import 'package:flutter_live_data/flutter_live_data.dart';
import '../base_widget.dart';

class WatchBLoCWidget<T> extends BaseBLoCWidget {
  final LiveData<T>? liveData;
  final Widget Function(BuildContext context, T value) builder;

  const WatchBLoCWidget({
    Key? key,
    this.liveData,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (liveData == null) return EmptyWidget(key: key);
    return StreamBuilder<T>(
      key: key,
      stream: liveData!.stream,
      initialData: liveData!.initialValue,
      builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
        var value = liveData!.value ?? snapshot.data ?? liveData!.initialValue;
        return builder(context, value);
      },
    );
  }

  @override
  operator |(BaseBLoCWidget next) => this;
}
