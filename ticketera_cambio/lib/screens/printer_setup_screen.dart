import 'package:flutter/material.dart';

class PrinterSetupScreen extends StatelessWidget {
  const PrinterSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar impresora')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Esta app usa el sistema de impresión de Android. Para que tu ticketera Bluetooth aparezca en la lista al imprimir, se configura UNA SOLA VEZ con la app gratuita "RawBT".',
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 20),
          const Text('Pasos:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          _Step(number: '1', text: 'Instala "RawBT - impresora" desde Google Play Store (busca "RawBT").'),
          _Step(number: '2', text: 'Empareja tu ticketera desde el Bluetooth de Android (Ajustes del sistema), si aún no lo has hecho.'),
          _Step(number: '3', text: 'Abre RawBT → Configuración de impresora → selecciona tu ticketera por Bluetooth → elige el ancho de papel (58mm u 80mm).'),
          _Step(number: '4', text: 'Listo. Desde ahora, al presionar "Imprimir" en esta app, aparecerá RawBT como opción, junto con "Guardar como PDF".'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
            child: const Text(
              'Si no configuras RawBT todavía, siempre puedes elegir "Guardar como PDF" en el mismo diálogo, o usar el botón "Compartir" de la calculadora para enviarlo directo por WhatsApp.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String text;

  const _Step({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.orange,
            child: Text(number, style: const TextStyle(fontSize: 12, color: Colors.white)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
