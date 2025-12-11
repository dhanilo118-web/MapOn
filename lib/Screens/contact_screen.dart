import 'package:flutter/material.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  String _selectedOption = "Feedback";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {},
        ),
        title: const Text("Contato", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            _buildLabel("Nome"),
            const TextField(decoration: InputDecoration(hintText: "Digite seu nome")),
            const SizedBox(height: 16),
            _buildLabel("Seu email"),
            const TextField(decoration: InputDecoration(hintText: "email@exemplo.com")),
            const SizedBox(height: 16),
            _buildLabel("Sua mensagem..."),
            const TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Deixe seu feedback ou dúvida aqui...",
                contentPadding: EdgeInsets.all(20),
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
                child: const Text(
                  "Enviar Mensagem",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
          ],
        ),
      ),
    );
  }

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
