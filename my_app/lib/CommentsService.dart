
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

enum Status {
  failed,
  success,
}

class Comment {
  final int userId;
  final int id;
  final String title;

  const Comment({
    required this.userId,
    required this.id,
    required this.title,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      userId: json['userId'] as int,
      id: json['id'] as int,
      title: json['title'] as String,
    );
  }
}

class CommentsService extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _pageNumber = 1;

  List<Comment> comments = [];

  Future<List<Comment>> fetchComments() async {
    _isLoading = true;
    notifyListeners();

    final response = await http
        .get(Uri.parse(
            'https://jsonplaceholder.typicode.com/users/$_pageNumber/todos'))
        .catchError((e) {});

    if (response.statusCode == 200) {
      // Use the compute function to run parseComments in a separate isolate.
      var fechedComments = parseComments(response.body);

      _pageNumber = _pageNumber + 1;
      _isLoading = false;
      comments.addAll(fechedComments);
      notifyListeners();

      return comments;
    } else {
      _isLoading = false;
      notifyListeners();
      throw Exception('Error - ${response.statusCode}');
    }
  }

  List<Comment> parseComments(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    final list = parsed.map<Comment>((json) => Comment.fromJson(json)).toList();
    return list;
  }

  Future<Status> sendMessageToServer(String text) async {
    try {
      final response = await http.post(
        Uri.parse(' https://cambi.co.il/test/testAssignComment '),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'text': text,
        }),
      );

      if (response.statusCode == 200) {
        // At this part should also be a check for valid parsed response, if not valid should be returned status.failed.
        return Status.success;
      } else {
        throw Exception('Request Error: ${response.statusCode}');
      }
    } on Exception {
      rethrow;
    }
  }
}
