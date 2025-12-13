// Arquivo: lib/ifpa_locais.dart

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

// 1. A Classe (O molde do marcador)
class IfpaPlace {
  final String title;
  final String description;
  final LatLng location;
  final IconData icon;
  final Color color;

  IfpaPlace({
    required this.title,
    required this.description,
    required this.location,
    required this.icon,
    required this.color,
  });
}

// 2. A Lista de Locais (Seus dados)
final List<IfpaPlace> ifpaLocais = [
  IfpaPlace(
    title: "Portaria/Entrada e Saída",
    description: "Controle\nAcesso ao campus",
    location: const LatLng(-3.8176994607430537, -49.665150515562765),
    icon: Icons.local_police, // Polícia/Segurança
    color: Colors.blueGrey,
  ),
  IfpaPlace(
    title: "Bloco 1 - Eletrotécnica",
    description: "Laboratórios\nSalas de elétrica",
    location: const LatLng(-3.817888612562388, -49.66472441218371),
    icon: Icons.electric_bolt, // Raio/Eletricidade
    color: Colors.amber, // Amarelo (padrão de elétrica)
  ),
  IfpaPlace(
    title: "Bloco 2 - Administrativo/TI",
    description: "Secretaria Acadêmica\nEstágio\nIFMaker\nASCOM\nTI",
    location: const LatLng(-3.817701196078738, -49.66448092453882),
    icon: Icons.support_agent, // Atendimento/Suporte
    color: Colors.blue,
  ),
  IfpaPlace(
    title: "Bloco 3 - Edificações",
    description: "Edificações\nAgrimensura",
    location: const LatLng(-3.818063881646658, -49.664566145215026),
    icon: Icons.foundation, // Fundação/Construção
    color: Colors.orange, // Laranja (capacete de obra)
  ),
  IfpaPlace(
    title: "Bloco 4 - Direção/Rádio",
    description: "Gab. Direção Geral\nProtocolo\nNAPNE\nRádio",
    location: const LatLng(-3.817893818577571, -49.66433657114984),
    icon: Icons.mic_external_on, // Microfone/Rádio ou Icons.gavel (Direção)
    color: Colors.brown,
  ),
  IfpaPlace(
    title: "Bloco 5 - Logística",
    description: "Dep. de Administração\nAlmoxarifado\nTransportes",
    location: const LatLng(-3.818259974735538, -49.66443570540526),
    icon: Icons.inventory_2, // Caixa/Estoque
    color: Colors.teal,
  ),
  IfpaPlace(
    title: "Bloco 6 - Computação",
    description: "Informática\nCiência da Computação",
    location: const LatLng(-3.818072558332954, -49.66418526097052),
    icon: Icons.terminal, // Terminal de código
    color: Colors.indigo,
  ),
  IfpaPlace(
    title: "Bloco 7 - Ambiental",
    description: "Saneamento\nEngenharia Sanitária\nAmbiental",
    location: const LatLng(-3.8184560677796235, -49.66429656960818),
    icon: Icons.water_drop, // Gota/Água
    color: Colors.cyan,
  ),
  IfpaPlace(
    title: "Bloco 8 - Arq. e Pesca",
    description: "Arquitetura\nEngenharia de Pesca",
    location: const LatLng(-3.8182530333880305, -49.66403916838358),
    icon: Icons.architecture, // Compasso/Arquitetura
    color: Colors.lime,
  ),
  IfpaPlace(
    title: "Bloco Pedagógico",
    description: "Salas de aula\nSalas pedagógicas",
    location: const LatLng(-3.817374952466222, -49.663860031058746),
    icon: Icons.school, // Chapéu de formatura/Ensino
    color: Colors.pinkAccent,
  ),
  IfpaPlace(
    title: "Biblioteca",
    description: "Acervo\nLivros\nComputadores\nEstudo",
    location: const LatLng(-3.8173801584821807, -49.66421830573622),
    icon: Icons.local_library, // Livro
    color: Colors.green,
  ),
  IfpaPlace(
    title: "Auditório",
    description: "Eventos\nPalestras\nApresentações",
    location: const LatLng(-3.8172239779895, -49.66423048011847),
    icon: Icons.theater_comedy, // Máscaras de teatro/Palco
    color: Colors.deepPurple,
  ),
  IfpaPlace(
    title: "Refeitório/Cantina",
    description: "Lanches\nRefeições",
    location: const LatLng(-3.817192741887554, -49.66398873167104),
    icon: Icons.restaurant, // Garfo e Faca
    color: Colors.redAccent,
  ),
  IfpaPlace(
    title: "Lanchonete do Tio Manoel",
    description: "Lanches rápidos\nBebidas\nRecargas de carteirinha",
    location: const LatLng(-3.817888669214377, -49.66538692619721),
    icon: Icons.fastfood, // Bola de futebol
    color: Colors.orange,
  ),
];
