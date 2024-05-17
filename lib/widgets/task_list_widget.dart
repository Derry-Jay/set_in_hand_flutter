import 'empty_widget.dart';
import '../models/task.dart';
import '../back_end/api.dart';
import 'task_item_widget.dart';
import '../helpers/helper.dart';
import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';

class TaskListWidget extends StatefulWidget {
  const TaskListWidget({Key? key}) : super(key: key);
  static DashboardScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<DashboardScreenState>();
  @override
  TaskListWidgetState createState() => TaskListWidgetState();
}

class TaskListWidgetState extends State<TaskListWidget> {
  DashboardScreenState? get dss => TaskListWidget.of(context);

  void tasksListener() {
    log('task');
  }

  Widget listBuilder(BuildContext context, List<Task>? tasks, Widget? child) {
    Widget getItem(BuildContext context, int index) {
      return TaskItemWidget(task: tasks?[index] ?? Task.emptyTask);
    }

    return tasks == null
        ? (child ?? const EmptyWidget())
        : (tasks.isEmpty
            ? const Text('No Tasks Found')
            : ListView.builder(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                itemBuilder: getItem,
                itemCount: tasks.length));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tasks.addListener(tasksListener);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Task>?>(
        valueListenable: tasks, builder: listBuilder);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    tasks.removeListener(tasksListener);
    super.dispose();
  }
}
