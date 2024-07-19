import 'package:flutter/material.dart';

class Overview extends StatelessWidget {
  final String email;
  final String id;
  final String role;
     
     Overview({required this.email, required this.role, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 200,
            width: 400,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10),
             
            ),
            
           child:  Padding(
             padding: const EdgeInsets.all(8.0),
             child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text("Group Name :",style: TextStyle(fontFamily: 'Monsteraat',fontSize: 20,fontWeight: FontWeight.w900),),
               ],
             ),
           ),
          ),
        ),
      )
      
    );
  }
}
