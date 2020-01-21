import 'package:custed2/core/provider/provider_base.dart';
import 'package:flutter/cupertino.dart';

class DebugProvider extends ProviderBase {
  final widgets = <Widget>[];

  void addText(String text) {
    _addText(text);
    notifyListeners();
  }

  void _addText(String text) {
    _addWidget(Text(text));
  }

  void addError(Object error) {
    _addError(error);
    notifyListeners();
  }

  void _addError(Object error) {
    _addMultiline(error, CupertinoColors.destructiveRed);
  }

  void addMultiline(Object data, [Color color = CupertinoColors.activeBlue]) {
    _addMultiline(data, color);
    notifyListeners();
  }

  void _addMultiline(Object data, [Color color = CupertinoColors.activeBlue]) {
    final widget = Text(
      '$data',
      style: TextStyle(
        color: color,
      ),
    );
    _addWidget(SingleChildScrollView(
      child: widget,
      scrollDirection: Axis.horizontal,
    ));
  }

  void _addWidget(Widget widget) {
    final outlined = Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(
          color: CupertinoColors.activeGreen,
        ),
      ),
      child: widget,
    );

    widgets.add(outlined);
  }

  void clear() {
    widgets.clear();
    notifyListeners();
  }
}