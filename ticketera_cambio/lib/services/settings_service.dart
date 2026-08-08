import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _keyBusinessName = 'business_name';
  static const _keyLocation = 'location';
  static const _keyPhone = 'phone';
  static const _keyDefaultOrigen = 'default_origen';
  static const _keyDefaultDestino = 'default_destino';
  static const _keyPrinterAddress = 'printer_address';
  static const _keyPrinterName = 'printer_name';

  static Future<Map<String, String>> loadBusinessInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'businessName': prefs.getString(_keyBusinessName) ?? 'COMPRA Y VENTA DE DIVISAS',
      'location': prefs.getString(_keyLocation) ?? '',
      'phone': prefs.getString(_keyPhone) ?? '',
      'origen': prefs.getString(_keyDefaultOrigen) ?? 'PEN',
      'destino': prefs.getString(_keyDefaultDestino) ?? 'USD',
    };
  }

  static Future<void> saveBusinessInfo({
    required String businessName,
    required String location,
    required String phone,
    required String origen,
    required String destino,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBusinessName, businessName);
    await prefs.setString(_keyLocation, location);
    await prefs.setString(_keyPhone, phone);
    await prefs.setString(_keyDefaultOrigen, origen);
    await prefs.setString(_keyDefaultDestino, destino);
  }

  static Future<void> savePrinter(String address, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPrinterAddress, address);
    await prefs.setString(_keyPrinterName, name);
  }

  static Future<Map<String, String>?> loadPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    final address = prefs.getString(_keyPrinterAddress);
    final name = prefs.getString(_keyPrinterName);
    if (address == null) return null;
    return {'address': address, 'name': name ?? ''};
  }
}
