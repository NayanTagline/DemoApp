import 'package:flutter/material.dart';
import 'package:todo_demo/Model/task_model.dart';

class HomePageNotifier extends ChangeNotifier {
  final List<TaskModel> _taskList = [];
  String _hoursStr = '00';
  String _minutesStr = '00';
  String _secondsStr = '00';

  List<TaskModel> get taskList => _taskList;
  String get hoursStr => _hoursStr;
  String get minutesStr => _minutesStr;
  String get secondsStr => _secondsStr;

  updateTimeData(String hour, String minutes, String second) {
    _hoursStr = hour;
    _minutesStr = minutes;
    _secondsStr = second;
    notifyListeners();
  }

  addTask(TaskModel taskModel) {
    _taskList.add(taskModel);
    notifyListeners();
  }

  updateTask(TaskModel taskModel, int index) {
    _taskList[index] = taskModel;
    notifyListeners();
  }

  updateFullListOfTask(List<TaskModel> tasks) {
    for (var element in tasks) {
      element.startTimer = false;
    }
    notifyListeners();
  }
}
