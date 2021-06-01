import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RecorderPage extends StatelessWidget {
  const RecorderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recorder"),),
      body: _getBody(),
    );
  }

  Widget _getBody() {
    return SafeArea(child: Container());
  }
}
