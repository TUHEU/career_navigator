import 'package:flutter/material.dart';

class JobSeekerProfileScreen extends StatefulWidget {
  @override
  _JobSeekerProfileScreenState createState() =>
      _JobSeekerProfileScreenState();
}

class _JobSeekerProfileScreenState extends State<JobSeekerProfileScreen> {

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController skillsController = TextEditingController();
  TextEditingController goalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("JobSeeker Profile"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),

            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),

            TextField(
              controller: skillsController,
              decoration: InputDecoration(labelText: "Skills"),
            ),

            TextField(
              controller: goalController,
              decoration: InputDecoration(labelText: "Career Goal"),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                print(nameController.text);
                print(emailController.text);
                print(skillsController.text);
                print(goalController.text);
              },
              child: Text("Save Profile"),
            )
          ],
        ),
      ),
    );
  }
}