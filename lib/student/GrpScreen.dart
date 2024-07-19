import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Grpscreen extends StatefulWidget {
  final String email;
  final String id;
  final String role;

   Grpscreen({required this.email, required this.role, required this.id});

  @override
  State<Grpscreen> createState() => _GrpscreenState();
}

class _GrpscreenState extends State<Grpscreen> {
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body:
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: cards(),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: cards(),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: cards(),
        )
       
        ],
      )
      
    );
  }
}

class cards extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Group Name :",style: TextStyle(fontFamily: 'Monsteraat',fontSize: 20,fontWeight: FontWeight.w900),),
            Text("No Of Students :",style: TextStyle(fontFamily: 'Monsteraat',fontSize: 15,fontWeight: FontWeight.w900),),
            Text("Admin Name :",style: TextStyle(fontFamily: 'Monsteraat',fontSize: 15,fontWeight: FontWeight.w900),),
          ],
        ),
      ),
      height: 90,
      decoration: BoxDecoration(
          color: Colors.grey,
         borderRadius: BorderRadius.circular(10)
      ),
    );
  }
}