import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:todo_demo/Model/task_model.dart';

import 'home_page/home_page_notifier.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomePageNotifier(),
      child: MaterialApp(
        title: 'Todo Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key}) : super(key: key);

  String taskTitle = '';

  bool flag = true;
  Stream<int>? timerStream;
  StreamSubscription<int>? timerSubscription;
  String hoursStr = '00';
  String minutesStr = '00';
  String secondsStr = '00';

  Stream<int> stopWatchStream() {
    late StreamController<int> streamController;
    Timer? timer;
    Duration timerInterval = const Duration(seconds: 1);
    int counter = 0;

    void stopTimer() {
      if (timer != null) {
        timer?.cancel();
        timer = null;
        counter = 0;
        streamController.close();
      }
    }

    void tick(_) {
      counter++;
      streamController.add(counter);
      if (!flag) {
        stopTimer();
      }
    }

    void startTimer() {
      timer = Timer.periodic(timerInterval, tick);
    }

    streamController = StreamController<int>(
      onListen: startTimer,
      onCancel: stopTimer,
      onResume: startTimer,
      onPause: stopTimer,
    );

    return streamController.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: Provider.of<HomePageNotifier>(context).taskList.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: ListView.builder(
                  itemCount: Provider.of<HomePageNotifier>(context).taskList.length,
                  itemBuilder: (context, index) {
                    List<TaskModel> data = Provider.of<HomePageNotifier>(context).taskList;
                    return InkWell(
                      onTap: () {
                        Provider.of<HomePageNotifier>(context, listen: false).updateFullListOfTask(data);
                        timerSubscription?.cancel();
                        timerStream = null;
                        Provider.of<HomePageNotifier>(context, listen: false).updateTimeData('00', '00', '00');
                        Provider.of<HomePageNotifier>(context, listen: false)
                            .updateTask(TaskModel(taskName: data[index].taskName, icon: data[index].icon, color: data[index].color, startTimer: true), index);
                        timerStream = stopWatchStream();
                        timerSubscription = timerStream!.listen((int newTick) {
                          Provider.of<HomePageNotifier>(context, listen: false).updateTimeData(((newTick / (60 * 60)) % 60).floor().toString().padLeft(2, '0'),
                              ((newTick / 60) % 60).floor().toString().padLeft(2, '0'), (newTick % 60).floor().toString().padLeft(2, '0'));
                        });
                      },
                      onDoubleTap: () {
                        Provider.of<HomePageNotifier>(context, listen: false).updateFullListOfTask(data);
                        timerSubscription?.cancel();
                        timerStream = null;
                        Provider.of<HomePageNotifier>(context, listen: false).updateTimeData('00', '00', '00');
                      },
                      child: Card(
                        elevation: 5,
                        color: Colors.white,
                        child: Container(
                          height: 100,
                          width: double.infinity,
                          color: data[index].color,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    data[index].icon,
                                    size: 60,
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    data[index].taskName,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                              data[index].startTimer!
                                  ? Consumer<HomePageNotifier>(
                                      builder: (_, data, __) {
                                        return Text(
                                          "${data.hoursStr}:${data.minutesStr}:${data.secondsStr}",
                                          style: const TextStyle(
                                            fontSize: 25.0,
                                          ),
                                        );
                                      },
                                    )
                                  : const SizedBox(),
                              Icon(
                                Icons.timer,
                                size: 40,
                                color: data[index].startTimer! ? Colors.red : Colors.green,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            )
          : const Center(
              child: Text('No Task is available'),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                  title: const Text('Add Task'),
                  content: TextField(
                    onChanged: (val) {
                      taskTitle = val;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Task Title',
                    ),
                  ),
                  actions: [
                    SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () {
                              Provider.of<HomePageNotifier>(context, listen: false).addTask(TaskModel(taskName: taskTitle, icon: Icons.description, color: Colors.white, startTimer: false));
                              Navigator.pop(context);
                            },
                            child: const Text('Add'))),
                  ],
                );
              });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
