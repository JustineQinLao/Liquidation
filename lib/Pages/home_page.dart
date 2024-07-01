import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:liquidapp/Constants/ui.dart';
import 'package:liquidapp/Pages/liquidation.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int active = 0;

  final List<Widget> nav_items = [
    const Icon(Icons.home),
    const Icon(Icons.dashboard),
    const Icon(Icons.settings)

  ];

  final List<Widget> pages = [
    Container(),
    Liquid(),
    Container()
  ];
  
  

  @override
  Widget build(BuildContext context) {
     final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.bg,

      body: pages[active],

      bottomNavigationBar: CurvedNavigationBar(
        // backgroundColor: active == 1 ? Color.fromARGB(255, 233, 232, 232) : Colors.white,
        backgroundColor: AppColors.bg,
        color: AppColors.cream,
        buttonBackgroundColor: AppColors.cream,
        height: height * 0.06,
        items: nav_items,
        animationDuration: const Duration(milliseconds: 300),
        
        onTap: (index) {
         setState((){
          active = index;
         });
        },
      ),
    );
  
  }
}
