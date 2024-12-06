import 'package:flutter/material.dart';

// Define a constant for default padding
const double kDefaultPadding = 20.0;

// User model to hold user information
class User {
  final String name;
  final String role;
  final String profileImagePath;

  User({
    required this.name,
    required this.role,
    required this.profileImagePath,
  });
}

// HomeScreen widget
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final User currentUser = User(
    name: "Rival",
    role: "Fullstack Developer",
    profileImagePath: 'assets/images/profile.jpg',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR S&G', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              // Handle settings action
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserProfileHeader(user: currentUser),
            const SizedBox(height: 20),
            const Text("Welcome to", style: TextStyle(fontSize: 20)),
            const Text(
              "QR S&G",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(10),
                children: [
                  BuildButton(
                    icon: Icons.qr_code,
                    label: 'Create',
                    iconColor: Colors.white,
                    backgroundColor: Colors.blueAccent,
                    onTap: () {
                      Navigator.pushNamed(context, '/create');
                    },
                  ),
                  BuildButton(
                    icon: Icons.qr_code_scanner,
                    label: 'Scan',
                    iconColor: Colors.white,
                    backgroundColor: Colors.redAccent,
                    onTap: () {
                      Navigator.pushNamed(context, '/scan');
                    },
                  ),
                  BuildButton(
                    icon: Icons.send,
                    label: 'Send',
                    iconColor: Colors.white,
                    backgroundColor: Colors.greenAccent,
                    onTap: () {
                      // Handle send action
                    },
                  ),
                  BuildButton(
                    icon: Icons.print,
                    label: 'Print',
                    iconColor: Colors.white,
                    backgroundColor: Colors.purpleAccent,
                    onTap: () {
                      // Handle print action
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// UserProfileHeader widget
class UserProfileHeader extends StatelessWidget {
  const UserProfileHeader({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage(user.profileImagePath),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, ${user.name}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              user.role,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        )
      ],
    );
  }
}

// BuildButton widget
class BuildButton extends StatelessWidget {
  const BuildButton({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor = Colors.black,
    this.backgroundColor = Colors.white,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(20),
              child: Icon(
                icon,
                color: iconColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
