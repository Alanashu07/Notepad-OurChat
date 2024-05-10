
import 'dart:ui';

import 'package:flutter/material.dart';

class Note{
int id;
String title;
Color color;
String content;
DateTime modifiedTime;

Note({
  required this.id,
  required this.title,
  required this.content,
  required this.color,
  required this.modifiedTime
});
}

List<Note> sampleNotes = [];