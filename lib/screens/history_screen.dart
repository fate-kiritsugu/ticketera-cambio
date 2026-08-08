import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';
import '../models/operation.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedDay = DateTime.now();
  List<Operation> _ops = [];
  Map<String, double> _totals = {'compras': 0, 'ventas': 0};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dayStr = DateFormat('yyyy-MM-dd').format(_selectedDay);
    final ops = await DatabaseHelper.instance.getOperations(day: dayStr);
    final totals = await DatabaseHelper.instance.getDailyTotals(dayStr);
    setState(() {
      _ops = ops;
      _totals = totals;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDay = picked);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('dd/MM/yyyy').format(_selectedDay),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: const Text('Cambiar fecha'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(child: _totalCard('Compras', _totals['compras']!, Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _totalCard('Ventas', _totals['ventas']!, Colors.blue)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _ops.isEmpty
              ? const Center(child: Text('Sin operaciones este día'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ops.length,
                  itemBuilder: (context, i) {
                    final op = _ops[i];
                    final hora = DateFormat('HH:mm:ss').format(DateTime.parse(op.fechaHora));
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          op.tipo == 'Compra' ? Icons.arrow_downward : Icons.arrow_upward,
                          color: op.tipo == 'Compra' ? Colors.green : Colors.blue,
                        ),
                        title: Text(
                            '${op.monto} ${op.monedaOrigen} → ${op.resultado.toStringAsFixed(2)} ${op.monedaDestino}'),
                        subtitle: Text('${op.tipo} · TC ${op.tipoCambio} · $hora'),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _totalCard(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value.toStringAsFixed(2), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
