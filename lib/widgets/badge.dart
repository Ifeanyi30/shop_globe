import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final Widget icon;
  final int count;

  Badge({@required this.icon, @required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          icon,
          Positioned(
            left: 25,
            top: 8,
            child: Transform(
              transform: Matrix4.identity()..scale(0.4),
              child: Chip(
                backgroundColor: Colors.red,
                label: Text(
                  '$count',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // child: Container(
            //   padding: EdgeInsets.all(2.0),
            //   constraints: BoxConstraints(minHeight: 16, maxWidth: 16),
            //   decoration: BoxDecoration(
            //     color: Colors.red,
            //     borderRadius: BorderRadius.circular(10),
            //   ),
            //   child: Text(
            //     '$count',
            //     style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            //     textAlign: TextAlign.center,
            //   ),
            // )
          )
        ],
      ),
    );
  }
}
