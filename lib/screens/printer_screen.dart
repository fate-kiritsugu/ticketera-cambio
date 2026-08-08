import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/printer_service.dart';
import '../services/settings_service.dart';

class PrinterScreen extends StatefulWidget {
  const PrinterScreen({super.key});

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _connectedDevice;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _requestPermissions();
    await _loadDevices();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  Future<void> _loadDevices() async {
    setState(() => _loading = true);
    try {
      final devices = await PrinterService.instance.getBondedDevices();
      setState(() => _devices = devices);
    } catch (e) {
      // Sin dispositivos disponibles o Bluetooth apagado
    }
    setState(() => _loading = false);
  }

  Future<void> _connect(BluetoothDevice device) async {
    setState(() => _loading = true);
    try {
      await PrinterService.instance.connect(device);
      await SettingsService.savePrinter(device.address ?? '', device.name ?? '');
      setState(() => _connectedDevice = device);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Conectado a ${device.name}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo conectar')));
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _testPrint() async {
    try {
      await PrinterService.instance.printTicket(
        businessName: 'Prueba de impresión',
        location: 'Ticketera Cambio',
        phone: '',
        expression: '100 ÷ 3.70',
        resultText: '27.03',
        fechaHora: DateTime.now().toString(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Error al imprimir: conecta una impresora primero')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Impresora Bluetooth')),
      body: RefreshIndicator(
        onRefresh: _loadDevices,
        child: Column(
          children: [
            if (_loading) const LinearProgressIndicator(),
            Expanded(
              child: _devices.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No hay dispositivos emparejados.\nEmpareja tu ticketera desde Bluetooth de Android primero.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _devices.length,
                      itemBuilder: (context, i) {
                        final d = _devices[i];
                        return ListTile(
                          leading: const Icon(Icons.print),
                          title: Text(d.name ?? 'Desconocido'),
                          subtitle: Text(d.address ?? ''),
                          trailing: _connectedDevice?.address == d.address
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                          onTap: () => _connect(d),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _testPrint,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                  child: const Padding(padding: EdgeInsets.all(12), child: Text('Imprimir prueba')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
