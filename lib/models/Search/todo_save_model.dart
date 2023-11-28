import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class ToDoSaveModel {
  ToDoSaveModel({required this.taskId, required this.taskName, required this.isDone});

  @HiveField(0)
  String taskId;

  @HiveField(1)
  String taskName;

  @HiveField(2)
  bool isDone;

  @override
  String toString() {
    return 'ToDoSaveModel{taskId: $taskId, taskName: $taskName, isDone: $isDone}';
  }

  factory ToDoSaveModel.fromJson(String taskId, String taskName, bool isDone) {
    return ToDoSaveModel(
      taskId: taskId,
      taskName: taskName,
      isDone: isDone,
    );
  }
}
