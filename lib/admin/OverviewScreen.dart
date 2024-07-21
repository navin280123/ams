import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

class OverviewScreen extends StatelessWidget {
  final String email;
  final String id;
  final String role;

  OverviewScreen({required this.email, required this.role, required this.id});

  final DatabaseReference databaseReference = FirebaseDatabase.instance.reference();

  Future<Map<String, dynamic>> getOverviewData() async {
    final groupsEvent = await databaseReference.child('org/$id/groups').once();
    final groups = (groupsEvent.snapshot.value as Map<dynamic, dynamic>?) ?? {};

    Map<String, dynamic> groupData = {};

    for (String groupId in groups.keys) {
      final groupDetailsEvent = await databaseReference.child('org/$id/groups/$groupId/details').once();
      final groupDetails = groupDetailsEvent.snapshot.value as Map<dynamic, dynamic>? ?? {};

      final qrEvent = await databaseReference.child('org/$id/groups/$groupId/qr/${DateFormat('yyyy-M-d').format(DateTime.now())}').once();
      final qrDetails = qrEvent.snapshot.value as Map<dynamic, dynamic>? ?? {};

      int presentCount = 0;
      int totalStudents = 0;
      for (int i = 0; i < 7; i++) {
        final date = DateFormat('yyyy-M-d').format(DateTime.now().subtract(Duration(days: i)));
        final attendanceEvent = await databaseReference.child('org/$id/groups/$groupId/attendance/$date').once();
        final attendance = attendanceEvent.snapshot.value as Map<dynamic, dynamic>? ?? {};
        presentCount += attendance.keys.length;

        final studentsEvent = await databaseReference.child('org/$id/groups/$groupId/students').once();
        final students = studentsEvent.snapshot.value as Map<dynamic, dynamic>? ?? {};
        totalStudents = students.keys.length;
      }

      groupData[groupId] = {
        'details': groupDetails,
        'qr': qrDetails,
        'presentCount': presentCount,
        'totalStudents': totalStudents,
      };
    }

    return groupData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: getOverviewData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final groupData = snapshot.data ?? {};

          return ListView.builder(
            itemCount: groupData.keys.length,
            itemBuilder: (context, index) {
              final groupId = groupData.keys.elementAt(index);
              final groupDetails = groupData[groupId]['details'];
              final qrDetails = groupData[groupId]['qr'];
              final presentCount = groupData[groupId]['presentCount'];
              final totalStudents = groupData[groupId]['totalStudents'];

              return Card(
                color: Colors.black12,
                margin: EdgeInsets.all(16.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Group: ${groupDetails['groupName']}', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                      Text('Admin: ${groupDetails['groupAdmin']}'),
                      Text('Location: ${groupDetails['location']}'),
                      SizedBox(height: 16.0),
                      if (qrDetails.isNotEmpty)
                        Center(
                          child: QrImageView(
                            data: qrDetails['qrData'],
                            version: QrVersions.auto,
                            size: 200.0,
                          ),
                        ),
                      SizedBox(height: 16.0),
                      Text('Attendance This Week:', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                      SizedBox(height: 200, child: _buildBarChart(presentCount, totalStudents)),
                      SizedBox(height: 16.0),
                      Text('Overall Attendance:', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                      SizedBox(height: 200, child: _buildPieChart(presentCount, totalStudents)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBarChart(int presentCount, int totalStudents) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(toY: presentCount.toDouble(), color: Colors.green),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(toY: (totalStudents - presentCount).toDouble(), color: Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(int presentCount, int totalStudents) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: presentCount.toDouble(),
            title: 'Present',
            color: Colors.green,
          ),
          PieChartSectionData(
            value: (totalStudents - presentCount).toDouble(),
            title: 'Absent',
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
