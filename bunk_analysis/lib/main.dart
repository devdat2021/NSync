import 'package:flutter/material.dart';
import 'navbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _selectedSection = 'Home';

  void _selectSection(String section) {
    setState(() {
      _selectedSection = section;
    });
    Navigator.of(context).pop();
  }

  void _handleLogout() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logging off..')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomSideBar(
        userName: 'John Doe',
        userEmail: 'john@example.com',
        userMobile: '+1 555 0100',
        usn: 'NNM24IS145',
        profileImageUrl: null,
        onSectionSelected: _selectSection,
        onLogout: _handleLogout,
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _selectedSection,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            const Text('Use the hamburger menu to open the sidebar.'),
          ],
        ),
      ),
    );
  }
}
