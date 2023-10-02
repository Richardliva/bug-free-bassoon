import 'package:flutter/material.dart';
import 'package:petrol_app_mtaani_tech/provider/auth_provider.dart';
import 'package:petrol_app_mtaani_tech/provider/data_provider.dart';
import 'package:petrol_app_mtaani_tech/screens/home/normal_home.dart';
import 'package:petrol_app_mtaani_tech/screens/liveStats/live_stats.dart';
import 'package:petrol_app_mtaani_tech/screens/scan/mobile_scan.dart';
import 'package:petrol_app_mtaani_tech/screens/search/search_cloud.dart';
import 'package:petrol_app_mtaani_tech/screens/welcome_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  BottomNavigationBarType _bottomNavType = BottomNavigationBarType.fixed;
  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    dataProvider.getLiveStatsFromFirestore();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 90, 5),
        title: Text("Welcome ${ap.userModel.name}"),
        actions: [
          IconButton(
            onPressed: () {
              ap.userSignOut().then(
                    (value) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WelcomeScreen(),
                      ),
                    ),
                  );
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: _navBarItems[_selectedIndex].label == 'Home'
          ? NormalHome(
              ap: ap, selectedIndex: _selectedIndex, navBarItems: _navBarItems)
          : _navBarItems[_selectedIndex].label == 'Scan'
              ? QRSCan()
              : _navBarItems[_selectedIndex].label == 'Search'
                  ? SearchCloud()
                  : _navBarItems[_selectedIndex].label == 'Live Stats'
                      ? LiveStats()
                      : Text('wtf'),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Color.fromARGB(255, 8, 85, 1),
          unselectedItemColor: const Color(0xff757575),
          type: _bottomNavType,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: _navBarItems),
    );
  }
}

const _navBarItems = [
  BottomNavigationBarItem(
    icon: Icon(Icons.home_outlined),
    activeIcon: Icon(Icons.home_rounded),
    label: 'Home',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.qr_code_scanner_outlined),
    activeIcon: Icon(Icons.qr_code_scanner),
    label: 'Scan',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.search_outlined),
    activeIcon: Icon(Icons.search),
    label: 'Search',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.stacked_line_chart_outlined),
    activeIcon: Icon(Icons.stacked_line_chart_rounded),
    label: 'Live Stats',
  ),
];
