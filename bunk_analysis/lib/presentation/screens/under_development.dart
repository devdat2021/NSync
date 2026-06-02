import 'package:flutter/material.dart';

class UnderDevelopmentPage extends StatelessWidget {
  const UnderDevelopmentPage({Key? key}) : super(key: key);

  static const routeName = '/under-development';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Under Development')),
      body: const Center(
        child: Text('Still under development', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
