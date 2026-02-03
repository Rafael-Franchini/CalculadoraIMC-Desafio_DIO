import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:imccalc/models/imc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<IMC> historico = [];

  final TextEditingController pesoController = TextEditingController();
  final TextEditingController alturaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? dadosSalvos = prefs.getStringList('historico_imc');

    if (dadosSalvos != null) {
      setState(() {
        historico = dadosSalvos
            .map((item) => IMC.fromJson(jsonDecode(item)))
            .toList();
      });
    }
  }

  Future<void> _salvarNoBanco() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> listaParaSalvar = historico
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    await prefs.setStringList('historico_imc', listaParaSalvar);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Calculadora IMC"),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep, color: Colors.white),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('historico_imc');
              setState(() => historico.clear());
            },
          ),
        ],
      ),
      backgroundColor: Color(0xff252525),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            _buildInputContainer(width),
            SizedBox(height: 20),
            Text(
              "Histórico:",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            SizedBox(height: 20),
            _buildListaHistorico(height),
          ],
        ),
      ),
    );
  }

  Widget _buildInputContainer(double width) {
    return Center(
      child: Container(
        width: width * 0.8,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  _customTextField(
                    alturaController,
                    "Altura (ex: 1.80)",
                    Icons.height,
                  ),
                  SizedBox(height: 10),
                  _customTextField(
                    pesoController,
                    "Peso (ex: 80.0)",
                    Icons.fitness_center,
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            _buildBotaoCalcular(),
          ],
        ),
      ),
    );
  }

  Widget _customTextField(
    TextEditingController controller,
    String hint,
    IconData icon,
  ) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildBotaoCalcular() {
    return SizedBox(
      height: 110,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          String pesoText = pesoController.text.replaceAll(',', '.');
          String alturaText = alturaController.text.replaceAll(',', '.');

          double? peso = double.tryParse(pesoText);
          double? altura = double.tryParse(alturaText);

          if (peso != null && altura != null && altura > 0) {
            double valor = peso / (altura * altura);
            String tipo = "";

            if (valor < 18.5)
              tipo = "Magreza";
            else if (valor < 25)
              tipo = "Saudável";
            else if (valor < 30)
              tipo = "Sobrepeso";
            else
              tipo = "Obesidade";

            setState(() {
              historico.insert(
                0,
                IMC(
                  peso: peso,
                  altura: altura,
                  imc: valor,
                  tipo: tipo,
                  data: DateTime.now(),
                ),
              );
            });

            _salvarNoBanco();
            pesoController.clear();
            alturaController.clear();
            FocusScope.of(context).unfocus();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Preencha peso e altura corretamente!")),
            );
          }
        },
        child: Text("Calcular", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildListaHistorico(double height) {
    if (historico.isEmpty) {
      return Text("Nenhum registro.", style: TextStyle(color: Colors.grey));
    }
    return SizedBox(
      height: height * 0.5,
      child: ListView.builder(
        itemCount: historico.length,
        itemBuilder: (context, index) {
          final item = historico[index];

          // Implementação para apagar item específico (Swipe)
          return Dismissible(
            key: Key(item.data.millisecondsSinceEpoch.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              setState(() {
                historico.removeAt(index);
              });
              _salvarNoBanco();
            },
            child: ListTile(
              textColor: Colors.white,
              title: Text("IMC: ${item.imc.toStringAsFixed(2)} - ${item.tipo}"),
              subtitle: Text("Peso: ${item.peso}kg | Altura: ${item.altura}m"),
              trailing: Text("${item.data.day}/${item.data.month}"),
            ),
          );
        },
      ),
    );
  }
}
