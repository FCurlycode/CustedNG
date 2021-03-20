import 'dart:math' as math;

import 'package:custed2/core/provider/busy_provider.dart';
import 'package:custed2/core/user/undergraduate_user.dart';
import 'package:custed2/core/user/user.dart';
import 'package:custed2/data/models/custom_schedule_profile.dart';
import 'package:custed2/data/models/schedule.dart';
import 'package:custed2/data/models/schedule_lesson.dart';
import 'package:custed2/data/store/custom_lesson_store.dart';
import 'package:custed2/data/store/custom_schedule_store.dart';
import 'package:custed2/data/store/schedule_store.dart';
import 'package:custed2/locator.dart';

class ScheduleProvider extends BusyProvider {
  Schedule _schedule;

  Schedule get schedule => _schedule;

  int _selectedWeek = 1;

  int get selectedWeek => _selectedWeek;

  int get activeLessonCount => schedule?.activeLessonCount(selectedWeek) ?? 0;

  final int minWeek = 1;

  int get maxWeek => _schedule?.weekCount;

  int get currentWeek => _schedule?.calculateWeekSinceStart(DateTime.now());

  CustomScheduleProfile _customScheduleProfile;

  CustomScheduleProfile get customScheduleProfile => _customScheduleProfile;

  set customScheduleProfile(CustomScheduleProfile c) =>
      _customScheduleProfile = c;

  void selectWeek(int week) {
    if (week < minWeek || week > maxWeek) {
      return;
    }

    _selectedWeek = week;
    notifyListeners();
  }

  Future<void> loadLocalData(
      {bool resetWeek = false, bool refreshAnyway = false}) async {
    Schedule head;
    if (customScheduleProfile == null) {
      final scheduleStore = await locator.getAsync<ScheduleStore>();
      head = scheduleStore.head;
    } else {
      final customScheduleStore = await locator.getAsync<CustomScheduleStore>();
      head =
          customScheduleStore.getScheduleWithUUID(customScheduleProfile.uuid);
    }
    await _useSchedule(head, accpetNullSchedule: refreshAnyway);

    if (refreshAnyway || head != null) {
      print('use cached schedule: $head');
      if (resetWeek) {
        resetWeekToCurrentWeek();
      }
      notifyListeners();
    }
  }

  Future<void> updateScheduleData({bool resetWeek = false}) async {
    await busyRun(_updateScheduleData);
    if (resetWeek) resetWeekToCurrentWeek();
  }

  Future<void> _updateScheduleData() async {
    if (customScheduleProfile == null) {
      final schedule = await User().getSchedule();
      _schedule = schedule;
      final scheduleStore = await locator.getAsync<ScheduleStore>();
      scheduleStore.checkIn(schedule);
      _useSchedule(schedule);
    } else {
      final uuid = customScheduleProfile.uuid;
      final schedule = await UndergraduateUser.getScheduleByStudentUUID(uuid);
      final scheduleStore = await locator.getAsync<CustomScheduleStore>();
      scheduleStore.saveScheduleWithUUID(uuid, schedule);

      _schedule = schedule;
      _useSchedule(schedule);
    }
  }

  Future<void> _useSchedule(Schedule schedule,
      {bool accpetNullSchedule = false}) async {
    if (schedule == null) {
      _schedule = schedule;
      return;
    }
    ;

    final newSchedule = schedule.safeCopy();
    final customLessonStore = await locator.getAsync<CustomLessonStore>();
    newSchedule.lessons.addAll(customLessonStore.box.values);
    _schedule = newSchedule;
  }

  void gotoNextWeek() {
    if (_schedule != null && _selectedWeek < maxWeek) {
      _selectedWeek++;
      notifyListeners();
    }
  }

  void gotoPrevWeek() {
    final minAllowedWeek = math.min(currentWeek, minWeek);
    if (_schedule != null && _selectedWeek > minAllowedWeek) {
      _selectedWeek--;
      notifyListeners();
    }
  }

  void resetWeekToCurrentWeek() {
    _selectedWeek = currentWeek ?? 1;
  }

  void gotoCurrentWeek() {
    _selectedWeek = currentWeek;
    notifyListeners();
  }

  Iterable<ScheduleLesson> lessonsSince(DateTime dateTime) {
    return _schedule?.lessonsSince(dateTime);
  }
}
