import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class Overview extends StatelessWidget {
  final String email;
  final String id;
  final String role;

  Overview({required this.email, required this.role, required this.id});

  final DatabaseReference databaseReference = FirebaseDatabase.instance.reference();

  Future<Map<String, dynamic>> getStudentStats() async {
    final String stdemail = email.replaceAll(RegExp(r'[.@]'), '');
    final studentGroupsEvent = await databaseReference.child('org/$id/students/$stdemail/groups').once();
    final studentGroups = (studentGroupsEvent.snapshot.value as Map<dynamic, dynamic>?) ?? {};

    Map<String, dynamic> studentStats = {};
    int overallPresentCount = 0;
    int overallTotalAttendance = 0;

    for (String groupId in studentGroups.keys) {
      final groupDetailsEvent = await databaseReference.child('org/$id/groups/$groupId/details').once();
      final groupDetails = groupDetailsEvent.snapshot.value as Map<dynamic, dynamic>? ?? {};

      int totalAttendance = 0;
      int presentCount = 0;
      for (int i = 0; i < 7; i++) {
        final date = DateFormat('yyyy-M-d').format(DateTime.now().subtract(Duration(days: i)));
        final attendanceEvent = await databaseReference.child('org/$id/groups/$groupId/attendance/$date/$stdemail').once();
        if (attendanceEvent.snapshot.value != null) {
          presentCount++;
        }
        totalAttendance++;
      }

      overallPresentCount += presentCount;
      overallTotalAttendance += totalAttendance;

      studentStats[groupId] = {
        'groupName': groupDetails['groupName'],
        'totalAttendance': totalAttendance,
        'presentCount': presentCount,
      };
    }

    studentStats['overallPresentCount'] = overallPresentCount;
    studentStats['overallTotalAttendance'] = overallTotalAttendance;

    return studentStats;
  }

  @override
  Widget build(BuildContext context) {
    final String stdemail = email.replaceAll(RegExp(r'[.@]'), '');
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder<Map<String, dynamic>>(
            future: getStudentStats(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final studentStats = snapshot.data ?? {};

              final overallPresentCount = studentStats['overallPresentCount'];
              final overallTotalAttendance = studentStats['overallTotalAttendance'];

              return ListView(
                children: [
                  Card(
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Student Profile',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text('Email: $stdemail'),
                          Text('Role: $role'),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Overall Attendance',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Present: $overallPresentCount days',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Absent: ${overallTotalAttendance - overallPresentCount} days',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 200, child: _buildPieChart(overallTotalAttendance, overallPresentCount)),
                        ],
                      ),
                    ),
                  ),
                  ...studentStats.keys.where((key) => key != 'overallPresentCount' && key != 'overallTotalAttendance').map((groupId) {
                    final groupName = studentStats[groupId]['groupName'];
                    final totalAttendance = studentStats[groupId]['totalAttendance'];
                    final presentCount = studentStats[groupId]['presentCount'];

                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ExpansionTile(
                        title: Text(
                          "Group: $groupName",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Attendance this week:",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 150, child: _buildBarChart(totalAttendance, presentCount)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(int totalAttendance, int presentCount) {
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
              BarChartRodData(toY: (totalAttendance - presentCount).toDouble(), color: Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(int totalAttendance, int presentCount) {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: presentCount.toDouble(),
            title: 'Present',
            color: Colors.green,
          ),
          PieChartSectionData(
            value: (totalAttendance - presentCount).toDouble(),
            title: 'Absent',
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
