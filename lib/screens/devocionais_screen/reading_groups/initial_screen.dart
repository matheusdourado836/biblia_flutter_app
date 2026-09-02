import 'package:biblia_flutter_app/data/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.getLoggedUser().whenComplete(() {
        if(userProvider.currentUser == null) {
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, 'login_screen');
        }else {
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, 'user_home_screen');
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: null,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}