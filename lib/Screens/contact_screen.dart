import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Não esqueça de adicionar ao pubspec.yaml

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  String _selectedOption = "Feedback";

  // --- FUNÇÃO AUXILIAR PARA ABRIR LINKS (INFO) ---
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Não foi possível abrir $urlString');
      }
    } catch (e) {
      debugPrint('Erro ao abrir link: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        // Botão de voltar (opcional se estiver na tab bar)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            // Se for navegar para fora, adicione a lógica aqui.
          },
        ),
        title: Text(
          _selectedOption == "Info" ? "Sobre & Créditos" : "Fale Conosco",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. BARRA DE SELEÇÃO (TOGGLE) ---
            Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(24)),
              child: Row(
                children: ["Feedback", "Suporte", "Info"].map((option) {
                  final isSelected = _selectedOption == option;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedOption = option),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFEA2A33) : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          option,
                          style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // --- 2. CONTEÚDO DINÂMICO ---
            // Se for "Info", mostra os créditos. Se não, mostra o formulário.
            if (_selectedOption == "Info") _buildInfoContent() else _buildFormContent(),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // WIDGETS DA TELA DE INFO (CRÉDITOS)
  // =========================================================
  Widget _buildInfoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Sobre o MapOn",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "O MapOn é um projeto desenvolvido para facilitar a localização dentro do Campus IFPA Tucuruí.",
          style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
        ),

        const SizedBox(height: 24),
        const Text(
          "Créditos e Licenças",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Bloco 1: OpenStreetMap
        _buildCreditTile(
          title: "Dados do Mapa",
          subtitle: "© OpenStreetMap contributors",
          icon: Icons.map_outlined,
          onTap: () => _launchURL('https://www.openstreetmap.org/copyright'),
        ),

        const SizedBox(height: 12),

        // Bloco 2: Esri (Satélite)
        _buildCreditTile(
          title: "Imagens de Satélite",
          subtitle: "Source: Esri, Maxar, Earthstar Geographics, and the GIS User Community",
          icon: Icons.satellite_alt,
          onTap: () => _launchURL('https://www.esri.com/en-us/legal/copyright-trademarks'),
        ),

        const SizedBox(height: 12),

        // Bloco 3: Flutter Map
        _buildCreditTile(
          title: "Motor de Renderização",
          subtitle: "Desenvolvido com flutter_map",
          icon: Icons.code,
          onTap: () => _launchURL('https://pub.dev/packages/flutter_map'),
        ),

        const SizedBox(height: 30),
        Center(
          child: Text("Versão 1.0.0", style: TextStyle(color: Colors.grey[700], fontSize: 12)),
        ),
        const SizedBox(height: 50), // Espaço extra no final
      ],
    );
  }

  Widget _buildCreditTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFEA2A33)),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        trailing: const Icon(Icons.open_in_new, color: Colors.grey, size: 18),
        onTap: onTap,
      ),
    );
  }

  // =========================================================
  // WIDGETS DA TELA DE FEEDBACK E SUPORTE (FORMULÁRIO)
  // =========================================================
  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel("Nome"),
        const TextField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Digite seu nome",
            hintStyle: TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Color(0xFF1E1E1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLabel("Seu email"),
        const TextField(
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "email@exemplo.com",
            hintStyle: TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Color(0xFF1E1E1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLabel(_selectedOption == "Suporte" ? "Descreva o problema..." : "Sua mensagem..."),
        TextField(
          maxLines: 5,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: _selectedOption == "Suporte"
                ? "Tive um erro ao tentar..."
                : "Deixe seu feedback ou dúvida aqui...",
            hintStyle: const TextStyle(color: Colors.white24),
            contentPadding: const EdgeInsets.all(20),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA2A33),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              shadowColor: const Color(0xFFEA2A33).withValues(alpha: .4),
              elevation: 8,
            ),
            child: Text(
              _selectedOption == "Suporte" ? "Pedir Ajuda" : "Enviar Mensagem",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Center(
          child: Text("Nossas Redes Sociais", style: TextStyle(color: Colors.grey)),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(Icons.camera_alt),
            const SizedBox(width: 16),
            _buildSocialIcon(Icons.alternate_email),
            const SizedBox(width: 16),
            _buildSocialIcon(Icons.facebook),
          ],
        ),
        const SizedBox(height: 32),
        _buildContactTile(Icons.call, "+55 (94) 98765-4321"),
        const SizedBox(height: 12),
        _buildContactTile(Icons.location_on, "IFPA Campus Tucuruí"),
        const SizedBox(height: 50),
      ],
    );
  }

  // --- HELPERS DO FORMULÁRIO ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(color: Color(0xFF1E1E1E), shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _buildContactTile(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 16),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}
