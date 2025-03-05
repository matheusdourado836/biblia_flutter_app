import 'package:biblia_flutter_app/data/reading_groups_provider.dart';
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
      final groupsProvider = Provider.of<ReadingGroupsProvider>(context, listen: false);
      groupsProvider.getUser().whenComplete(() {
        if(groupsProvider.currentUser == null) {
          Navigator.pushReplacementNamed(context, 'login_screen');
        }else {
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