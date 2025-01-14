import 'package:custed2/app.dart';
import 'package:custed2/core/extension/color.dart';
import 'package:custed2/data/providers/user_provider.dart';
import 'package:custed2/data/store/setting_store.dart';
import 'package:custed2/data/store/user_data_store.dart';
import 'package:custed2/locator.dart';
import 'package:custed2/service/custed_service.dart';
import 'package:custed2/ui/user_tab/custed_header.dart';
import 'package:custed2/core/util/utils.dart';
import 'package:custed2/ui/widgets/navbar/navbar.dart';
import 'package:custed2/ui/widgets/navbar/navbar_text.dart';
import 'package:custed2/ui/widgets/placeholder/placeholder.dart';
import 'package:custed2/ui/widgets/select_view.dart';
import 'package:custed2/ui/widgets/setting_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:provider/provider.dart';

class UserTab extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UseTabState();
}

class _UseTabState extends State<UserTab> with AutomaticKeepAliveClientMixin {
  final setting = locator<SettingStore>();
  List<Color> widgetColors = [];
  final custed = CustedService();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = Provider.of<UserProvider>(context);

    if (user.isBusy) return PlaceholderWidget(isActive: true);
    return _buildUserTab(context);
  }

  Widget _buildUserTab(BuildContext context) {
    return Scaffold(
        appBar: NavBar.material(
          context: context,
          leading: SizedBox(),
          middle: NavbarText('设置'),
        ),
        body: _buildSetting());
  }

  Widget _buildSetting() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          CustedHeader(),
          SizedBox(height: 10.0),
          Text('课表'),
          SizedBox(height: 10.0),
          SettingItem(
            title: '将课表设置为首页',
            showArrow: false,
            rightBtn: buildSwitch(context, setting.useScheduleAsHome),
          ),
          SettingItem(
            title: '研究生课表',
            showArrow: false,
            rightBtn: buildSwitch(context, setting.isGraduate),
          ),
          SettingItem(
            title: '显示非当前周课程',
            showArrow: false,
            rightBtn: buildSwitch(context, setting.showInactiveLessons),
          ),
          SettingItem(
            title: '隐藏周末',
            showArrow: false,
            rightBtn: buildSwitch(context, setting.scheduleHideWeekend),
          ),
          SettingItem(
            title: '推送上课通知',
            showArrow: false,
            rightBtn: buildSwitch(context, setting.pushNotification,
                func: (v) => sendSetting2Backend(v)),
          ),
          SizedBox(height: 10.0),
          Text('主题'),
          SizedBox(height: 10.0),
          SettingItem(
            title: '课表主题',
            showArrow: false,
            rightBtn: _showMenu(context),
          ),
          SettingItem(
            title: '使用渐变色',
            showArrow: false,
            rightBtn: buildSwitch(context, setting.scheduleUseGradient),
          ),
          SettingItem(
            title: 'App强调色',
            showArrow: false,
            rightBtn: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: _buildAppColorPreview(),
            ),
          ),
          SettingItem(
            title: '黑暗模式',
            showArrow: false,
            rightBtn: _buildDarkModeRadio(),
          ),
          SizedBox(height: 10.0),
          Text('更多'),
          SizedBox(height: 10.0),
          SettingItem(
            title: '绩点不计选修',
            showArrow: false,
            rightBtn:
                buildSwitch(context, setting.dontCountElectiveCourseGrade),
          ),
          SettingItem(
            title: '持续自动更新天气',
            showArrow: false,
            rightBtn: buildSwitch(context, setting.autoUpdateWeather),
          ),
          SizedBox(height: 40.0)
        ],
      ),
    );
  }

  Widget _buildAppColorPreview() {
    final nowAppColor = primaryColor;
    return GestureDetector(
      child: ClipOval(
        child: Container(
          color: nowAppColor,
          height: 27,
          width: 27,
        ),
      ),
      onTap: () => _showAppColorPicker(nowAppColor),
    );
  }

  List<String> themeName = [
    '梵高·星空',
    '霓虹·浅粉',
    '故宫·口红',
    '夏日·薄荷',
    '中式·传统',
    '蒙克·尖叫'
  ];

  Widget _showMenu(BuildContext context) {
    return PopupMenuButton<int>(
        child: Padding(
          child: Row(
            children: [
              Text(themeName[setting.scheduleTheme.fetch()]),
              Icon(Icons.keyboard_arrow_down)
            ],
          ),
          padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
        ),
        itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
              SelectViewText('梵高·星空', 0),
              SelectViewText('霓虹·浅粉', 1),
              SelectViewText('故宫·口红', 2),
              SelectViewText('夏日·薄荷', 3),
              SelectViewText('中式·传统', 4),
              SelectViewText('蒙克·尖叫', 5),
            ],
        onSelected: (int idx) {
          setting.scheduleTheme.put(idx);
          setState(() {});
        });
  }

  void sendSetting2Backend(bool v) async {
    final id = locator<UserDataStore>().username.fetch();
    if (id == null || id.isEmpty || id.length < 9) {
      setting.pushNotification.put(false);
      return showSnackBar(context, '请先登录');
    }
    if (!(await custed.remoteHaveSchedule(id))) {
      setting.pushNotification.put(false);
      return showSnackBar(context, '未能检测到课表！\n请登录并刷新课表后重试');
    }
    await custed.setPushScheduleNotification(v);
    requestUpdateHomeWidget(enablePush: v);
  }

  void _showAppColorPicker(Color selected) {
    showRoundDialog(
        context,
        '选择颜色',
        MaterialColorPicker(
            shrinkWrap: true,
            onColorChange: (Color color) async {
              setting.appPrimaryColor.put(color.value);
            },
            selectedColor: selected),
        [
          TextButton(
              onPressed: () => Navigator.of(context).pop(), child: Text('取消')),
          TextButton(
              onPressed: () async {
                final dark = setting.darkMode.fetch();
                setting.darkMode.put(dark);
                if (primaryColor.isBrightColor) {
                  showSnackBar(context, '当前设置的颜色过浅\n不会应用至高亮字、按钮、开关等');
                }
                setState(() {});
                Navigator.of(context).pop();
              },
              child: Text('确定')),
        ]);
  }

  Widget _buildDarkModeRadio() {
    final color = MaterialStateProperty.all(primaryColor);
    final value = setting.darkMode.fetch();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('自动'),
        Radio(
            value: 0,
            fillColor: color,
            groupValue: value,
            onChanged: _onSelection),
        Text('开'),
        Radio(
            value: 1,
            fillColor: color,
            groupValue: value,
            onChanged: _onSelection),
        Text('关'),
        Radio(
            value: 2,
            fillColor: color,
            groupValue: value,
            onChanged: _onSelection)
      ],
    );
  }

  void _onSelection(int index) {
    if (index == 0) {
      showSnackBar(context, '自动模式仅在Android 10+或iOS 13+有效');
    }
    final setting = locator<SettingStore>();
    setting.darkMode.put(index);
  }

  @override
  bool get wantKeepAlive => true;
}
