import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:project_akhir/pages/mangapage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class mangasearch extends StatefulWidget {
  const mangasearch({super.key});

  @override
  State<mangasearch> createState() => _mangasearchState();
}

class _mangasearchState extends State<mangasearch> {
  String search = '';
  String search_controler = '';
  int bottomnavselect = 0;
  late SharedPreferences logindata;

  Future<List<dynamic>> fetchmanga() async {
    final apimanga = await Dio().get(
        'https://api.mangadex.org/manga?limit=10&title=$search&status%5B%5D=ongoing&status%5B%5D=completed&status%5B%5D=hiatus&status%5B%5D=cancelled&publicationDemographic%5B%5D=shounen&publicationDemographic%5B%5D=shoujo&publicationDemographic%5B%5D=josei&publicationDemographic%5B%5D=seinen&contentRating%5B%5D=safe&order%5BlatestUploadedChapter%5D=desc&includes%5B%5D=cover_art');

    if (apimanga.statusCode == 200) {
      return apimanga.data['data'];
    } else {
      throw Exception('Bad request');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchmanga().then((data) {
      setState(() {
        mangalist = data;
      });
    });
    initial();
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
  }

  List<dynamic> mangalist = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Container(
            margin:
                EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 10),
            child: TextFormField(
              onChanged: (value) {
                setState(() {
                  search = value;
                  fetchmanga().then((data) {
                    setState(() {
                      mangalist = data;
                    });
                  });
                });
              },
              decoration: InputDecoration(
                suffix: IconButton(
                    onPressed: () {}, icon: Icon(Icons.arrow_forward)),
                filled: true,
                label: Container(
                  width: 100,
                  child: Row(
                    children: [
                      Icon(Icons.search),
                      Text('Search'),
                    ],
                  ),
                ),
                contentPadding: EdgeInsets.all(8.0),
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0))),
              ),
            ),
          ),
          Expanded(
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
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
        ],
      ),
    );
  }
}
