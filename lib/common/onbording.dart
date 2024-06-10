import 'package:flutter/material.dart';
import 'package:anti/pustaka.dart';

class Onbording extends StatefulWidget {
  const Onbording({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OnbordingState createState() => _OnbordingState();
}

class _OnbordingState extends State<Onbording> {
  PermissionService PermissionServices = PermissionService();

  int currentIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      Expanded(
        child: PageView.builder(
          controller: _controller,
          itemCount: contents.length,
          onPageChanged: (int index) {
            setState(() {
              currentIndex = index;
            });
          },
          itemBuilder: (_, i) {
            return Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(contents[i].images, width: 90, height: 90),
                  Center(
                    child:
                        Image.asset(contents[i].image, width: 240, height: 240),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        textAlign: TextAlign.center,
                        contents[i].title,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        textAlign: TextAlign.center,
                        contents[i].discription,
                        overflow: TextOverflow.visible,
                        softWrap: true,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      const SizedBox(height: 20),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
      // ignore: avoid_unnecessary_containers
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            contents.length,
            (index) => buildDot(index, context),
          ),
        ),
      ),
      const SizedBox(height: 20),
      Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
        child: Column(
          children: [
            TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                },
                child: const Text(
                  'Lewati',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                )),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFF96B12D),
                borderRadius: BorderRadius.all(Radius.circular(25)),
              ),
              child: TextButton(
                child: Text(
                  currentIndex == contents.length - 1
                      ? "Lanjutkan"
                      : "Lanjutkan",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                onPressed: () async {
                  switch (currentIndex) {
                    case 0:
                      await PermissionServices.requestNotificationPermission();
                      break;
                    case 1:
                      await PermissionServices.requestLocationPermission();
                      break;
                    case 2:
                      await PermissionServices.requestPhonePermission();
                      break;
                  }
                  if (currentIndex == contents.length - 1) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  }
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.bounceIn,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 40),
    ]));
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: currentIndex == index ? 25 : 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF96B12D),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
