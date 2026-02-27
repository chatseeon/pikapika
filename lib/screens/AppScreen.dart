import 'dart:async';
import 'package:pikapika/i18.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:pikapika/basic/config/Version.dart';
import 'package:pikapika/basic/config/WillPopNotice.dart';
import 'package:pikapika/screens/components/Badge.dart';
import 'package:pikapika/screens/components/TimeoutLock.dart';
import '../basic/Common.dart';
import 'CategoriesScreen.dart';
import 'SpaceScreen.dart';

// MAIN UI 底部导航栏
class AppScreen extends StatefulWidget {
  const AppScreen({Key? key}) : super(key: key);

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  late StreamSubscription<String?> _linkSubscription;

  @override
  void initState() {
    versionEvent.subscribe(_onVersion);
    _linkSubscription = linkSubscript(context);
    super.initState();
    Future.delayed(Duration.zero, () async {
      versionPop(context);
      versionEvent.subscribe(_versionSub);
    });
  }

  @override
  void dispose() {
    versionEvent.unsubscribe(_onVersion);
    _linkSubscription.cancel();
    versionEvent.unsubscribe(_versionSub);
    super.dispose();
  }

  _versionSub(_) {
    versionPop(context);
  }

  void _onVersion(dynamic a) {
    setState(() {});
  }

  static const List<Widget> _widgetOptions = <Widget>[
    CategoriesScreen(),
    SpaceScreen(),
  ];

  late int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = Scaffold(
      // 这里新增 Padding 来消费系统导航栏（navigation bar）的高度
      // 避免 Android edge-to-edge 模式下内容被底部手势条/虚拟键遮挡
      body: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.public),
            label: tr('app.categories'),
          ),
          BottomNavigationBarItem(
            icon: Badged(
              child: const Icon(Icons.face),
              badge: latestVersion() == null ? null : "1",
            ),
            label: tr('app.my'),
          ),
        ],
        currentIndex: _selectedIndex,
        iconSize: 20,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: _onItemTapped,
      ),
    );

    return TimeoutLock(child: willPop(body));
  }

  int _noticeTime = 0;

  Widget willPop(Scaffold body) {
    return WillPopScope(
      child: body,
      onWillPop: () async {
        if (willPopNotice()) {
          final now = DateTime.now().millisecondsSinceEpoch;
          if (_noticeTime + 3000 > now) {
            return true;
          } else {
            _noticeTime = now;
            showToast(
              tr("screen.app.will_pop_notice"),
              context: context,
              position: StyledToastPosition.center,
              animation: StyledToastAnimation.scale,
              reverseAnimation: StyledToastAnimation.fade,
              duration: const Duration(seconds: 3),
              animDuration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              reverseCurve: Curves.linear,
            );
            return false;
          }
        }
        return true;
      },
    );
  }
}
