import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_blue/flutter_blue.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piscador 3001',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: MyHomePage(title: 'Acelerador de LED\'s 3001'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice device;
  BluetoothCharacteristic char;
  int speed = 16;
  bool loading = false;

  void initState() {
    super.initState();
  }

  void incrementOrDecrement(bool isIncrement) {
    if (isIncrement) {
      if (speed < 31) {
        setState(() {
          speed++;
        });
      }
    } else {
      if (speed > 1) {
        setState(() {
          speed = speed - 1;
        });
      }
    }
  }

  void findChar() async {
    List<BluetoothService> services = await device.discoverServices();
    services.forEach((service) async {
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        if (c.uuid.toString() == '560d029d-57a1-4ccc-8868-9e4b4ef41da6') {
          setState(() {
            char = c;
          });
        }
      }
    });
  }

  void scanAndConnect() {
    if (loading) return;
    loading = true;
    flutterBlue.startScan(
        scanMode: ScanMode.balanced, timeout: Duration(seconds: 4));
    loading = false;
  }

  Future<void> showList() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Conectar a um dispositivo'),
            content: SingleChildScrollView(
              child: StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data
                      .map(
                        (r) => ListTile(
                          title: Text(r.device.name),
                          subtitle: Text(r.device.id.toString()),
                          onTap: () {
                            r.device.connect();
                            setState(() {
                              device = r.device;
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (device != null) findChar();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              scanAndConnect();
              showList();
            },
            icon: Icon(Icons.bluetooth),
          )
        ],
      ),
      body: Center(
        child: (device == null)
            ? null
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      if (char != null) char.write([34], withoutResponse: true);
                      incrementOrDecrement(true);
                    },
                    icon: Icon(Icons.arrow_drop_up),
                    color: Colors.blue,
                    iconSize: 100,
                    splashColor: Colors.white,
                  ),
                  Text(
                    '$speed',
                    style: Theme.of(context).textTheme.display1,
                  ),
                  IconButton(
                    onPressed: () {
                      if (char != null) char.write([35], withoutResponse: true);
                      incrementOrDecrement(false);
                    },
                    icon: Icon(Icons.arrow_drop_down),
                    color: Colors.blue,
                    iconSize: 100,
                    splashColor: Colors.white,
                  )
                ],
              ),
      ),
    );
  }
}
