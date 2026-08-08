import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../services/settings_service.dart';
import '../services/pdf_service.dart';
import '../db/database_helper.dart';
import '../models/operation.dart';
import '../widgets/ticket_preview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _display = '0';
  String _expression = '';
  double? _firstOperand;
  String? _operator;
  bool _shouldResetDisplay = false;

  String _businessName = 'COMPRA Y VENTA DE DIVISAS';
  String _location = '';
  String _phone = '';
  String _tipo = 'Compra';
  String _monedaOrigen = 'PEN';
  String _monedaDestino = 'USD';

  final _currencies = ['PEN', 'USD', 'CLP', 'EUR'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final info = await SettingsService.loadBusinessInfo();
    setState(() {
      _businessName = info['businessName']!;
      _location = info['location']!;
      _phone = info['phone']!;
      _monedaOrigen = info['origen']!;
      _monedaDestino = info['destino']!;
    });
  }

  void _onNumberTap(String number) {
    setState(() {
      if (_display == '0' || _shouldResetDisplay) {
        _display = number;
        _shouldResetDisplay = false;
      } else {
        _display += number;
      }
    });
  }

  void _onDecimalTap() {
    setState(() {
      if (_shouldResetDisplay) {
        _display = '0.';
        _shouldResetDisplay = false;
      } else if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  void _onOperatorTap(String op) {
    setState(() {
      if (_operator != null && !_shouldResetDisplay) {
        _calculate();
      }
      _firstOperand = double.tryParse(_display) ?? 0;
      _operator = op;
      _shouldResetDisplay = true;
    });
  }

  void _calculate() {
    if (_firstOperand == null || _operator == null) return;
    final second = double.tryParse(_display) ?? 0;
    double result;
    switch (_operator) {
      case '÷':
        result = second == 0 ? 0 : _firstOperand! / second;
        break;
      case '×':
        result = _firstOperand! * second;
        break;
      case '−':
        result = _firstOperand! - second;
        break;
      case '+':
        result = _firstOperand! + second;
        break;
      default:
        result = second;
    }
    _expression = '${_formatNum(_firstOperand!)} $_operator ${_formatNum(second)}';
    _display = _formatNum(result);
    _operator = null;
    _firstOperand = null;
    _shouldResetDisplay = true;
  }

  void _onEqualsTap() {
    setState(() => _calculate());
  }

  void _onClearTap() {
    setState(() {
      _display = '0';
      _expression = '';
      _firstOperand = null;
      _operator = null;
      _shouldResetDisplay = false;
    });
  }

  String _formatNum(double n) {
    if (n == n.roundToDouble()) return n.toStringAsFixed(0);
    return n.toStringAsFixed(2);
  }

  /// Guarda la operación actual en el historial y devuelve los datos ya calculados
  /// (fecha/hora formateada y resultado numérico) para usarlos en imprimir o compartir.
  Future<Map<String, dynamic>?> _saveCurrentOperation() async {
    if (_expression.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Realiza un cálculo antes de continuar')),
      );
      return null;
    }

    final now = DateTime.now();
    final fechaHora = DateFormat('dd/MM/yyyy, HH:mm:ss').format(now);
    final resultado = double.tryParse(_display) ?? 0;

    final parts = _expression.split(' ');
    double monto = 0;
    double tipoCambio = 0;
    if (parts.length == 3) {
      monto = double.tryParse(parts[0]) ?? 0;
      tipoCambio = double.tryParse(parts[2]) ?? 0;
    }

    final op = Operation(
      fechaHora: now.toIso8601String(),
      tipo: _tipo,
      monedaOrigen: _monedaOrigen,
      monedaDestino: _monedaDestino,
      monto: monto,
      tipoCambio: tipoCambio,
      resultado: resultado,
    );
    await DatabaseHelper.instance.insertOperation(op);

    return {'fechaHora': fechaHora, 'resultado': resultado};
  }

  Future<void> _onPrintTap() async {
    final data = await _saveCurrentOperation();
    if (data == null) return;

    final pdfBytes = await PdfService.buildTicketPdf(
      businessName: _businessName,
      location: _location,
      phone: _phone,
      tipo: _tipo,
      expression: _expression,
      resultText: _formatNum(data['resultado'] as double),
      fechaHora: data['fechaHora'] as String,
    );

    // Abre el diálogo nativo de impresión de Android: ahí aparecerá tu
    // ticketera (si configuraste RawBT), "Guardar como PDF" y otras impresoras.
    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: 'ticket_cambio',
    );
  }

  Future<void> _onSharePdfTap() async {
    final data = await _saveCurrentOperation();
    if (data == null) return;

    final pdfBytes = await PdfService.buildTicketPdf(
      businessName: _businessName,
      location: _location,
      phone: _phone,
      tipo: _tipo,
      expression: _expression,
      resultText: _formatNum(data['resultado'] as double),
      fechaHora: data['fechaHora'] as String,
    );

    // Abre el selector de apps directo (WhatsApp, Drive, etc.), sin pasar por el diálogo de impresión.
    await Printing.sharePdf(bytes: pdfBytes, filename: 'ticket_cambio.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final now = DateFormat('dd/MM/yyyy, HH:mm:ss').format(DateTime.now());
    final resultLine = _operator == null && _expression.isNotEmpty ? '$_expression = $_display' : _expression;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TicketPreview(
            businessName: _businessName,
            location: _location,
            phone: _phone,
            tipo: _tipo,
            monedaOrigen: _monedaOrigen,
            monedaDestino: _monedaDestino,
            currencies: _currencies,
            expression: resultLine,
            result: _display,
            fechaHora: now,
            onTipoChanged: (v) => setState(() => _tipo = v),
            onOrigenChanged: (v) => setState(() => _monedaOrigen = v),
            onDestinoChanged: (v) => setState(() => _monedaDestino = v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _onPrintTap,
                    icon: const Icon(Icons.print),
                    label: const Text('Imprimir', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _onSharePdfTap,
                  icon: const Icon(Icons.share),
                  label: const Text('Compartir'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: Text(resultLine, style: const TextStyle(fontSize: 20, color: Colors.grey)),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(_display, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          _buildKeypad(),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    Widget key(String label, VoidCallback onTap, {Color? bg, Color? fg}) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: bg ?? Colors.white,
              foregroundColor: fg ?? Colors.black87,
              minimumSize: const Size(0, 64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: onTap,
            child: Text(label, style: const TextStyle(fontSize: 22)),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(children: [
          key('7', () => _onNumberTap('7')),
          key('8', () => _onNumberTap('8')),
          key('9', () => _onNumberTap('9')),
          key('÷', () => _onOperatorTap('÷'), bg: Colors.grey.shade200, fg: Colors.orange),
        ]),
        Row(children: [
          key('4', () => _onNumberTap('4')),
          key('5', () => _onNumberTap('5')),
          key('6', () => _onNumberTap('6')),
          key('×', () => _onOperatorTap('×'), bg: Colors.grey.shade200, fg: Colors.orange),
        ]),
        Row(children: [
          key('1', () => _onNumberTap('1')),
          key('2', () => _onNumberTap('2')),
          key('3', () => _onNumberTap('3')),
          key('−', () => _onOperatorTap('−'), bg: Colors.grey.shade200, fg: Colors.orange),
        ]),
        Row(children: [
          key('0', () => _onNumberTap('0')),
          key('.', _onDecimalTap),
          key('+', () => _onOperatorTap('+'), bg: Colors.grey.shade200, fg: Colors.orange),
          key('=', _onEqualsTap, bg: Colors.orange, fg: Colors.white),
        ]),
        Row(children: [
          key('C', _onClearTap, bg: Colors.grey.shade200),
        ]),
      ],
    );
  }
}
