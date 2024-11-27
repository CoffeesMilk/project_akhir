import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:project_akhir/pages/detailscanlation.dart';
import 'package:project_akhir/pages/homepage.dart';
import 'package:project_akhir/pages/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class listscanlation extends StatefulWidget {
  const listscanlation({super.key});

  @override
  State<listscanlation> createState() => _listscanlationState();
}

class _listscanlationState extends State<listscanlation> {
  int bottomnavselect = 1;
  late SharedPreferences logindata;
  Future<List<dynamic>> fetchscanlation() async {
    final apiscanlation = await Dio().get(
        'https://api.mangadex.org/group?limit=100&includes%5B%5D=leader&includes%5B%5D=member');

    if (apiscanlation.statusCode == 200) {
      return apiscanlation.data['data'];
    } else {
      throw Exception('Bad request');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchscanlation().then((data) {
      setState(() {
        scanlationlist = data;
      });
    });
    initial();
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
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

  List<dynamic> scanlationlist = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Scanlation'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Container(
        child: Center(
            child: SingleChildScrollView(
          child: Column(
            children: scanlationlist.map((list) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          detailscanlation(listid: list['id']),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.all(10),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${list['attributes']['name']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        )),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Scanlation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: bottomnavselect,
        selectedItemColor: Colors.white,
        onTap: _onitemselected,
      ),
    );
  }
}
