// The original content is temporarily commented out to allow generating a self-contained demo - feel free to uncomment later.

// import 'package:flutter/material.dart';
import 'package:silvanus/engine.dart';

import 'widgets/simple_line_chart.dart';
import 'package:flutter/material.dart';
import 'package:silvanus/src/rust/frb_generated.dart';

Future<void> main() async {
  await RustLib.init();
  await Engine.engine.begin();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
        body: Center(
        child: Column(
          mainAxisAlignment: .center,
         children: [
            SizedBox(
              height: 300,
              child: SimpleLineChart(),
            ),
          ]
        )
        ),
      ),
    );
  }
}
