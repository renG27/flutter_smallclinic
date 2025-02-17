import 'package:flutter/material.dart';
import 'package:flutter_smallclinic/screens/welcome/welcome_screen.dart';
import 'package:flutter_smallclinic/services/database_helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_smallclinic/providers/queue_provider.dart';
import 'package:flutter_smallclinic/services/notification_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_smallclinic/screens/doctor/queue_screen.dart';
import 'package:flutter_smallclinic/screens/patient/patient_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final DatabaseHelper dbHelper = DatabaseHelper();
  await dbHelper.initializeDatabase();

  final LocalNotificationService localNotificationService = LocalNotificationService();
  await localNotificationService.initialize();
  await localNotificationService.requestPermissions();

  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const WelcomeScreen();
        },
      ),
      GoRoute(
        path: '/doctor',
        builder: (BuildContext context, GoRouterState state) {
          return const DoctorQueueScreen(); // Doctor's queue screen
        },
      ),
      GoRoute(
        path: '/patient',
        builder: (BuildContext context, GoRouterState state) {
          return const PatientScreen(); // Patient's main screen
        },
      ),
    ],
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => QueueProvider(
            dbHelper: dbHelper,
            localNotificationService: localNotificationService,
          ),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: _router,
        title: 'SmallClinic',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
      ),
    ),
  );
}