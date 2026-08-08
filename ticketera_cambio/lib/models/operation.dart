class Operation {
  final int? id;
  final String fechaHora; // ISO8601
  final String tipo; // 'Compra' o 'Venta'
  final String monedaOrigen;
  final String monedaDestino;
  final double monto;
  final double tipoCambio;
  final double resultado;
  final String? cliente;

  Operation({
    this.id,
    required this.fechaHora,
    required this.tipo,
    required this.monedaOrigen,
    required this.monedaDestino,
    required this.monto,
    required this.tipoCambio,
    required this.resultado,
    this.cliente,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fecha_hora': fechaHora,
      'tipo': tipo,
      'moneda_origen': monedaOrigen,
      'moneda_destino': monedaDestino,
      'monto': monto,
      'tipo_cambio': tipoCambio,
      'resultado': resultado,
      'cliente': cliente,
    };
  }

  factory Operation.fromMap(Map<String, dynamic> map) {
    return Operation(
      id: map['id'] as int?,
      fechaHora: map['fecha_hora'] as String,
      tipo: map['tipo'] as String,
      monedaOrigen: map['moneda_origen'] as String,
      monedaDestino: map['moneda_destino'] as String,
      monto: (map['monto'] as num).toDouble(),
      tipoCambio: (map['tipo_cambio'] as num).toDouble(),
      resultado: (map['resultado'] as num).toDouble(),
      cliente: map['cliente'] as String?,
    );
  }
}
