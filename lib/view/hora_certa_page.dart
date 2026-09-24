import 'package:flutter/material.dart';
import '../service/invertexto_service.dart';

class HoraCertaPage extends StatefulWidget {
  const HoraCertaPage({super.key});

  @override
  State<HoraCertaPage> createState() => _HoraCertaPageState();
}

class _HoraCertaPageState extends State<HoraCertaPage> {
  String? cidade;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Hora Certa', style: TextStyle(color: Colors.white)),
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
            DropdownButtonFormField<String>(
              initialValue: cidade,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Escolha a cidade',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              items: ['Brasília', 'Manaus', 'Fernando de Noronha']
                  .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: (value) => setState(() => cidade = value),
            ),
            FutureBuilder<DateTime>(
              future: cidade == null ? null : Future(() => HoraCerta.agora(cidade!)),
              builder: (context, snapshot) {
                if (cidade == null) return const SizedBox();
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: Colors.white));
                }
                if (snapshot.hasError) {
                  return _mensagem(snapshot.error.toString());
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text('$cidade\n${formatarHora(snapshot.data!)}', style: const TextStyle(color: Colors.white, fontSize: 20), textAlign: TextAlign.center),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _mensagem(String mensagem) => Text(mensagem.replaceFirst('Exception: ', ''), style: const TextStyle(color: Colors.white, fontSize: 18));
}
