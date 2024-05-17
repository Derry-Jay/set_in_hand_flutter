import '../models/task.dart';
import 'task_list_widget.dart';
import '../helpers/helper.dart';
import 'package:flutter/material.dart';

class TaskItemWidget extends StatefulWidget {
  final Task task;
  const TaskItemWidget({Key? key, required this.task}) : super(key: key);
  static TaskListWidgetState? of(BuildContext context) =>
      context.findAncestorStateOfType<TaskListWidgetState>();
  @override
  TaskItemWidgetState createState() => TaskItemWidgetState();
}

class TaskItemWidgetState extends State<TaskItemWidget> {
  Helper get hp => Helper.of(context);
  TaskListWidgetState? get tls => TaskItemWidget.of(context);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Container(
            height: hp.height /
                (hp.screenLayout == Orientation.landscape ? 10.24 : 12.5),
            width: hp.width / 2,
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(
                vertical: hp.height / 128, horizontal: hp.width / 64),
            padding: EdgeInsets.all(hp.radius / 160),
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(hp.radius / 125)),
                border: Border.all(
                    width: 1,
                    color: hp.theme.primaryColor,
                    style: BorderStyle.solid),
                color: Colors.white),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 3,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                                child: Text(widget.task.status,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: widget.task.status == 'Pull List'
                                            ? hp.theme.bottomAppBarColor
                                            : (widget.task.status ==
                                                    'Full Stock Check'
                                                ? hp.theme.errorColor
                                                : hp.theme.splashColor)))),
                            Flexible(
                                child: Text(widget.task.lapsedTime,
                                    style: const TextStyle(fontSize: 12))),
                          ])),
                  Expanded(
                      flex: 7,
                      child: Text(widget.task.toString(),
                          style: const TextStyle(fontSize: 12.8))),
                ])),
        onTap: () {
          hp.goTo(
              '/${widget.task.status == 'Pull List' ? 'pullList' : (widget.task.status == 'Full Stock Check' ? 'fullStock' : (widget.task.status == 'Cycle Stock Check' ? 'cycleStock' : ''))}',
              args: widget.task, vcb: () {
            try {
              tls?.dss?.didUpdateWidget(tls!.dss!.widget);
            } catch (e) {
              sendAppLog(e);
            }
          });
        });
  }
}
