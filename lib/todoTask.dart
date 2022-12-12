class todoTask {
  late DateTime _dt;
  late String _note;

  todoTask._();

  todoTask(DateTime dt, String note) {
    _dt = dt;
    _note = note;
  }

  String note() {
    return _note;
  }

  DateTime dateTime() {
    return _dt;
  }
}
