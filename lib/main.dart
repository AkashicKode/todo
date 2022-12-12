import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'todoBook.dart';
import 'todoTask.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _nowSelected = DateTime.now();
  final todoBook _mapDt2Tasks = todoBook();
  final _taskNoteControl = TextEditingController();
  final _taskHHMMControl = TextEditingController();

  Widget _buildCalendar() {
    return TableCalendar(
      currentDay: _nowSelected,
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      selectedDayPredicate: (day) => isSameDay(day, _nowSelected),
      focusedDay: _nowSelected,
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      eventLoader: (day) {
        var todoList = _mapDt2Tasks.getToDoTasks(day);
        return (todoList != null && todoList.isNotEmpty) ? [""] : [];
      },
      /*calendarStyle: const CalendarStyle(
          markersAlignment: Alignment.bottomCenter,
          markerDecoration:
              BoxDecoration(shape: BoxShape.circle, color: Colors.redAccent)),
      */
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _nowSelected = focusedDay;
        });
      },
    );
  }

  Widget _buildTaskEntry(todoList) {
    return ListTile(
        tileColor: Colors.blue,
        leading: SizedBox(
            width: 80,
            child: TextField(
              inputFormatters: [
                LengthLimitingTextInputFormatter(5),
                FilteringTextInputFormatter.allow(RegExp(r'[0-9:]'))
              ],
              textAlign: TextAlign.center,
              controller: _taskHHMMControl,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: const InputDecoration(
                focusedBorder: OutlineInputBorder(),
                border: OutlineInputBorder(),
                hintStyle: TextStyle(color: Colors.white54),
                hintText: 'hh:mm',
              ),
            )),
        title: TextField(
          controller: _taskNoteControl,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            focusedBorder: OutlineInputBorder(),
            border: OutlineInputBorder(),
            hintStyle: TextStyle(color: Colors.white54),
            hintText: 'Enter the new event note',
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit_calendar),
          tooltip: "add event",
          color: Colors.white,
          onPressed: () {
            var taskHHMM = _taskHHMMControl.text;
            var tsParts = taskHHMM.split(":");
            var taskHH = 0;
            var taskMM = 0;
            try {
              if (tsParts.length != 2) {
                throw const FormatException(
                    "format in hh:mm - hh: hour (0 - 23), mm: minute (0 - 59)");
              }

              taskHH = int.parse(tsParts[0]);
              if (taskHH > 24 || taskHH < 0) {
                throw const FormatException(
                    "hh (hour) is in 24 hours format (0 to 23)");
              }

              taskMM = int.parse(tsParts[1]);
              if (taskMM > 60 || taskMM < 0) {
                throw const FormatException("mm (minute) is between 0 to 59");
              }
            } on FormatException catch (fmEx) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      // Retrieve the text the that user has entered by using the
                      // TextEditingController.
                      content: Text("Time format error: ${fmEx.message}"),
                    );
                  });

              return;
            }

            var newDt = DateTime(_nowSelected.year, _nowSelected.month,
                _nowSelected.day, taskHH, taskMM);

            todoList!.add(todoTask(newDt, _taskNoteControl.text));

            _taskHHMMControl.text = "";
            _taskNoteControl.text = "";

            setState(() {});
          },
        ));
  }

  Widget _buildTaskList(todoList) {
    if (todoList == null || todoList.length == 0) {
      return const SizedBox(
          height: 50,
          child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.elliptical(30, 60))),
              child: Center(
                  child: Text(
                "There is no event in this day",
                textAlign: TextAlign.center,
              ))));
    }

    return Expanded(
        child: ListView.builder(
            itemCount: todoList!.length * 2,
            padding: const EdgeInsets.all(8),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: /*1*/ (context, taskIdx) {
              if (taskIdx % 2 != 0) {
                return const Divider(
                  height: 10,
                );
              }

              var task = todoList!.elementAt(taskIdx / 2);

              return ListTile(
                leading: SizedBox(
                    width: 70,
                    child: Text(
                      _mapDt2Tasks.dateTime2StrHHMM(
                        task.dateTime(),
                      ),
                      textAlign: TextAlign.center,
                    )),
                title: Text(
                  task.note(),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_forever_outlined),
                  tooltip: "cancel event",
                  onPressed: () {
                    todoList!.removeAt(taskIdx);
                    setState(() {});
                  },
                ),
              );
            }));
  }

  @override
  Widget build(BuildContext context) {
    var taskList = _mapDt2Tasks.getToDoTasks(_nowSelected);
    taskList?.sort((a, b) => a.dateTime().compareTo(b.dateTime()));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _buildCalendar(),
          _buildTaskEntry(taskList),
          _buildTaskList(taskList)
        ],
      ),
    );
  }
}
