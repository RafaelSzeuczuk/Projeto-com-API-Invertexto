import 'package:flutter/material.dart';
import '../service/invertexto_service.dart';

class ConversaoBasePage extends StatefulWidget {
  const ConversaoBasePage({super.key});

  @override
  State<ConversaoBasePage> createState() => _ConversaoBasePageState();
}

class _ConversaoBasePageState extends State<ConversaoBasePage> {
  String? campo;
  String origem = '10';
  String destino = '2';
  final apiService = InvertextoApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Conversão de Base', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Digite o número',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 18),
              onSubmitted: (value) => setState(() => campo = value),
            ),
            Row(
              children: [
                Expanded(child: _seletor('Base de origem', origem, (value) => setState(() => origem = value!))),
                const SizedBox(width: 10),
                Expanded(child: _seletor('Base de destino', destino, (value) => setState(() => destino = value!))),
              ],
            ),
            FutureBuilder<String>(
              future: campo == null ? null : Future(() => ConversorBase.converter(campo!, int.parse(origem), int.parse(destino))),
              builder: (context, snapshot) {
                if (campo == null) return const SizedBox();
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: Colors.white));
                }
                if (snapshot.hasError) return _mensagem(snapshot.error.toString());
                return Padding(padding: const EdgeInsets.only(top: 10), child: Text('Resultado: ${snapshot.data}', style: const TextStyle(color: Colors.white, fontSize: 18)));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _seletor(String label, String valor, ValueChanged<String?> onChanged) => DropdownButtonFormField<String>(
    initialValue: valor,
    dropdownColor: Colors.grey[900],
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.white)),
    items: ['2', '8', '10', '16'].map((base) => DropdownMenuItem(value: base, child: Text(base))).toList(),
    onChanged: onChanged,
  );

  Widget _mensagem(String mensagem) => Padding(padding: const EdgeInsets.only(top: 10), child: Text(mensagem.replaceFirst('Exception: ', ''), style: const TextStyle(color: Colors.white, fontSize: 18)));
}
