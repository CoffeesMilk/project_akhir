import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class detailscanlation extends StatefulWidget {
  final String listid;
  const detailscanlation({super.key, required this.listid});

  @override
  State<detailscanlation> createState() => _detailscanlationState();
}

class _detailscanlationState extends State<detailscanlation> {
  double input_controler = 0;
  String _dropdownvalue = 'IDR';
  late SharedPreferences logindata;

  Future<Map<String, dynamic>> fetchdetail() async {
    final response = await Dio().get(
        'https://api.mangadex.org/group/${widget.listid}?includes%5B%5D=leader&includes%5B%5D=member');

    if (response.statusCode == 200) {
      return response.data['data'] as Map<String, dynamic>;
    } else {
      throw Exception('Bad request');
    }
  }

  Future<Map<String, dynamic>> fetchconvert() async {
    final convert = await Dio().get(
        'https://v6.exchangerate-api.com/v6/92577223aaf39bac1197358a/latest/IDR');

    if (convert.statusCode == 200) {
      return convert.data['conversion_rates'] as Map<String, dynamic>;
    } else {
      throw Exception('Bad request');
    }
  }

  Map<String, dynamic> detail = {};
  Map<String, dynamic> converstion = {};

  @override
  void initState() {
    super.initState();
    fetchdetail().then((data) {
      setState(() {
        detail = data;
      });
    });
    fetchconvert().then((data) {
      setState(() {
        converstion = data;
      });
    });
    initial();
    notif();
  }

  void notif() async {
    var androidsetting = new AndroidInitializationSettings('@mipmap/logo');

    var initialsetting = new InitializationSettings(android: androidsetting);

    await flutterLocalNotificationsPlugin.initialize(initialsetting);
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
  }

  static Future shownotif(
      {var id = 0,
      required String title,
      required String body,
      var payload,
      required FlutterLocalNotificationsPlugin fln}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      importance: Importance.max,
      priority: Priority.high,
    );
    var not = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, not);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donasi'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  '${detail['attributes']['name']}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                margin: EdgeInsetsDirectional.symmetric(
                    horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        onChanged: (value) {
                          setState(() {
                            input_controler = double.tryParse(value) ?? 0;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          contentPadding: EdgeInsets.all(8.0),
                          border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0))),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _dropdownvalue,
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
                          value: 'IDR',
                          child: Text('IDR'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'USD',
                          child: Text('USD'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'EUR',
                          child: Text('EUR'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'JPY',
                          child: Text('JPY'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'GBP',
                          child: Text('GBP'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'KRW',
                          child: Text('KRW'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsetsDirectional.symmetric(
                    horizontal: 20, vertical: 10),
                child: Text(
                  _dropdownvalue == 'IDR'
                      ? 'Rp: ${(input_controler * (converstion['IDR'])).toStringAsFixed(2)}'
                      : _dropdownvalue == 'USD'
                          ? '\$: ${(input_controler * (converstion['USD'])).toStringAsFixed(2)}'
                          : _dropdownvalue == 'EUR'
                              ? '€: ${(input_controler * (converstion['EUR'])).toStringAsFixed(2)}'
                              : _dropdownvalue == 'JPY'
                                  ? '¥: ${(input_controler * (converstion['JPY'])).toStringAsFixed(2)}'
                                  : _dropdownvalue == 'GBP'
                                      ? '£: ${(input_controler * (converstion['GBP'])).toStringAsFixed(2)}'
                                      : '₩: ${(input_controler * (converstion['KRW'])).toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  shownotif(
                    title: 'Terima kasih atas dukungan yang anda berikan',
                    body:
                        'Dukungan pada ${detail['attributes']['name']} berhasil diterima',
                    fln: flutterLocalNotificationsPlugin,
                  );
                },
                child: Text('Bayar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
