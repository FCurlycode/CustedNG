import 'package:after_layout/after_layout.dart';
import 'package:alice/alice.dart';
import 'package:custed2/app_frame.dart';
import 'package:custed2/core/platform/os/app_doc_dir.dart';
import 'package:custed2/data/providers/debug_provider.dart';
import 'package:custed2/locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Custed extends StatefulWidget {
  @override
  _CustedState createState() => _CustedState();
}

class _CustedState extends State<Custed> with AfterLayoutMixin<Custed> {
  @override
  Widget build(BuildContext context) {
    const isDark = false;

    return MaterialApp(
      navigatorKey: locator<Alice>().getNavigatorKey(),
      home: CupertinoApp(
        theme: CupertinoThemeData(
          // 在这里修改亮度可以决定应用主题，详见 [AppTheme] 类
          brightness: isDark ? Brightness.dark : Brightness.light,
        ),
        title: 'Custed',
        home: AppFrame(),
      ),
    );
  }

  // 在这里进行初始化，避免启动掉帧
  @override
  void afterFirstLayout(BuildContext context) async {
    final path = await getAppDocDir.invoke();
    print('AppDocDir: $path');
    final debug = locator<DebugProvider>();
    debug.addMultiline(r'''
  
      _____         __         __   
     / ___/_ _____ / /____ ___/ /   
    / /__/ // (_-</ __/ -_) _  /    
    \___/\_,_/___/\__/\__/\_,_/     

      App First Layout Done. 
  
    ''');
  }
}