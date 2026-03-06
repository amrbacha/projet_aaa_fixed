import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  late Future<String> _fileContentFuture;

  @override
  void initState() {
    super.initState();
    _fileContentFuture = _loadFile();
  }

  Future<String> _loadFile() async {
    try {
      // Attempt to load the raw content of the JSON file.
      return await rootBundle.loadString('assets/quran/quran.json');
    } catch (e) {
      // If it fails, return the error message.
      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File Read Test')),
      body: FutureBuilder<String>(
        future: _fileContentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          // Display the raw content of the file.
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Text(snapshot.data ?? "No data."),
          );
        },
      ),
    );
  }
}
