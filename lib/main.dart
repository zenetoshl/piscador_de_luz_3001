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
  List<BluetoothDevice> listD = [];
  BluetoothDevice device;
  BluetoothCharacteristic char;
  int speed = 16;

  void initState() {
    scanAndConnect();
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
    flutterBlue
        .scan(scanMode: ScanMode.balanced, timeout: Duration(seconds: 5))
        .listen((scanResult) {
      // do something with scan result
      BluetoothDevice device = scanResult.device;
      if (!listD.contains(device)) {
        setState(() {
          listD.add(device);
        });
      }
      print(device.name);
    });
  }

  Future<void> showList() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Conectar a um dispositivo'),
            content: SingleChildScrollView(
              child: Column(
                children: listD
                    .map((d) => ListTile(
                          title: Text(d.name),
                          subtitle: Text(d.id.toString()),
                          onTap: () async {
                            d.connect();
                            print(d.name);
                            setState(() {
                              device = d;
                              speed = 16;
                            });
                          },
                        ))
                    .toList(),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (device != null)
                    findChar();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () {
        if (device != null)
          device.disconnect();
        return Future<bool>.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions:<Widget>[
            IconButton(
              onPressed: showList,
              icon: Icon(Icons.bluetooth),
            )
          ],
        ),
        body: Center(
          child:  (device == null) ? null : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  if (char != null)
                    char.write([34], withoutResponse: true);
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
                  if (char != null)
                    char.write([35], withoutResponse: true);
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
      ),
    );
  }
}
