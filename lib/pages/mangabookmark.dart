import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:project_akhir/models/boxes.dart';
import 'package:project_akhir/pages/mangapage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class mangabookmark extends StatefulWidget {
  const mangabookmark({super.key});

  @override
  State<mangabookmark> createState() => _mangabookmarkState();
}

class _mangabookmarkState extends State<mangabookmark> {
  late SharedPreferences logindata;

  @override
  void initState() {
    super.initState();
    initial();
    fetchfavorite();
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
  }

  void fetchfavorite() async {
    final box = await Hive.openBox(HiveBoxex.user);
    final currentuser = box.get(logindata.getString('username'));
    if (currentuser != null) {
      List<dynamic> favoritemanga = [];
      for (String id in currentuser.like) {
        final response = await Dio().get(
            'https://api.mangadex.org/manga?limit=10&includedTagsMode=AND&excludedTagsMode=OR&status%5B%5D=ongoing&status%5B%5D=completed&status%5B%5D=hiatus&status%5B%5D=cancelled&publicationDemographic%5B%5D=shounen&publicationDemographic%5B%5D=shoujo&publicationDemographic%5B%5D=josei&publicationDemographic%5B%5D=seinen&publicationDemographic%5B%5D=none&ids%5B%5D=$id&contentRating%5B%5D=safe&includes%5B%5D=cover_art');
        if (response.statusCode == 200) {
          favoritemanga.add(response.data['data'].first);
        }
      }
      setState(() {
        listmangafav = favoritemanga;
      });
    }
  }

  List<dynamic> listmangafav = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Manga'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
            child: SingleChildScrollView(
          child: Column(
            children: listmangafav.map((manga) {
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
    );
  }
}
