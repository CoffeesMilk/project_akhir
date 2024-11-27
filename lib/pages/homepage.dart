import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:project_akhir/pages/listscanlation.dart';
import 'package:project_akhir/pages/mangabookmark.dart';
import 'package:project_akhir/pages/mangapage.dart';
import 'package:project_akhir/pages/mangasearch.dart';
import 'package:project_akhir/pages/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  int bottomnavselect = 0;
  late SharedPreferences logindata;
  Future<List<dynamic>> fetchManga() async {
    final apimanga = await Dio().get(
        'https://api.mangadex.org/manga?limit=10&includedTagsMode=AND&excludedTagsMode=AND&contentRating%5B%5D=safe&order%5BlatestUploadedChapter%5D=desc&includes%5B%5D=manga&includes%5B%5D=cover_art&includes%5B%5D=tag&hasAvailableChapters=true');

    if (apimanga.statusCode == 200) {
      return apimanga.data['data'];
    } else {
      throw Exception('Bad request');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchManga().then((data) {
      setState(() {
        mangalist = data;
      });
    });
    initial();
  }

  List<dynamic> mangalist = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: new Icon(Icons.bookmark, color: Colors.black),
            onPressed: () {
              logindata.setBool('login', false);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => mangabookmark()));
            },
          ),
          IconButton(
            icon: new Icon(Icons.search, color: Colors.black),
            onPressed: () {
              logindata.setBool('login', false);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => mangasearch()));
            },
          ),
        ],
        backgroundColor: Colors.blue,
      ),
      body: Container(
        child: Center(
            child: SingleChildScrollView(
          child: Column(
            children: mangalist.map((manga) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => mangapage(mangaid: manga['id']),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.all(10),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Image.network(
                          'https://uploads.mangadex.org/covers/${manga['id']}/${manga['relationships'].firstWhere((coverart) => coverart['type'] == 'cover_art')['attributes']['fileName']}',
                          width: 100,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${manga['attributes']['title']['en']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2),
                              Divider(
                                color: Colors.blue,
                              ),
                              Text(
                                'Status: ${manga['attributes']['status']}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              Text(
                                  'Tags: ${manga['attributes']['tags'].map((tag) => tag['attributes']['name']['en']).join(', ')}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2),
                            ],
                          ),
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
            icon: Icon(Icons.group),
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
