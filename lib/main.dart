import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

void main(){
  runApp(MaterialApp(
    title: "Leitor de Código de barras",
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _data = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FlatButton(
            child: Text("Scan"),
            onPressed: ()=> _scan(),
            color: Colors.green,
          ),
          Container(
            alignment: Alignment.center,
            child: Text(_data),
          )
        ],
      ),
    );
  }

  _scan() async{
      await FlutterBarcodeScanner.scanBarcode("#000000", "Cancel", true, ScanMode.BARCODE).then((value) => setState(()=> _data = value));
  }
}
