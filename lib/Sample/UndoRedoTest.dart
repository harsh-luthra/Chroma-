import 'package:chroma_plus_flutter/MarkersDataObj.dart';
import 'package:flutter/material.dart';
import 'package:undo/undo.dart';

class UndoRedoTest extends StatefulWidget {
  const UndoRedoTest({super.key});

  @override
  UndoRedoTestState createState() => UndoRedoTestState();
}

class UndoRedoTestState extends State<UndoRedoTest> {
  late SimpleStack _controller;

  MarkersDataObj markersDataObj = new MarkersDataObj();

  @override
  void initState() {
    _controller = SimpleStack<int>(
      0,
      onUpdate: (val) {
        if (mounted) {
          setState(() {
            //print('New Value -> $val');
            print(markersDataObj.markerTopLeft);
          });
        }
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var count = _controller.state;
    return Scaffold(
      appBar: AppBar(
        title: Text('Undo/Redo Example'),
      ),
      body: Center(
        child: Text('Count: $count'),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: !_controller.canUndo
                  ? null
                  : () {
                if (mounted)
                  setState(() {
                    _controller.undo();
                    print(markersDataObj.markerTopLeft);
                  });
              },
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: !_controller.canRedo
                  ? null
                  : () {
                if (mounted)
                  setState(() {
                    _controller.redo();
                    print(markersDataObj.markerTopLeft);
                  });
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        heroTag: ValueKey('add_button'),
        child: Icon(Icons.add),
        onPressed: () {
          //_controller.modify(count+1);
          _controller.add(
              Change(
                  markersDataObj.markerTopLeft,
                      () {
                        markersDataObj.markerTopLeft = !markersDataObj.markerTopLeft;
                      },
                  (old) => markersDataObj.markerTopLeft = old,
              )
          );
          print(markersDataObj.markerTopLeft);
        },
      ),
    );
  }
}