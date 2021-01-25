import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

void main() {
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
      appBar: AppBar(
        backgroundColor: Colors.grey,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: Icon(Icons.qr_code_scanner, size: 150.0)),
          Padding(
            padding: EdgeInsets.fromLTRB(80.0, 10.0, 80.0, 5.0),
            child:  FlatButton(
              child: Text("Bipar", style: TextStyle(color: Colors.white)),
              onPressed: () => _scan(),
              color: Colors.grey,
            )
          ),

          Container(
            alignment: Alignment.center,
            child: Text(_data),
          )
        ],
      ),
    );
  }

  _scan() async {
    String codbar = await FlutterBarcodeScanner.scanBarcode(
        "#8B0000", "Cancel", true, ScanMode.BARCODE);
    setState(() {
      if (codbar == "-1") {
        _data = "Código de Barras inválido!";
      } else {
        _data = codbar;
      }
    });
  }
}
