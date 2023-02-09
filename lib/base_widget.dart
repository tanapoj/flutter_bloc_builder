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

class EmptyWidget extends SizedBox {
  const EmptyWidget({super.key, super.width, super.height, super.child});
}

class EmptyWidget1 extends Widget {
  static EmptyWidget1? _singleton;

  factory EmptyWidget1({Key? key}) {
    _singleton ??= EmptyWidget1._internal(key: key);
    return _singleton!;
  }

  const EmptyWidget1._internal({Key? key}) : super(key: key);

  @override
  Element createElement() => _EmptyWidgetElement(this);
}

class _EmptyWidgetElement extends Element {
  _EmptyWidgetElement(EmptyWidget1 widget) : super(widget);

  @override
  void mount(Element? parent, dynamic newSlot) {
    super.mount(parent, newSlot);
  }

  @override
  bool get debugDoingBuild => false;

  @override
  void performRebuild() {}
}
