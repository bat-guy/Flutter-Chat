import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mac/common/constants.dart';
import 'package:flutter_mac/models/user.dart';
import 'package:flutter_mac/navigator.dart';
import 'package:flutter_mac/preference/app_preference.dart';
import 'package:flutter_mac/preference/shared_preference.dart';
import 'package:flutter_mac/viewmodel/profile_view_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  final bool edit;
  const ProfileScreen({super.key, required this.uid, required this.edit});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileViewModel viewModel;
  late Future<UserProfile> profile;
  final _pref = AppPreference();
  AppColorPref _colorsPref = AppColorPref();
  var _loading = false;

  @override
  void initState() {
    super.initState();
    setViewModel();
    _getColorsPref();
  }

  void setViewModel() {
    viewModel = ProfileViewModel(uid: widget.uid, pref: _pref);
    viewModel.loadingStream.listen((e) {
      if (mounted) {
        setState(() => _loading = e);
      }
    });
    viewModel.toastStream.listen((e) {
      if (e.isNotEmpty) {
        if (Platform.isAndroid || Platform.isIOS) {
          BotToast.showText(text: e);
        } else {
          showDialog(
              context: context,
              builder: ((context) => AlertDialog(
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Okay'),
                      )
                    ],
                    content: Text(e),
                  )));
        }
      }
    });
    setProfile();
  }

  @override
  void dispose() {
    super.dispose();
    viewModel.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorsPref.appBarColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        height: double.maxFinite,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            tileMode: TileMode.mirror,
            // stops: [4],
            colors: [
              _colorsPref.appBackgroundColor.first,
              _colorsPref.appBackgroundColor.second
            ],
          ),
        ),
        child: FutureBuilder(
            future: viewModel.getProfile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '${snapshot.error} occurred',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                } else if (snapshot.hasData) {
                  return _getMainWidget(snapshot.data!);
                }
              }
              return const SpinKitHourGlass(color: Colors.white);
            }),
      ),
    );
  }

  _getMainWidget(UserProfile data) {
    return _loading
        ? const SpinKitHourGlass(color: Colors.white)
        : SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 70, 20, 0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 236, 238, 236),
                    borderRadius: BorderRadius.circular(20),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: const Color.fromARGB(255, 191, 191, 191)
                    //         .withOpacity(0.5),
                    //     spreadRadius: 1,
                    //     blurRadius: 4,
                    //     offset: const Offset(0, 8), // changes position of shadow
                    //   ),
                    // ],
                  ),
                  child: Column(
                    children: <Widget>[
                      Visibility(
                        visible: widget.edit,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: Container(
                          alignment: Alignment.centerRight,
                          margin: const EdgeInsets.only(top: 10, right: 10),
                          child: IconButton(
                            icon: const Icon(Icons.edit,
                                color: Color.fromARGB(255, 211, 21, 7)),
                            onPressed: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (ctx) => _buildDialog(ctx, data),
                              );
                            },
                          ),
                        ),
                      ),
                      Text(data.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text(data.quote),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => ScreenNavigator.openImagePreview(
                      data.profilePicture.isNotEmpty
                          ? data.profilePicture
                          : KeyConstants.samplePicture,
                      context),
                  child: CachedNetworkImage(
                    imageUrl: data.profilePicture.isNotEmpty
                        ? data.profilePicture
                        : KeyConstants.samplePicture,
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      radius: 55,
                      backgroundImage: imageProvider,
                    ),
                    placeholder: (context, url) => const CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 55,
                        child: SpinKitCircle(color: Colors.red)),
                    errorWidget: (context, url, error) => const CircleAvatar(
                        radius: 55, child: Icon(Icons.error)),
                  ),
                ),
                Visibility(
                  visible: widget.edit,
                  child: Container(
                    margin: const EdgeInsets.only(top: 78, left: 75),
                    child: CircleAvatar(
                      backgroundColor: const Color.fromARGB(255, 211, 21, 7),
                      child: IconButton(
                        onPressed: () => setProfilePicture(),
                        icon: const Icon(Icons.camera_alt_sharp),
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ));
  }

  void setProfilePicture() async {
    await viewModel.updateProfilePicture();
    setProfile();
  }

  _buildDialog(BuildContext ctx, UserProfile data) {
    var loading = false;
    var name = data.name;
    var quote = data.quote;
    final nameController = TextEditingController(text: name);
    final quoteController = TextEditingController(text: quote);
    return AlertDialog(
      title: const Text("Update Details"),
      content: StatefulBuilder(builder: (context, setState) {
        return Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(25)),
            ),
            child: loading
                ? const Column(mainAxisSize: MainAxisSize.min, children: [
                    SpinKitCircle(
                      color: Colors.red,
                      size: 150,
                    )
                  ])
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: name,
                            hintText: 'Name',
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (value) {}),
                      TextField(
                          controller: quoteController,
                          decoration: InputDecoration(
                            labelText: quote,
                            hintText: 'Quote',
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (value) {}),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              if (nameController.text.trim().isEmpty) {
                              } else if (quoteController.text.trim().isEmpty) {
                              } else {
                                setState(() {
                                  name = nameController.text.trim();
                                  quote = quoteController.text.trim();
                                  loading = true;
                                });
                                updateUserDetails(name, quote, context);
                              }
                            },
                            child: const Text('Update'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          )
                        ],
                      )
                    ],
                  ));
      }),
    );
  }

  _getColorsPref() async {
    var a = await _pref.getAppColorPref();
    setState(() => _colorsPref = a);
  }

  void updateUserDetails(
      String name, String quote, BuildContext context) async {
    await viewModel.updateUserDetails(name, quote);
    if (mounted) {
      Navigator.of(context).pop();
    }
    setProfile();
  }

  void setProfile() {
    final v = viewModel.getProfile();
    setState(() {
      profile = v;
    });
  }
}
