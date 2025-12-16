import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  String _selectedOption = "Feedback";
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSending = false;
  DateTime? _lastSubmissionTime;

  // 🔗 SUAS URLS DO DISCORD (Mantenha as suas chaves aqui)
  final String _feedbackWebhookUrl =
      "https://discord.com/api/webhooks/1449429463409627326/dIsdS8ryDU9o3H5bW_GzSkBgzefx8DMk-LomcDXYz321dufcdAHeDR2CNAUEqSOlmhgy";
  final String _supportWebhookUrl =
      "https://discord.com/api/webhooks/1449432958724477215/HOo2t1MMSUPvVXzX5gUAvD6j_EcSu-1jGpo7eZ7tyyJsAL4xFWNKIJed1fdVgP66L8mp";

  Future<void> _sendToDiscord() async {
    if (!_formKey.currentState!.validate()) return;

    if (_feedbackWebhookUrl.contains("URL_DO") || _supportWebhookUrl.contains("URL_DO")) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Erro: Configure os Webhooks no código!")));
      return;
    }

    if (_lastSubmissionTime != null) {
      final difference = DateTime.now().difference(_lastSubmissionTime!);
      if (difference.inSeconds < 60) {
        final waitSeconds = 60 - difference.inSeconds;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Aguarde $waitSeconds segundos para enviar novamente."),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    setState(() => _isSending = true);

    final isSupport = _selectedOption == "Suporte";
    final urlToUse = isSupport ? _supportWebhookUrl : _feedbackWebhookUrl;
    final color = isSupport ? 15548997 : 5763719;
    final title = isSupport ? "🚨 PEDIDO DE SUPORTE" : "🔔 NOVO FEEDBACK";

    try {
      final messageData = {
        "username": isSupport ? "Suporte MapOn" : "Feedback MapOn",
        "embeds": [
          {
            "title": title,
            "color": color,
            "fields": [
              {"name": "👤 Usuário", "value": _nameController.text, "inline": true},
              {"name": "📧 Contato", "value": _emailController.text, "inline": true},
              {"name": "📝 Mensagem", "value": _messageController.text},
            ],
            "footer": {"text": "Enviado via App MapOn"},
          },
        ],
      };

      final response = await http.post(
        Uri.parse(urlToUse),
        headers: {"Content-Type": "application/json"},
        body: json.encode(messageData),
      );

      if (mounted) {
        if (response.statusCode == 204) {
          _lastSubmissionTime = DateTime.now();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isSupport ? "Solicitação enviada! Aguarde retorno." : "Feedback enviado! Obrigado."),
              backgroundColor: isSupport ? Colors.redAccent : Colors.green,
            ),
          );
          _clearForm();
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Erro ao enviar."), backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      debugPrint("Erro: $e");
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _messageController.clear();
    _formKey.currentState?.reset();
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Erro ao abrir $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {}, // Ajuste se precisar de navegação
        ),
        title: Text(
          _selectedOption == "Info" ? "Sobre" : "Fale Conosco",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- ABAS ---
            Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(24)),
              child: Row(
                children: ["Feedback", "Suporte", "Info"].map((option) {
                  final isSelected = _selectedOption == option;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _selectedOption = option;
                        _formKey.currentState?.reset();
                      }),
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

            // --- CONTEÚDO ---
            if (_selectedOption == "Info") _buildInfoContent() else _buildUnifiedForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildUnifiedForm() {
    final isSupport = _selectedOption == "Suporte";

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isSupport ? "Precisa de ajuda técnica?" : "Ajude a melhorar o MapOn!",
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            isSupport
                ? "Preencha abaixo e nossa equipe analisará seu caso."
                : "Encontrou um erro ou tem uma ideia? Conta pra gente.",
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // --- CAMPO NOME ---
          _buildTextFormField(
            controller: _nameController,
            label: "Nome Completo", // Título na borda
            hint: "Ex: Cleitin Del Rei", // Texto de exemplo dentro
            icon: Icons.person_outline,
            isRequired: true,
          ),

          const SizedBox(height: 20),

          // --- CAMPO EMAIL ---
          _buildTextFormField(
            controller: _emailController,
            label: "Seu Email",
            hint: "Ex: email@exemplo.com",
            icon: Icons.email_outlined,
            isRequired: true,
            isEmail: true,
          ),

          const SizedBox(height: 20),

          // --- CAMPO MENSAGEM ---
          _buildTextFormField(
            controller: _messageController,
            label: "Mensagem",
            hint: isSupport ? "Descreva seu problema..." : "Sua sugestão...",
            icon: Icons.message_outlined,
            isRequired: true,
            maxLines: 5,
          ),

          const SizedBox(height: 32),

          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isSending ? null : _sendToDiscord,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEA2A33),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      isSupport ? "Enviar Solicitação" : "Enviar Feedback",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // === WIDGET DO INPUT ESTILO OUTLINE (IGUAL A FOTO) ===
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label, // Novo parâmetro Label
    required String hint,
    IconData? icon,
    bool isRequired = false,
    bool isEmail = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return 'Campo obrigatório';
        }
        if (isEmail && value != null && value.isNotEmpty && !value.contains('@')) {
          return 'Email inválido';
        }
        return null;
      },
      decoration: InputDecoration(
        // CONFIGURAÇÃO DO LABEL "CORTANDO" A BORDA
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        floatingLabelBehavior: FloatingLabelBehavior.always, // Mantém o Label sempre em cima

        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),

        prefixIcon: maxLines == 1 && icon != null ? Icon(icon, color: Colors.grey[500]) : null,

        filled: true,
        fillColor: const Color(0xFF1E1E1E), // Fundo levemente mais claro que o fundo preto
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),

        // BORDAS ARREDONDADAS COM OUTLINE
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEA2A33), width: 2), // Borda Vermelha ao focar
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }

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
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 24),
        const Text(
          "Créditos e Licenças",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildCreditTile(
          title: "Dados do Mapa",
          subtitle: "© OpenStreetMap contributors",
          icon: Icons.map_outlined,
          onTap: () => _launchURL('https://www.openstreetmap.org/copyright'),
        ),
        const SizedBox(height: 12),
        _buildCreditTile(
          title: "Imagens de Satélite",
          subtitle: "Source: Esri, Maxar, Earthstar Geographics",
          icon: Icons.satellite_alt,
          onTap: () => _launchURL('https://www.esri.com/en-us/legal/copyright-trademarks'),
        ),
        const SizedBox(height: 12),
        _buildCreditTile(
          title: "Motor de Renderização",
          subtitle: "Desenvolvido com flutter_map",
          icon: Icons.code,
          onTap: () => _launchURL('https://pub.dev/packages/flutter_map'),
        ),
        const SizedBox(height: 30),
        Center(
          child: Text("Versão 1.0.3", style: TextStyle(color: Colors.grey[700], fontSize: 12)),
        ),
        const SizedBox(height: 30),
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
}
