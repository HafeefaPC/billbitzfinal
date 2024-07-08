import 'package:billbitzfinal/presentation/screens/add_transaction.dart';
import 'package:billbitzfinal/presentation/screens/category_screen.dart';
import 'package:billbitzfinal/presentation/screens/home.dart';
import 'package:billbitzfinal/presentation/screens/search_screen.dart';
import 'package:billbitzfinal/presentation/screens/statistic.dart';
import 'package:flutter/material.dart';

class Bottom extends StatefulWidget {
  const Bottom({super.key});

  @override
  State<Bottom> createState() => _BottomState();
}

class _BottomState extends State<Bottom> {
  int selectedIndex = 0;
  final List<Widget> screens = [
    const Home(),
    const Statistics(),
    const CategoryScreen(),
    const SearchScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddScreen(extractedText: '')),
          );
        },
        backgroundColor: const Color(0xFF0D47A1),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                child: GestureDetector(
                  onTap: () => onTabTapped(0),
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.home,
                      size: 30,
                      color: selectedIndex == 0 ? const Color(0xFF64B5F6) : Colors.grey,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: GestureDetector(
                  onTap: () => onTabTapped(1),
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.bar_chart_outlined,
                      size: 30,
                      color: selectedIndex == 1 ? const Color(0xFF64B5F6) : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20), // Add space for FloatingActionButton
              Flexible(
                child: GestureDetector(
                  onTap: () => onTabTapped(2),
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.category_outlined,
                      size: 30,
                      color: selectedIndex == 2 ? const Color(0xFF64B5F6) : Colors.grey,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: GestureDetector(
                  onTap: () => onTabTapped(3),
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.search_outlined,
                      size: 30,
                      color: selectedIndex == 3 ? const Color(0xFF64B5F6) : Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: screens[selectedIndex],
    );
  }
}
