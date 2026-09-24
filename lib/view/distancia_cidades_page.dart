import 'package:flutter/material.dart';
import '../service/invertexto_service.dart';

class DistanciaCidadesPage extends StatefulWidget {
  const DistanciaCidadesPage({super.key});

  @override
  State<DistanciaCidadesPage> createState() => _DistanciaCidadesPageState();
}

class _DistanciaCidadesPageState extends State<DistanciaCidadesPage> {
  String? origem;
  String? destino;
  String? resultado;
  bool carregando = false;
  final apiService = InvertextoApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Distância Entre Cidades', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Cidade de origem', labelStyle: TextStyle(color: Colors.white), border: OutlineInputBorder()),
              style: const TextStyle(color: Colors.white, fontSize: 18),
              onChanged: (value) => setState(() { origem = value; resultado = null; }),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(labelText: 'Cidade de destino', labelStyle: TextStyle(color: Colors.white), border: OutlineInputBorder()),
              style: const TextStyle(color: Colors.white, fontSize: 18),
              onChanged: (value) => setState(() { destino = value; resultado = null; }),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: carregando ? null : _consultar, child: Text(carregando ? 'Consultando...' : 'Calcular distância')),
            if (carregando) const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: Colors.white)),
            if (resultado != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(resultado!, style: const TextStyle(color: Colors.white, fontSize: 18), textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }

  Future<void> _consultar() async {
    FocusScope.of(context).unfocus();
    setState(() { carregando = true; resultado = null; });
    try {
      final dados = await apiService.distanciaEntreCidades(origem, destino);
      final km = (dados['distanceKm'] as num).toStringAsFixed(2).replaceAll('.', ',');
      final minutos = (dados['durationMinutes'] as num).round();
      if (mounted) setState(() => resultado = 'Distância por estrada: $km km\nDuração estimada: $minutos minutos');
    } catch (e) {
      if (mounted) setState(() => resultado = erroUsuario(e));
    }
    if (mounted) setState(() => carregando = false);
  }
}
