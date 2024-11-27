import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:project_akhir/models/boxes.dart';
import 'package:project_akhir/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class mangapage extends StatefulWidget {
  final String mangaid;
  const mangapage({super.key, required this.mangaid});

  @override
  State<mangapage> createState() => _mangapageState();
}

class _mangapageState extends State<mangapage> {
  bool favorite = false;
  String _dropdownvalue = 'ORI';
  late SharedPreferences logindata;
  Future<Map<String, dynamic>> fetchManga() async {
    final response = await Dio().get(
        'https://api.mangadex.org/manga/${widget.mangaid}?includes%5B%5D=cover_art&includes%5B%5D=author');

    if (response.statusCode == 200) {
      return response.data['data'] as Map<String, dynamic>;
    } else {
      throw Exception('Bad request');
    }
  }

  Map<String, dynamic> manga = {};

  @override
  void initState() {
    super.initState();
    fetchManga().then((data) {
      setState(() {
        manga = data;
      });
    });
    initial();
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
  }

  void addfav() async {
    final box = await Hive.openBox(HiveBoxex.user);
    final currentuser = box.get(logindata.getString('username'));
    if (currentuser != null) {
      currentuser.like.add(widget.mangaid);
    } else {
      box.put(logindata.getString('username'), user(like: [widget.mangaid]));
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Menambahkan ke favorit')),
    );
  }

  void removefav() async {
    final box = await Hive.openBox(HiveBoxex.user);
    final currentuser = box.get(logindata.getString('username'));
    if (currentuser != null) {
      currentuser.like.remove(widget.mangaid);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Menghapus dari favorit')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manga'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(15),
                child: Image.network(
                  'https://uploads.mangadex.org/covers/${widget.mangaid}/${manga['relationships'].firstWhere((coverart) => coverart['type'] == 'cover_art')['attributes']['fileName']}',
                  width: 250,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                child: Text(
                  '${manga['attributes']['title']['en']}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
              Text('Status: ${manga['attributes']['status']}'),
              FutureBuilder(
                future: Hive.openBox(HiveBoxex.user),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    final box = snapshot.data as Box;
                    final currentuser =
                        box.get(logindata.getString('username'));
                    if (currentuser != null &&
                        currentuser.like.contains(widget.mangaid)) {
                      favorite = true;
                    }
                    return IconButton(
                      onPressed: () {
                        setState(() {
                          favorite = !favorite;
                          if (favorite) {
                            addfav();
                          } else {
                            removefav();
                          }
                        });
                      },
                      icon: favorite
                          ? Icon(Icons.favorite)
                          : Icon(Icons.favorite_border),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
              DropdownButton<String>(
                value: _dropdownvalue,
                style: const TextStyle(color: Colors.blue),
                underline: Container(
                  height: 2,
                  color: Colors.blue,
                ),
                onChanged: (String? newvalue) {
                  setState(() {
                    _dropdownvalue = newvalue!;
                  });
                },
                items: [
                  DropdownMenuItem<String>(
                    value: 'ORI',
                    child:
                        Text('CreatedAt: ${manga['attributes']['createdAt']}'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'WIB',
                    child: Text(
                        'CreatedAt (WIB): ${DateTime.parse(manga['attributes']['createdAt']).toLocal()}'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'WITA',
                    child: Text(
                        'CreatedAt (WITA): ${DateTime.parse(manga['attributes']['createdAt']).toUtc().add(Duration(hours: 8))}'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'WIT',
                    child: Text(
                        'CreatedAt (WIT): ${DateTime.parse(manga['attributes']['createdAt']).toUtc().add(Duration(hours: 9))}'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'London',
                    child: Text(
                        'CreatedAt (London): ${DateTime.parse(manga['attributes']['createdAt']).toUtc()}'),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(15),
                child: Text(
                  '${manga['attributes']['description']['en']}',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
