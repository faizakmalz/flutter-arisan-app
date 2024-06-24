import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pmob/pages/category.dart';
import 'package:pmob/pages/homepage.dart';
import 'package:pmob/pages/transactionPage.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  late DateTime selectedDate;
  late List<Widget> _children;
  late int currentIndex;

  @override
  void initState() {
    // TODO: implement initState
    updateView(0, DateTime.now());
    super.initState();
  }

  void updateView(int index, DateTime? date) {
    setState(() {
      if (date != null) {
        selectedDate = DateTime.parse(DateFormat('yyyy-MM-dd').format(date));
      }

      currentIndex = index;
      _children = [HomePage(selectedDate: selectedDate), CategoryPage()];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (currentIndex == 0)
          ? CalendarAppBar(
              accent: Colors.blue,
              backButton: false,
              locale: 'id',
              onDateChanged: (value) {
                print('selected Date' + value.toString());
                setState(() {});
                selectedDate = value;
                updateView(0, selectedDate);
              },
              firstDate: DateTime.now().subtract(Duration(days: 140)),
              lastDate: DateTime.now(),
            )
          : PreferredSize(
              preferredSize: Size.fromHeight(200),
              child: Container(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 70, horizontal: 16),
                  child: Text(
                    'Nama',
                    style: GoogleFonts.montserrat(fontSize: 20),
                  ),
                ),
              )),
      floatingActionButton: Visibility(
        visible: (currentIndex == 0) ? true : false,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(
              builder: (context) => Transactionpage(
                transactionWithCategory: null,
              ),
            ))
                .then((value) {
              setState(() {});
            });
          },
          backgroundColor: Colors.blue,
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
      body: _children[currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: () {
                  updateView(0, DateTime.now());
                },
                icon: Icon(Icons.home)),
            SizedBox(
              width: 20,
            ),
            IconButton(
                onPressed: () {
                  updateView(1, null);
                },
                icon: Icon(Icons.list))
          ],
        ),
      ),
    );
  }
}
