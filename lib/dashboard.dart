
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thesocialmeet/screens/first.dart';
import 'package:thesocialmeet/screens/account.dart';
import 'package:thesocialmeet/screens/second.dart';
import 'package:thesocialmeet/screens/chat.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {


  TextEditingController editingControllerPopMenu = TextEditingController();
  TextEditingController editingControllerMyList = TextEditingController();

  TextEditingController txtTimeController1 = TextEditingController();
  TextEditingController txtTimeController2 = TextEditingController();

  late TextEditingController emailL;
  late TextEditingController hasloL;
  late TextEditingController nameR;
  late TextEditingController emailR;
  late TextEditingController hasloR;
  late TextEditingController hasloReset;

  bool isSignUp = true;
  bool clickLogin = false;
  bool isHoverReset = false;
  bool isVisible = true;

  int selIndex = 0;

  final screens = const [
   // FirstPage(),
   // SecondPage(),
    ChatPage(),
    AccountPage(),
  ];


  @override
  void initState() {
    super.initState();
    emailL = TextEditingController();
    hasloL = TextEditingController();
    emailR = TextEditingController();
    hasloR = TextEditingController();
    nameR = TextEditingController();
    hasloReset = TextEditingController();
  }

  @override
  void dispose() {
    emailL.dispose();
    hasloL.dispose();
    emailR.dispose();
    hasloR.dispose();
    nameR.dispose();
    hasloReset.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
//    final localeProvider = Provider.of<LanguageChangeProvider>(context);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return  PopScope(
      canPop: false,
      child: Scaffold(
        bottomNavigationBar: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: Colors.transparent,
            shadowColor: null,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            labelTextStyle: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return TextStyle(color: Colors.purple[700]);
              }
              return const TextStyle(color: Colors.black54 );
            }),
          ),
          child: NavigationBar(
            backgroundColor: Colors.white,
            height: 55,
          selectedIndex: selIndex,
          animationDuration: const Duration(milliseconds: 1100),
          onDestinationSelected: (selIndex) => setState(() => this.selIndex = selIndex),
          destinations: [
             NavigationDestination(icon: Icon(Icons.chat_bubble_outline, color: selIndex == 0 ? Colors.purple[700] : Colors.black54 ), label: "Chat",),
             NavigationDestination(icon: Icon(Icons.account_circle_outlined, color: selIndex == 1 ? Colors.purple[700] : Colors.black54 ), label: "Profile"),

            // NavigationDestination(icon: Icon(Icons.dashboard_outlined, color: selIndex == 0 ? Colors.purple[700] : Colors.black54 ), label: "List"),
            // NavigationDestination(icon: Icon(Icons.info_outline, color: selIndex == 1 ? Colors.purple[700] : Colors.black54 ), label: "Info"),
            // NavigationDestination(icon: Icon(Icons.chat_bubble_outline, color: selIndex == 2 ? Colors.purple[700] : Colors.black54 ), label: "Chat",),
            // NavigationDestination(icon: Icon(Icons.account_circle_outlined, color: selIndex == 3 ? Colors.purple[700] : Colors.black54 ), label: "Profile"),
          ],
        ),),
        body: screens[selIndex],
      ),
    );
  }
}













