import 'package:flutter/material.dart';
import 'package:flutter_mac/models/user.dart';
import 'package:flutter_mac/navigator.dart';
import 'package:flutter_mac/preference/app_preference.dart';
import 'package:flutter_mac/services/auth_service.dart';
import 'package:flutter_mac/viewmodel/dashboard_view_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

class Dashboard extends StatefulWidget {
  final UserCred userCred;
  final AuthService _auth = AuthService();

  Dashboard({super.key, required this.userCred});

  @override
  State<Dashboard> createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  late DashboardViewModel _viewModel;
  AppColorPref _colorsPref = AppColorPref();

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel(widget.userCred);
    _getColorsPref();
  }

  @override
  void dispose() {
    super.dispose();
    _viewModel.dispose();
  }

  _getColorsPref() async {
    _viewModel.appColoPrefStream.listen((e) {
      setState(() => _colorsPref = e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _colorsPref.appBarColor,
        title: const Text('Dashboard'),
        leading: IconButton.filled(
            onPressed: () => ScreenNavigator.openProfileScreen(
                widget.userCred.uid, true, context),
            icon: const Icon(Icons.account_circle_rounded)),
        actions: [
          IconButton.filled(
              onPressed: () async {
                final value = await ScreenNavigator.openSettingsPage(
                    widget.userCred.uid, context);
                if (value != null && value) {
                  _viewModel.refresh();
                }
              },
              icon: const Icon(Icons.settings)),
          IconButton.filled(
              onPressed: () {
                widget._auth.signOut();
                _viewModel.signOut();
              },
              icon: const Icon(Icons.logout)),
        ],
      ),
      body: FutureBuilder(
        future: _viewModel.getUserList(),
        builder: ((context, snapshot) {
          return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  tileMode: TileMode.decal,
                  // stops: [4],
                  colors: [
                    _colorsPref.appBackgroundColor.first,
                    _colorsPref.appBackgroundColor.second
                  ],
                ),
              ),
              child: _getMainWidget(snapshot));
        }),
      ),
    );
  }

  _getMainWidget(AsyncSnapshot<List<UserProfile>> snapshot) {
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
          padding: const EdgeInsets.all(10),
          child: ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) =>
                _setListWidget(context, snapshot.data![index]),
          ),
        );
      }
    }
    return const Center(child: SpinKitCircle(color: Colors.white));
  }

  _setListWidget(BuildContext context, UserProfile profile) {
    return GestureDetector(
      onTap: () =>
          ScreenNavigator.openChatScreen(widget.userCred, profile, context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
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
