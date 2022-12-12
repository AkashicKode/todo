import 'todoTask.dart';

class todoBook {
  final Map<int, List<todoTask>> _todoList = {};

  int dateTime2IntYYYYMMDD(DateTime dt) {
    return (dt.year * 10000) + (dt.month * 100) + dt.day;
  }

  String dateTime2StrHHMM(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  List<todoTask>? getToDoTasks(DateTime dt) {
    var intDate = dateTime2IntYYYYMMDD(dt);

    if (!_todoList.containsKey(intDate)) {
      _todoList[intDate] = [];
    }

    return _todoList[intDate];
  }
}
