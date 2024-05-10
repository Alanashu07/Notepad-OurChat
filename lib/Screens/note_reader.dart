import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notepad/Models/note_model.dart';
import 'package:notepad/Screens/note_home.dart';

import 'ChatApp/chat_lock_screen.dart';

class NoteReader extends StatefulWidget {
  final int index;
  final List<Note> notes;
  final Note note;
  const NoteReader({super.key, required this.note, required this.index, required this.notes});

  @override
  State<NoteReader> createState() => _NoteReaderState();
}

class _NoteReaderState extends State<NoteReader> {

  void deleteNote() {
    setState(() {
      widget.notes.removeAt(widget.index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.note.color,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Note View"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.note.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),),
              const SizedBox(height: 10,),
              Text(widget.note.content, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black),),
              Container(
                alignment: Alignment.centerRight,
                child: Text(DateFormat('EEE MMM d, yyyy h:mm a')
                    .format(widget.note.modifiedTime), style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 10, color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onLongPress: (){
          showDialog(context: context, builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Are you sure?"),
                  Icon(Icons.info_outline, color: Colors.black,)
                ],
              ),
              content: Text("Your Note ${widget.note.title} will be deleted!"),
              actions: [
                TextButton(onPressed: (){
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_)=> ChatLockScreen()));
                }, child: const Text("Delete")),
                TextButton(onPressed: (){
                  Navigator.pop(context);
                }, child: const Text("Cancel")),
              ],
            );
          });
        },
        child: FloatingActionButton(
          onPressed: (){
            showDialog(context: context, builder: (BuildContext context) {
              return AlertDialog(
                title: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Are you sure?"),
                    Icon(Icons.info_outline, color: Colors.black,)
                  ],
                ),
                content: Text("Your Note ${widget.note.title} will be deleted!"),
                actions: [
                  TextButton(onPressed: (){
                    deleteNote;
                    Navigator.pop(context);
                    Navigator.pop(context);
                    setState(() {
                      sampleNotes.remove(widget.note);
                      sampleNotes = widget.notes;
                    });
                  }, child: const Text("Delete")),
                  TextButton(onPressed: (){
                    Navigator.pop(context);
                  }, child: const Text("Cancel")),
                ],
              );
            });
          },
          child: const Icon(Icons.delete),
        ),
      ),
    );
  }
}
