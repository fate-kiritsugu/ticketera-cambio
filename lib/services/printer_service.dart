import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class PrinterService {
  PrinterService._internal();
  static final PrinterService instance = PrinterService._internal();

  final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;

  Future<List<BluetoothDevice>> getBondedDevices() async {
    return await _bluetooth.getBondedDevices();
  }

  Future<bool> isConnected() async {
    return (await _bluetooth.isConnected) ?? false;
  }

  Future<void> connect(BluetoothDevice device) async {
    await _bluetooth.connect(device);
  }

  Future<void> disconnect() async {
    await _bluetooth.disconnect();
  }

  /// Envía el ticket a la ticketera térmica conectada.
  /// Lanza una excepción si no hay impresora conectada.
  Future<void> printTicket({
    required String businessName,
    required String location,
    required String phone,
    required String expression,
    required String resultText,
    required String fechaHora,
  }) async {
    final connected = await isConnected();
    if (!connected) {
      throw Exception('No hay impresora conectada');
    }

    // size: 0=normal 1=mediano 2=grande 3=extra grande | align: 0=izq 1=centro 2=der
    _bluetooth.printCustom(businessName.toUpperCase(), 2, 1);
    _bluetooth.printNewLine();
    if (location.isNotEmpty) {
      _bluetooth.printCustom(location, 1, 1);
    }
    if (phone.isNotEmpty) {
      _bluetooth.printCustom(phone, 1, 1);
    }
    _bluetooth.printNewLine();
    _bluetooth.printCustom(expression, 1, 1);
    _bluetooth.printCustom('------', 1, 1);
    _bluetooth.printCustom(resultText, 3, 1);
    _bluetooth.printNewLine();
    _bluetooth.printCustom(fechaHora, 0, 1);
    _bluetooth.printNewLine();
    _bluetooth.printNewLine();
    _bluetooth.paperCut();
  }
}
