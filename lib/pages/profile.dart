import 'package:flutter/material.dart';
import 'package:project_akhir/pages/listscanlation.dart';
import 'package:project_akhir/pages/loginpage.dart';
import 'package:project_akhir/pages/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class profile extends StatefulWidget {
  const profile({super.key});

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  String? username;
  int bottomnavselect = 2;
  late SharedPreferences logindata;

  @override
  void initState() {
    super.initState();
    initial();
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
    setState(() {
      username = logindata.getString('username');
    });
  }

  void _onitemselected(int index) {
    if (bottomnavselect == index) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => homepage()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => listscanlation()));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => profile()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          Text(
            '$username',
            style: TextStyle(color: Colors.black),
          ),
          IconButton(
            icon: new Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              logindata.setBool('login', true);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => loginpage()));
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/wahyu.jpg'),
                    ),
                    Text(
                      'Wahyu Widiasmoro',
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      'NIM : 124220126',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
              Card(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/wahyu.jpg'),
                    ),
                    Text(
                      'Azkal Azkia Akbar',
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      'NIM : 124220085',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Scanlation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        backgroundColor: Colors.blue,
        currentIndex: bottomnavselect,
        selectedItemColor: Colors.white,
        onTap: _onitemselected,
      ),
    );
  }
}
