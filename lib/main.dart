import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

const urlLogin =
    "http://sankhya.grancoffee.com.br:8180/mge/service.sbr?serviceName=MobileLoginSP.login";

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
  void initState() {
    super.initState();
    Login();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: (){
          var login = Login();
          print(login);
        })],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: Icon(Icons.qr_code_scanner, size: 150.0)),
          Padding(
              padding: EdgeInsets.fromLTRB(80.0, 10.0, 80.0, 5.0),
              child: FlatButton(
                child: Text("Bipar", style: TextStyle(color: Colors.white)),
                onPressed: () => _scan(),
                color: Colors.grey,
              )),
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

  Future<File> _getFile() async {
    //recupera o arquivo
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }
}

 Login() async {
  String body = "<serviceRequest>" +
      "<requestBody>" +
      "<NOMUSU>GABRIEL</NOMUSU>" +
      "<INTERNO>gabriel123456</INTERNO>" +
      "</requestBody>" +
      "</serviceRequest>";

  var post = await http.post(urlLogin,body: body);
  var xmlDocument = XmlDocument.parse(post.body);
  var where = xmlDocument.findAllElements('jsessionid');
  var map = where.map((e) => e.text.trim());
  print("JSessionId: $where");
}
