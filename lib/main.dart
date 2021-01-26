import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

const urlLogin =
    "http://sankhya.grancoffee.com.br:8180/mge/service.sbr?serviceName=MobileLoginSP.login";
const urlLogout =
    "http://sankhya.grancoffee.com.br:8180/mge/service.sbr?serviceName=MobileLoginSP.logout";

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
  String _jsessionid = "";
  String _codprod = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: clean)
        ],
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
            padding: EdgeInsets.only(top: 10.0),
            alignment: Alignment.center,
            child: Text("Código de Barras: $_data",
                style: TextStyle(fontSize: 20.0)),
          ),
          Container(
            padding: EdgeInsets.only(top: 20.0),
            alignment: Alignment.center,
            child: Text("Código Produto: $_codprod", style: TextStyle(fontSize: 20.0)),
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
        _data = "Inválido!";
        Logout();
      } else {
        _data = codbar;
      }
    });

    if(codbar !="-1"){
      await Login();
      await getProduto();
      await Logout();
    }

  }

  Future<File> _getFile() async {
    //recupera o arquivo
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future Login() async {
    String body = "<serviceRequest>" +
        "<requestBody>" +
        "<NOMUSU>GABRIEL</NOMUSU>" +
        "<INTERNO>gabriel123456</INTERNO>" +
        "</requestBody>" +
        "</serviceRequest>";

    var post = await http.post(urlLogin, body: body);
    var xmlDocument = XmlDocument.parse(post.body);
    var where = xmlDocument.findAllElements('jsessionid');
    var map = where.map((e) => e.text.trim());
    setState(() {
      _jsessionid = map.toString().replaceAll("(", "").replaceAll(")", "");
    });
  }

  Future Logout() async {
    await http.post(urlLogout, headers: {"Cookie": "JSESSIONID=$_jsessionid"});
  }

  Future getProduto() async {
    print(_jsessionid);
    if (_jsessionid.isEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("ERRO"),
              content: Text("Jsession Inválida!"),
              actions: [
                FlatButton(
                    child: Text("Fechar"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ],
            );
          });
    }else{
      String url =
          "http://sankhya.grancoffee.com.br:8180/mge/service.sbr?serviceName=DbExplorerSP.executeQuery&mgeSession=$_jsessionid";
      String body =
          "{\"serviceName\":\"DbExplorerSP.executeQuery\",\"requestBody\":{\"sql\":\"SELECT CODPROD FROM TGFBAR WHERE CODBARRA=\'$_data\' AND ROWNUM=1\"}}";

      var response = await http.post(url,body: body, headers: {"Cookie": "JSESSIONID=$_jsessionid"});
      var decode = json.decode(response.body);
      setState(() {
        _codprod = decode["responseBody"]["rows"][0].toString().replaceAll("[", "").replaceAll("]", "");
      });
    }
  }

  clean(){
    setState(() {
      _data = "";
      _codprod = "";
    });
  }
}
