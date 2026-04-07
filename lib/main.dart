import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Career Navigator',
      theme: ThemeData.dark().copyWith(useMaterial3: true),
      home: const RegistrationPage(),
    );
  }
}

// ================== PAGE 1 ==================
class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  final Color primaryCyan = const Color(0xFF00E5FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background/bg2.png'),
                fit: BoxFit.cover,
                opacity: 0.5,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildGlassForm(),
                    const SizedBox(height: 20),

                    // 🔥 SIGN IN LINK
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(color: Colors.white70),
                        ),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Navigate to Sign In screen"),
                              ),
                            );
                          },
                          child: Text(
                            "Sign In",
                            style: TextStyle(
                              color: primaryCyan,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: const [
        Icon(Icons.explore, size: 60, color: Color(0xFF00E5FF)),
        Text(
          'CAREER NAVIGATOR',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text("Create your account", style: TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _buildGlassForm() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildGoogleButton(),
                const SizedBox(height: 20),

                _buildTextField(Icons.email, "Email"),
                const SizedBox(height: 15),

                _buildTextField(Icons.lock, "Password", isPassword: true),
                const SizedBox(height: 15),

                _buildTextField(
                  Icons.lock_outline,
                  "Confirm Password",
                  isPassword: true,
                ),

                const SizedBox(height: 25),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileSetupPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryCyan,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text("CONTINUE"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String label, {
    bool isPassword = false,
  }) {
    return TextFormField(
      obscureText: isPassword && _obscurePassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primaryCyan),
        labelText: label,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.g_mobiledata, color: Colors.white),
      label: const Text(
        "Continue with Google",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

// ================== PAGE 2 ==================
class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  final Color primaryCyan = const Color(0xFF00E5FF);

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "Complete Your Profile",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // 🔥 PROFILE IMAGE PICKER
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white10,
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null
                    ? Icon(Icons.camera_alt, color: primaryCyan, size: 40)
                    : null,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Tap to upload profile picture",
              style: TextStyle(color: Colors.white54),
            ),

            const SizedBox(height: 30),

            TextFormField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Full Name",
                prefixIcon: Icon(Icons.person, color: primaryCyan),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextFormField(
              readOnly: true,
              onTap: () => showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
              ),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Date of Birth",
                prefixIcon: Icon(Icons.calendar_today, color: primaryCyan),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryCyan,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 55),
              ),
              child: const Text("FINISH REGISTRATION"),
            ),
          ],
        ),
      ),
    );
  }
}
