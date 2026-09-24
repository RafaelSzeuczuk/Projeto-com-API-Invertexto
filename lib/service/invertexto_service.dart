import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class InvertextoApiService {
  final String _token = "28072|vZM7Qr1GMZILj5Et1q3C0bVmtWxFOD1S";

  Future<Map<String, dynamic>> convertePorExtenso(String? valor) async {
    try {
      if (valor == null || valor.trim().isEmpty) throw Exception('Digite um número obrigatório');
      final uri = Uri.parse(
        "https://api.invertexto.com/v1/number-to-words"
        "?token=$_token&number=${Uri.encodeQueryComponent(valor.trim())}"
        "&language=pt&currency=BRL",
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final dados = json.decode(response.body);
        if (dados is Map<String, dynamic> && dados.isNotEmpty) return dados;
        throw Exception('A API retornou uma resposta vazia');
      }
      throw Exception(_mensagemHttp(response.statusCode, response.body));
    } on SocketException { throw Exception('Erro de conexão com a internet'); }
    catch (e) { rethrow; }
  }

  Future<Map<String, dynamic>> buscaCEP(String? valor) async {
    try {
      final cep = (valor ?? '').replaceAll(RegExp(r'[^0-9]'), '');
      if (cep.length != 8) throw Exception('Digite um CEP válido com 8 números');
      final uri = Uri.parse("https://api.invertexto.com/v1/cep/$cep?token=$_token");
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final dados = json.decode(response.body);
        if (dados is Map<String, dynamic> && dados.isNotEmpty) return dados;
        throw Exception('A API retornou uma resposta vazia');
      }
      throw Exception(_mensagemHttp(response.statusCode, response.body));
    } on SocketException { throw Exception('Erro de conexão com a internet'); }
    catch (e) { rethrow; }
  }

  Future<Map<String, dynamic>> distanciaEntreCidades(String? origem, String? destino) async {
    try {
      if (origem == null || origem.trim().isEmpty) throw Exception('Digite a cidade de origem');
      if (destino == null || destino.trim().isEmpty) throw Exception('Digite a cidade de destino');
      if (origem.trim().toLowerCase() == destino.trim().toLowerCase()) throw Exception('Escolha cidades diferentes');

      final pontoOrigem = await _localizar(origem.trim());
      final pontoDestino = await _localizar(destino.trim());
      final coordenadas = '${pontoOrigem['lon']},${pontoOrigem['lat']};${pontoDestino['lon']},${pontoDestino['lat']}';
      final uri = Uri.https('router.project-osrm.org', '/route/v1/driving/$coordenadas', {'overview': 'false'});
      final response = await http.get(uri, headers: {'User-Agent': 'InverTexto/1.0'});
      if (response.statusCode != 200) throw Exception('Erro ${response.statusCode}: não foi possível calcular a rota');
      final dados = json.decode(response.body);
      final rotas = dados['routes'];
      if (rotas is! List || rotas.isEmpty) throw Exception('Rota não encontrada para essas cidades');
      final rota = rotas.first as Map<String, dynamic>;
      return {'distanceKm': (rota['distance'] as num).toDouble() / 1000, 'durationMinutes': (rota['duration'] as num).toDouble() / 60};
    } on SocketException { throw Exception('Erro de conexão com a internet'); }
    catch (e) { rethrow; }
  }

  Future<Map<String, dynamic>> _localizar(String cidade) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {'q': '$cidade, Brasil', 'format': 'json', 'limit': '1', 'countrycodes': 'br'});
    final response = await http.get(uri, headers: {'User-Agent': 'InverTexto/1.0'});
    if (response.statusCode != 200) throw Exception('Erro ao localizar a cidade: ${response.statusCode}');
    final dados = json.decode(response.body);
    if (dados is! List || dados.isEmpty) throw Exception('Cidade não encontrada: $cidade');
    final item = dados.first;
    return {'lat': item['lat'], 'lon': item['lon']};
  }

  String _mensagemHttp(int status, String corpo) {
    if (status == 401) return 'Token inválido ou não autorizado.';
    if (status == 404) return 'Dados não encontrados.';
    return 'Erro $status: $corpo';
  }
}

class ConversorBase {
  static String converter(String valor, int origem, int destino) {
    if (valor.trim().isEmpty) throw Exception('Digite um número');
    if (![2, 8, 10, 16].contains(origem) || ![2, 8, 10, 16].contains(destino)) throw Exception('Base numérica inválida');
    final numero = int.tryParse(valor.trim().toUpperCase(), radix: origem);
    if (numero == null || numero < 0) throw Exception('Número inválido para a base escolhida');
    return numero.toRadixString(destino).toUpperCase();
  }
}

class HoraCerta {
  static DateTime agora(String cidade) {
    const fusos = {'Brasília': -3, 'Manaus': -4, 'Fernando de Noronha': -2};
    return DateTime.now().toUtc().add(Duration(hours: fusos[cidade] ?? -3));
  }
}

String formatarHora(DateTime data) => '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}:${data.second.toString().padLeft(2, '0')}';
dynamic campo(dynamic dados, String nome) => dados is Map ? dados[nome] : null;
String texto(dynamic valor) => valor == null || '$valor'.isEmpty ? 'Não informado' : '$valor';
String moeda(dynamic valor) => 'R\$ ${(double.tryParse('$valor') ?? 0).toStringAsFixed(2).replaceAll('.', ',')}';
String tipoLabel(String tipo) => {'1': 'Carros', '2': 'Motos', '3': 'Caminhões'}[tipo] ?? 'Carros';
String erroUsuario(Object erro) => erro.toString().replaceFirst('Exception: ', '');
