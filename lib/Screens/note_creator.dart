import 'dart:math';

import 'package:flutter/material.dart';
import 'package:notepad/Styles/app_style.dart';

import '../Models/note_model.dart';


class NoteCreator extends StatefulWidget {
  final Note? note;
  final String title;
  const NoteCreator({super.key, this.note, required this.title});

  @override
  State<NoteCreator> createState() => _NoteCreatorState();
}

class _NoteCreatorState extends State<NoteCreator> {

  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  getRandomColor(){
    Random random = Random();
    return AppStyle.cardsColor[random.nextInt(AppStyle.cardsColor.length)];
  }

  @override
  void initState() {
    if(widget.note != null) {
      _titleController = TextEditingController(text: widget.note!.title);
      _contentController = TextEditingController(text: widget.note!.content);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.note == null ? AppStyle.cardsColor[6] : widget.note!.color,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w500, color: Colors.black),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black54),
                  hintText: "Add your title here",
                ),
                controller: _titleController,
              ),
              const SizedBox(height: 10,),
              TextField(
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.black54),
                  hintText: "Add your content here",
                ),
                controller: _contentController,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          if(_titleController.text.isNotEmpty && _contentController.text.isNotEmpty){
          Navigator.pop(context, [
            _titleController.text, _contentController.text, getRandomColor()
          ]);} else{
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please Enter both title and content to save")));
          }
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}
