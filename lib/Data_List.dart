import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import 'AppConstants.dart';

class Data_List extends StatefulWidget {
  Data_List({Key? key}) : super(key: key);

  @override
  State<Data_List> createState() => Data_List_State();

  //List<String> names = <String>['Aby', 'Aish', 'Ayan', 'Ben', 'Bob', 'Charlie', 'Cook', 'Carline'];
}

class Data_List_State extends State<Data_List> {
  double? screenWidth;
  double? screenHeight;

  List<String> names = <String>['Aby', 'Aish', 'Ayan', 'Ben', 'Bob', 'Charlie', 'Cook', 'Carline'];
  List<int> msgCount = <int>[2, 0, 10, 6, 52, 4, 0, 2];

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppConstants.Bg_Color,
        body: Container(
          width: screenWidth!,
          decoration: const BoxDecoration(
            color: AppConstants.Bg_Color,
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    shrinkWrap: true,
                    itemCount: names.length,
                    itemBuilder: (BuildContext context, int index) {
                      //return listItem(context, index);
                      return SlideableTest(index,names[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget SlideableTest(int index, String txt){
    return Slidable(
      // Specify a key if the Slidable is dismissible.
      key: UniqueKey(),
      // The start action pane is the one at the left or the top side.
      // startActionPane: ActionPane(
      //   // A motion is a widget used to control how the pane animates.
      //   motion: const ScrollMotion(),
      //   // A pane can dismiss the Slidable.
      //   dismissible: DismissiblePane(onDismissed: () {}),
      //   // All actions are defined in the children parameter.
      //   children: [
      //     // A SlidableAction can have an icon and/or a label.
      //     SlidableAction(
      //       onPressed: doNothing(),
      //       backgroundColor: Color(0xFFFE4A49),
      //       foregroundColor: Colors.white,
      //       icon: Icons.delete,
      //       label: 'Delete',
      //     ),
      //   ],
      // ),

      // The end action pane is the one at the right or the bottom side.
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(onDismissed: () {
          setState(() {
            names.removeAt(index);
          });
        }),
        children: [
          SlidableAction(
            // An action can be bigger than the others.
            flex: 2,
            borderRadius: BorderRadius.circular(10),
            autoClose: true,
            onPressed: (context){
              setState(() {
                names.removeAt(index);
                });
            },
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: listItem(context,index),
    );
  }

  doNothing(int index){
    // setState(() {
    //   names.remove(index);
    // });
  }

  Widget listItem(BuildContext context, int index) {
    return Card(
      color: Color.fromARGB(255, 59, 59, 59),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            children: [
              Container(
                margin: EdgeInsets.only(left: 10),
                height: 20,
                width: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.transparent,
                  image: DecorationImage(
                    image: AssetImage('assets/images/edit_icon.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Container(
              //   margin: EdgeInsets.all(10),
              //   child: Text("$index",
              //     style: TextStyle(color: Colors.white),
              //   ),
              // ),
              Container(
                margin: EdgeInsets.all(10),
                child: Text(DateFormat("MM-dd-yyyy - hh:mm:ss a").format(DateTime.now()),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Image(image: AssetImage('assets/images/exportImg.png'),
                  fit: BoxFit.contain,
                  width: 20,
                  height: 20,
                ),
                iconSize: 5,
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return true;
  }
}
