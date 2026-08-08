import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import 'printer_setup_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _origen = 'PEN';
  String _destino = 'USD';
  final _currencies = ['PEN', 'USD', 'CLP', 'EUR'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = await SettingsService.loadBusinessInfo();
    setState(() {
      _nameCtrl.text = info['businessName']!;
      _locationCtrl.text = info['location']!;
      _phoneCtrl.text = info['phone']!;
      _origen = info['origen']!;
      _destino = info['destino']!;
    });
  }

  Future<void> _save() async {
    await SettingsService.saveBusinessInfo(
      businessName: _nameCtrl.text,
      location: _locationCtrl.text,
      phone: _phoneCtrl.text,
      origen: _origen,
      destino: _destino,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ajustes guardados')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Datos del negocio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: 'Nombre del negocio', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _locationCtrl,
          decoration: const InputDecoration(labelText: 'Ubicación', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneCtrl,
          decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _origen,
                decoration: const InputDecoration(labelText: 'Moneda origen', border: OutlineInputBorder()),
                items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _origen = v!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _destino,
                decoration: const InputDecoration(labelText: 'Moneda destino', border: OutlineInputBorder()),
                items: _currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _destino = v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            child: const Padding(padding: EdgeInsets.all(12), child: Text('Guardar')),
          ),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),
        const Text('Impresora', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.print),
          title: const Text('Cómo configurar tu impresora'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrinterSetupScreen())),
        ),
      ],
    );
  }
}
