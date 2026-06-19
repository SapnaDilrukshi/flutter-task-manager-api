import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:taskmamger/models/task_model.dart';

class ApiService {
  final String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/todos'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<Task> createTasks(String title) async {
    final response = await http.post(
      Uri.parse('$baseUrl/todos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': 1, 'title': title, 'completed': false}),
    );

    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create task');
    }
  }

  Future<Task> updateTask(int id, String title, bool completed) async {
    final response = await http.put(
      Uri.parse('$baseUrl/todos/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id,
        'userId': 1,
        'title': title,
        'completed': completed,
      }),
    );

    print("PUT Status: ${response.statusCode}");
    print(response.body);

    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create task');
    }
  }


  Future<void> deleteTask(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/todos/$id'),
    );

    print("DELETE Status: ${response.statusCode}");

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }
}
