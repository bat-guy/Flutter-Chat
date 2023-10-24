import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mac/common/text_with_icon.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // return Container(
    //   padding: const EdgeInsets.all(8),
    //   decoration: const BoxDecoration(color: Color.fromARGB(255, 210, 17, 3)),
    //   child: SafeArea(
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: [
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             GestureDetector(
    //               child: const Icon(
    //                 Icons.arrow_back_ios_new_outlined,
    //                 color: Colors.white,
    //               ),
    //               onTap: () {
    //                 if (Navigator.canPop(context)) {
    //                   Navigator.pop(context);
    //                 } else {
    //                   SystemNavigator.pop();
    //                 }
    //               },
    //             ),
    //             GestureDetector(
    //               child: const Icon(
    //                 Icons.logout_outlined,
    //                 color: Colors.white,
    //               ),
    //               onTap: () {},
    //             ),
    //           ],
    //         ),
    //         Stack(children: [
    //           Card(
    //               elevation: 2,
    //               color: Colors.white,
    //               child: Text(
    //                 'asdadhbasdhbasjdhab sjd ajsd ajs dcjaasdajs dajs ashcb akscn  asuhbcasucbua sbcu  ucbua sbcua sbcuay sbcuay bscuysbcuwhd bcuasd bcusdbcuadsbc iasbck scbkas bcias cbiasucb iasbcidbc iasdbciadsbcsiadcb skdc bsxncb skdxcbskdcbsidc bidbcaisucbqieycb wuevcwuec basicdaksm as camscasm ascasc',
    //                 style: TextStyle(color: Colors.black),
    //               )),
    //           Positioned(
    //             top: 0,
    //             child: Card(
    //               margin: const EdgeInsets.only(top: 40),
    //               elevation: 1,
    //               color: Colors.transparent,
    //               child: CachedNetworkImage(
    //                 imageUrl: 'asdasd',
    //                 imageBuilder: (context, imageProvider) => Container(
    //                   decoration: BoxDecoration(
    //                     image: DecorationImage(
    //                       image: imageProvider,
    //                       fit: BoxFit.cover,
    //                       colorFilter: const ColorFilter.mode(
    //                         Colors.red,
    //                         BlendMode.colorBurn,
    //                       ),
    //                     ),
    //                   ),
    //                 ),
    //                 placeholder: (context, url) => const Icon(
    //                   Icons.person,
    //                   color: Colors.white,
    //                   size: 100,
    //                 ),
    //                 errorWidget: (context, url, error) => const Icon(
    //                   Icons.person,
    //                   color: Colors.white,
    //                   size: 100,
    //                 ),
    //                 height: 100,
    //                 width: 100,
    //               ),
    //             ),
    //           ),
    //         ]),
    //       ],
    //     ),
    //   ),
    // );

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 211, 21, 7),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 211, 21, 7),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined),
          color: Colors.white,
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              SystemNavigator.pop();
            }
          },
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.logout_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 130),
                  height: 80,
                  decoration: const BoxDecoration(color: Colors.white),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 50, 20, 0),
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
                        offset: Offset(0, 8), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 50),
                      Text('John Doe', style: TextStyle(fontSize: 24)),
                      const SizedBox(height: 16),
                      Text('Some quote here',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                      'https://dfstudio-d420.kxcdn.com/wordpress/wp-content/uploads/2019/06/digital_camera_photo-980x653.jpg'), // replace with your image url
                ),
              ],
            ),
            Container(
              height: double.maxFinite,
              color: Colors.white,
            )
          ],
        ),
      ),
    );
  }
}
