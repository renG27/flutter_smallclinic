import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_smallclinic/screens/admin/admin_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to SmallClinic'),
      ),
      body: InkWell(
        onLongPress: () {
           Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminScreen()));
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).go('/doctor'); // Navigate to Doctor screen
                },
                child: const Text("I'm a Doctor"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).go('/patient'); // Navigate to Patient screen
                },
                child: const Text("I'm a Patient"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}