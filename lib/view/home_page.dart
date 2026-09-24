import 'package:flutter/material.dart';
import 'busca_cep_page.dart';
import 'por_extenso_page.dart';
import 'distancia_cidades_page.dart';
import 'conversao_base_page.dart';
import 'hora_certa_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(backgroundColor: Colors.black, centerTitle: true, title: Image.asset('assets/imgs/logo.png', height: 40)),
    backgroundColor: Colors.black,
    body: ListView(padding: const EdgeInsets.all(12), children: [
      _botao(context, Icons.edit, 'Por Extenso', const PorExtensoPage()),
      _botao(context, Icons.home, 'Busca CEP', const BuscaCepPage()),
      _botao(context, Icons.map, 'Distância Entre Cidades', const DistanciaCidadesPage()),
      _botao(context, Icons.calculate, 'Conversão de Base Numérica', const ConversaoBasePage()),
      _botao(context, Icons.access_time, 'Hora Certa', const HoraCertaPage()),
    ],),
  );
  Widget _botao(BuildContext c, IconData icon, String texto, Widget page) => GestureDetector(
    onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => page)),
    child: Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Row(children: [Icon(icon, color: Colors.white, size: 46), const SizedBox(width: 24), Text(texto, style: const TextStyle(color: Colors.white, fontSize: 19))])),
  );
}
