import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sample_app/src/page_player.dart';
import 'package:sample_app/src/page_recorder.dart';

import 'page_gallery.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Main")),
      body: _getBody(context),
    );
  }

  Widget _getBody(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => RecorderPage()))},
                child: Text("Record audio")),
            ElevatedButton(
                onPressed: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerPage()))},
                child: Text("Play audio")),
            ElevatedButton(
                onPressed: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => GalleryPage()))},
                child: Text("Gallery")),
          ],
        ),
      ),
    );
  }
}
