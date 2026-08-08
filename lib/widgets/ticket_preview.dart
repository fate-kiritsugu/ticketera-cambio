import 'package:flutter/material.dart';

class TicketPreview extends StatelessWidget {
  final String businessName;
  final String location;
  final String phone;
  final String tipo;
  final String monedaOrigen;
  final String monedaDestino;
  final List<String> currencies;
  final String expression;
  final String result;
  final String fechaHora;
  final ValueChanged<String> onTipoChanged;
  final ValueChanged<String> onOrigenChanged;
  final ValueChanged<String> onDestinoChanged;

  const TicketPreview({
    super.key,
    required this.businessName,
    required this.location,
    required this.phone,
    required this.tipo,
    required this.monedaOrigen,
    required this.monedaDestino,
    required this.currencies,
    required this.expression,
    required this.result,
    required this.fechaHora,
    required this.onTipoChanged,
    required this.onOrigenChanged,
    required this.onDestinoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Text(
            businessName.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Compra'),
                selected: tipo == 'Compra',
                onSelected: (_) => onTipoChanged('Compra'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Venta'),
                selected: tipo == 'Venta',
                onSelected: (_) => onTipoChanged('Venta'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: monedaOrigen,
                items: currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => onOrigenChanged(v!),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, size: 16),
              ),
              DropdownButton<String>(
                value: monedaDestino,
                items: currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => onDestinoChanged(v!),
              ),
            ],
          ),
          if (location.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(location, textAlign: TextAlign.center, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black54)),
          ],
          if (phone.isNotEmpty)
            Text(phone, textAlign: TextAlign.center, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black54)),
          const SizedBox(height: 16),
          Text(
            expression.isEmpty ? '—' : expression,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
          ),
          const Divider(height: 24),
          Text(
            result,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(fechaHora, style: const TextStyle(color: Colors.black45, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
