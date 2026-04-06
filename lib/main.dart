// The original content is temporarily commented out to allow generating a self-contained demo - feel free to uncomment later.

// import 'package:flutter/material.dart';
import 'package:silvanus/engine.dart';
import 'package:silvanus/widgets/analysis_tab.dart';

import 'package:flutter/material.dart';
import 'package:silvanus/src/rust/frb_generated.dart';
import 'package:silvanus/widgets/source_select.dart';

Future<void> main() async {
  await RustLib.init();
  await Engine.engine.begin();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SourceOptions selectedSource = SourceOptions.none;

  Key refreshKey = UniqueKey();

  void rebuildTab() {
    setState(() {
      refreshKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Silvanus')),
        body: Center(
        child: Column(
          mainAxisAlignment: .center,
         children: [
          SizedBox(
              height: 300,
              child: AnalysisTab(key: ValueKey(refreshKey),
            ),),
            SourceSelector(onSelectionChanged: (SourceOptions src) { rebuildTab();}),
          ]
        )
        ),
      ),
    );
  }
}
