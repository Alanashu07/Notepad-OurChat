import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notepad/Models/note_model.dart';
import 'package:notepad/Screens/note_creator.dart';
import 'package:notepad/Screens/note_reader.dart';
import 'package:notepad/Styles/app_style.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> filteredNotes = [];
  bool sorted = false;

  @override
  void initState() {
    super.initState();
    filteredNotes = sampleNotes;
  }

  getRandomColor() {
    Random random = Random();
    return AppStyle.cardsColor[random.nextInt(AppStyle.cardsColor.length)];
  }

  sortNotesByModifiedTime(List<Note> notes) {
    if (sorted) {
      notes.sort((a, b) => a.modifiedTime.compareTo(b.modifiedTime));
    } else {
      notes.sort((b, a) => a.modifiedTime.compareTo(b.modifiedTime));
    }
    sorted = !sorted;
    return notes;
  }

  void onSearchChanged(String searchText) {
    setState(() {
      filteredNotes = sampleNotes
          .where((note) =>
              note.content.toLowerCase().contains(searchText.toLowerCase()) ||
              note.title.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }

  void deleteNote(int index) {
    setState(() {
      filteredNotes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppStyle.mainColor,
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.refresh, color: Colors.white,), onPressed: (){
          setState(() {

          });
        },),
        backgroundColor: AppStyle.mainColor,
        centerTitle: true,
        title: const Text(
          "Notepad",
          style: TextStyle(
              color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  filteredNotes = sortNotesByModifiedTime(filteredNotes);
                });
              },
              icon: const Icon(
                Icons.sort,
                color: Colors.white,
              ))
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              onChanged: onSearchChanged,
              style: const TextStyle(fontSize: 16, color: Colors.white),
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  hintText: "Search Notes",
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white70,
                  ),
                  fillColor: const Color(0xFF000750),
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.transparent)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.transparent))),
            ),
          ),
          filteredNotes.isEmpty
              ? Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: const Text(
                    "No Notes Here!",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                      itemCount: filteredNotes.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              top: 15.0, right: 10, left: 10),
                          child: Card(
                            color: filteredNotes[index].color,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: ListTile(
                              leading: IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => NoteCreator(
                                                note: filteredNotes[index], title: 'Edit your Note',
                                              )));
                                  if (result != null) {
                                    setState(() {
                                      int noteIndex = sampleNotes
                                          .indexOf(filteredNotes[index]);
                                      sampleNotes[noteIndex] = (Note(
                                          id: sampleNotes[noteIndex].id,
                                          title: result[0],
                                          content: result[1],
                                          modifiedTime: DateTime.now(),
                                          color: filteredNotes[index].color));
                                      filteredNotes = sampleNotes;
                                    });
                                  }
                                },
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => NoteReader(
                                              note: filteredNotes[index],
                                              index: filteredNotes[index].id,
                                              notes: filteredNotes,
                                            )));
                              },
                              title: RichText(
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                    text: '${sampleNotes[index].title} \n',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      height: 1.5,
                                    ),
                                    children: [
                                      TextSpan(
                                          text: filteredNotes[index].content,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                            height: 1.5,
                                          ))
                                    ]),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  DateFormat('EEE MMM d, yyyy h:mm a').format(
                                      filteredNotes[index].modifiedTime),
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey.shade800),
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Are you sure?"),
                                              Icon(
                                                Icons.info_outline,
                                                color: Colors.black,
                                              )
                                            ],
                                          ),
                                          content: Text(
                                              "Your Note ${filteredNotes[index].title} will be deleted!"),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  deleteNote(index);
                                                  Navigator.pop(context);
                                                },
                                                child: const Text("Delete")),
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text("Cancel")),
                                          ],
                                        );
                                      });
                                },
                              ),
                            ),
                          ),
                        );
                      }),
                )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
              context, MaterialPageRoute(builder: (_) => const NoteCreator(title: 'Add your note',)));
          if (result != null) {
            setState(() {
              sampleNotes.add(Note(
                  id: sampleNotes.length,
                  title: result[0],
                  content: result[1],
                  modifiedTime: DateTime.now(),
                  color: result[2]));
              filteredNotes = sampleNotes;
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
