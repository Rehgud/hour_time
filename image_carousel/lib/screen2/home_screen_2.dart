import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({Key? key}) : super(key: key);

  @override
  State<HomeScreen2> createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> {
  Timer? timer;
  PageController controller = PageController(
    initialPage: 0, // 첫 번쨰 사진부터 시작한다.
  );

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      int currentPage = controller.page!.toInt();
      int nextPage = currentPage + 1;

      if (nextPage > 4) {
        // 5번 인덱스는 존재하지 않기 때문
        nextPage = 0;
      }

      controller.animateToPage(
          nextPage, duration: Duration(milliseconds: 400),
          curve: Curves.linear,);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    if (timer != null) {
      timer!.cancel(); // home_screen_2의 화면이 종료되면 타이머 즉, 이미지 로테이션이 중지된다.
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark); // system bar = dark 테마

    return Scaffold(
      body: PageView(
        controller: controller,
        children: [1, 2, 3, 4, 5].map(
              (e) =>
              Image.asset(
                'asset2/img/image_$e.jpeg',
                fit: BoxFit.cover,
              ),
        ).toList(),
      ),
    );
  }
}
