import 'package:flutter/material.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Calls Screen"),),
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        child: Icon(Icons.add_call),
      ),
    );
  }
}
