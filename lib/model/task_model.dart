import 'package:flutter/material.dart';

class TaskModel {
  final String taskName;
  final IconData icon;
  final Color color;
  bool? startTimer = false;
  TaskModel({required this.taskName, required this.icon, required this.color, this.startTimer});
}
