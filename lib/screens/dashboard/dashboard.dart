import 'package:flutter/material.dart';
import 'package:flutter_mac/models/user.dart';
import 'package:flutter_mac/navigator.dart';
import 'package:flutter_mac/services/auth_service.dart';
import 'package:flutter_mac/viewmodel/dashboard_view_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

class Dashboard extends StatefulWidget {
  final UserCred user;
  final AuthService _auth = AuthService();

  Dashboard({super.key, required this.user});

  @override
  State<Dashboard> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  late DashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel(widget.user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          leading: IconButton.filled(
              onPressed: () => ScreenNavigator.openProfileScreen(
                  widget.user.uid, true, context),
              icon: const Icon(Icons.account_circle_rounded)),
          actions: [
            IconButton.filled(
                onPressed: () {
                  widget._auth.signOut();
                },
                icon: const Icon(Icons.logout)),
          ],
        ),
        body: FutureBuilder(
            future: _viewModel.getUserList(),
            builder: ((context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '${snapshot.error} occurred',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                } else if (snapshot.hasData) {
                  return Container(
                      width: double.maxFinite,
                      margin: const EdgeInsets.all(10),
                      child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) =>
                              _setListWidget(context, snapshot.data![index])));
                }
              }
              return const SpinKitCircle(color: Colors.white);
            })));
  }

  _setListWidget(BuildContext context, UserProfile profile) {
    return GestureDetector(
      onTap: () => ScreenNavigator.openChatScreen(widget.user.uid, context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.all(Radius.circular(5))),
        child: Text(
          profile.name,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
