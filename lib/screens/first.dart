
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => FirstPageState();
}

class FirstPageState extends State<FirstPage> {


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
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Colors.yellow,
        ),
      ),
    );
  }
}













