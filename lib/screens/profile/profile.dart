import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mac/common/constants.dart';
import 'package:flutter_mac/models/user.dart';
import 'package:flutter_mac/screens/image_preview.dart';
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

  @override
  void initState() {
    super.initState();
    viewModel = ProfileViewModel(uid: widget.uid);
    profile = viewModel.getProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 211, 21, 7),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 211, 21, 7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          color: Colors.white,
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              SystemNavigator.pop();
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: FutureBuilder(
            future: profile,
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
              return const SpinKitCircle(color: Colors.white);
            }),
      ),
    );
  }

  _getMainWidget(UserProfile data) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 130),
              height: 120,
              decoration: const BoxDecoration(color: Colors.white),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(20, 70, 20, 0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 191, 191, 191)
                        .withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 8), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                children: <Widget>[
                  Visibility(
                    visible: widget.edit,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: Container(
                      margin: const EdgeInsets.only(left: 330, top: 10),
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
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImagePreview(
                          imageUrl: data.profilePicture.isNotEmpty
                              ? data.profilePicture
                              : KeyConstants.samplePicture),
                    )),
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage: NetworkImage(data.profilePicture.isNotEmpty
                      ? data.profilePicture
                      : KeyConstants.samplePicture),
                )),
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
                        ))))
          ],
        ),
        Container(
          height: double.maxFinite,
          color: Colors.white,
        )
      ],
    );
  }

  void setProfilePicture() async {
    await viewModel.updateProfilePicture();
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
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (value) {}),
                        TextField(
                            controller: quoteController,
                            decoration: InputDecoration(
                                labelText: quote,
                                hintText: 'Quote',
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (value) {}),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: () {
                                  if (nameController.text.trim().isEmpty) {
                                  } else if (quoteController.text
                                      .trim()
                                      .isEmpty) {
                                  } else {
                                    setState(() {
                                      name = nameController.text.trim();
                                      quote = quoteController.text.trim();
                                      loading = true;
                                    });
                                    updateUserDetails(name, quote, context);
                                  }
                                },
                                child: Text('Update')),
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'))
                          ],
                        )
                      ],
                    ));
        }));
  }

  void updateUserDetails(
      String name, String quote, BuildContext context) async {
    await viewModel.updateUserDetails(name, quote);
    if (mounted) {
      Navigator.of(context).pop();
    }
    final v = viewModel.getProfile();
    setState(() {
      profile = v;
    });
  }
}
