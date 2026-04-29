import 'package:flutter/material.dart';
import 'job_seeker_dashboard2.dart';
import 'mentor_dashboard.dart';

class RoleSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Role")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobSeekerDashboard(),
                ),
              );
            },
            child: Text("Job Seeker"),
          ),

          SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MentorDashboard(),
                ),
              );
            },
            child: Text("Mentor"),
          ),
        ],
      ),
    );
  }
}