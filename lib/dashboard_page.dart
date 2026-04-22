import 'package:flutter/material.dart';

void main() {
  runApp(CareerApp());
}

class CareerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Dashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Dashboard extends StatelessWidget {

  Widget buildCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 5,
      child: ListTile(
        leading: Icon(icon, color: color, size: 40),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CareerNavigator Dashboard"),
      ),

      body: ListView(
        padding: EdgeInsets.all(10),
        children: [

          buildCard("Resume Score", "75%", Icons.description, Colors.blue),

          buildCard("Job Matches", "12 Jobs Found", Icons.work, Colors.green),

          buildCard("Skill Progress", "3 Skills Improving", Icons.bar_chart, Colors.orange),

          buildCard("Upcoming Interviews", "2 Scheduled", Icons.schedule, Colors.purple),

          buildCard("Mentorship", "1 Mentor Connected", Icons.people, Colors.red),

        ],
      ),
    );
  }
}
