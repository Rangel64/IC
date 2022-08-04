import 'dart:ffi';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String mass = "";
  ImagePicker imagePicker = ImagePicker();
  String url = 'http://192.168.100.8:5000/';
  double? serverLoad = 0;
  double numeroDeDias = 0;
  String massaEstimada = '';
  double capacidadeDeSuporte = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estimador Unidade Animal'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            onChanged: (text) {
              numeroDeDias = double.parse(text);
            },
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
                labelText: 'Dias', border: OutlineInputBorder()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: (){
                    pegarImagemGaleria();
                    estimativaAnimal();
                  },
                  icon: Icon(Icons.add_photo_alternate_outlined)),
              IconButton(
                  onPressed: (){
                    pegarImagemCamera();
                    estimativaAnimal();
                  },
                  icon: Icon(Icons.photo_camera_outlined)),
            ],
          ),
          Container(
              alignment: Alignment.topCenter,
              margin: EdgeInsets.only(top: 20),
              child: CircularProgressIndicator(
                value: serverLoad,
              )),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text(mass)])
        ],
      ),
    );
  }

  pegarImagemGaleria() async {
    final XFile? imagemTemporaria =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (imagemTemporaria != null) {
      final bytes = await File(imagemTemporaria.path).readAsBytes();

      String base64Encode = base64.encode(bytes);

      setState(() {
        mass = '';
      });

      setState(() {
        serverLoad = null;
      });

      final response = await http.post(Uri.parse(url),
          body: json.encode({'image': base64Encode}));

      final decoded = json.decode(response.body) as Map<String, dynamic>;

      if (decoded['response'] != null) {
        setState(() {
          serverLoad = 0;
        });
      }

      massaEstimada = decoded['response'];

    }
  }

  pegarImagemCamera() async {
    final XFile? imagemTemporaria =
        await imagePicker.pickImage(source: ImageSource.camera);

    if (imagemTemporaria != null) {
      final bytes = await File(imagemTemporaria.path).readAsBytes();

      String base64Encode = base64.encode(bytes);

      setState(() {
        mass = '';
      });

      setState(() {
        serverLoad = null;
      });

      final response = await http.post(Uri.parse(url),
          body: json.encode({'image': base64Encode}));

      final decoded = json.decode(response.body) as Map<String, dynamic>;

      massaEstimada = decoded['response'];
    }
  }

 void estimativaAnimal(){
    if (massaEstimada != null) {
      setState(() {
        serverLoad = 0;
      });
    }
    double forragemDisponivelEConsumivel =
        double.parse(massaEstimada) * 0.7 * 0.5;
    double consumoDiario = 450 * 0.02;
    double quantidadeDeConsumoPorPeriodo = consumoDiario * numeroDeDias;
    capacidadeDeSuporte = forragemDisponivelEConsumivel / quantidadeDeConsumoPorPeriodo;

    setState(() {
      mass = 'Estimativa: ' + capacidadeDeSuporte.toStringAsFixed(2)+ 'UA/ha';
    });
  }
}
