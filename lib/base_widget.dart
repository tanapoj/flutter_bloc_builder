import 'package:flutter/widgets.dart';

class BaseBLoCWidget<T> extends StatelessWidget {
  const BaseBLoCWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyWidget(key: key);
  }

  operator |(BaseBLoCWidget<T> next) => next;
}

class EmptyWidget extends Widget {
  static EmptyWidget? _singleton;

  factory EmptyWidget({Key? key}) {
    _singleton ??= EmptyWidget._internal(key: key);
    return _singleton!;
  }

  const EmptyWidget._internal({Key? key}) : super(key: key);

  @override
  Element createElement() => _EmptyWidgetElement(this);
}

class _EmptyWidgetElement extends Element {
  _EmptyWidgetElement(EmptyWidget widget) : super(widget);

  @override
  void mount(Element? parent, dynamic newSlot) {
    super.mount(parent, newSlot);
  }

  @override
  bool get debugDoingBuild => false;

  @override
  void performRebuild() {}
}
