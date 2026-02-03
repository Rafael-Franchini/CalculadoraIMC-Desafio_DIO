class IMC {
  final double peso;
  final double altura;
  final double imc;
  final String tipo;
  final DateTime data;

  IMC({
    required this.peso,
    required this.altura,
    DateTime? data,
    required this.imc,
    required this.tipo,
  }) : data = data ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'peso': peso,
    'altura': altura,
    'data': data.toIso8601String(),
    'imc': imc,
    'tipo': tipo,
  };

  factory IMC.fromJson(Map<String, dynamic> json) => IMC(
    peso: json['peso'],
    altura: json['altura'],
    imc: json['imc'],
    tipo: json['tipo'],
    data: DateTime.parse(json['data']),
  );
}
