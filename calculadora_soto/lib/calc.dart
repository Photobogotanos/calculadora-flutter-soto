import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Calculadora extends StatefulWidget {
  const Calculadora({super.key});

  @override
  State<Calculadora> createState() => _CalculadoraState();
}

class _CalculadoraState extends State<Calculadora> {
  String operacion = "";
  String resultado = "0";
  double? primerNumero;
  String? operadorActual;
  bool reiniciarPantalla = false;

  // Helper para parsear texto a double (ignorando los símbolos de operación si están al final)
  double _parsearPantalla(String valor) {
    String limpio = valor.replaceAll(',', '.');
    // Si termina en un operador visual, lo removemos para poder parsear el número limpio
    if (limpio.endsWith(' +') ||
        limpio.endsWith(' -') ||
        limpio.endsWith(' ×') ||
        limpio.endsWith(' ÷')) {
      limpio = limpio.substring(0, limpio.length - 2);
    }
    return double.tryParse(limpio) ?? 0.0;
  }

  // Helper para formatear los números eliminando decimales innecesarios
  String _formatearResultado(double numero) {
    if (numero == numero.toInt()) {
      return numero.toInt().toString();
    }
    String str = numero.toStringAsFixed(8);
    while (str.contains('.') && (str.endsWith('0') || str.endsWith('.'))) {
      str = str.substring(0, str.length - 1);
    }
    return str.replaceAll('.', ',');
  }

  // Obtener el símbolo visual que se concatenará en la pantalla
  String _obtenerSimbolo(String? operador) {
    if (operador == 'dividir') return '÷';
    if (operador == 'X') return '×';
    return operador ?? '';
  }

  void actionBoton(String valor) {
    setState(() {
      switch (valor) {
        case '=':
          _ejecutarCalculo();
          break;

        case 'borrarTodo':
          resultado = '0';
          operacion = '';
          primerNumero = null;
          operadorActual = null;
          reiniciarPantalla = false;
          break;

        case 'borrarNum':
          if (reiniciarPantalla) {
            resultado = '0';
          } else if (resultado != '0' && resultado.isNotEmpty) {
            // Si borramos y termina en espacio (después de un operador), borramos el operador completo
            if (resultado.endsWith(' ')) {
              resultado = resultado.substring(0, resultado.length - 3);
              operadorActual = null;
              primerNumero = null;
            } else {
              resultado = resultado.substring(0, resultado.length - 1);
            }
            if (resultado.isEmpty) resultado = '0';
          }
          break;

        case '%':
          double num = _parsearPantalla(resultado);
          resultado = _formatearResultado(num / 100);
          break;

        case 'dividir':
        case 'X':
        case '-':
        case '+':
          _manejarOperador(valor);
          break;

        case ',':
          if (reiniciarPantalla) {
            resultado = '0,';
            reiniciarPantalla = false;
          } else {
            // Buscamos si la parte que estamos escribiendo actualmente ya tiene coma
            List<String> partes = resultado.split(' ');
            if (!partes.last.contains(',')) {
              resultado += ',';
            }
          }
          break;

        case ' ':
          break;

        default: // Manejo de Números
          if (resultado == '0' || reiniciarPantalla) {
            resultado = valor;
            reiniciarPantalla = false;
          } else {
            resultado += valor;
          }
      }
    });
  }

  void _ejecutarCalculo() {
    if (primerNumero == null || operadorActual == null) return;

    // Obtenemos el segundo número aislando la última parte de la pantalla
    List<String> partes = resultado.split(' ');
    if (partes.length < 3) return; // Asegura que haya "Num1 Op Num2"

    double segundoNumero = _parsearPantalla(partes.last);
    double res = 0;

    switch (operadorActual) {
      case '+':
        res = primerNumero! + segundoNumero;
        break;
      case '-':
        res = primerNumero! - segundoNumero;
        break;
      case 'X':
        res = primerNumero! * segundoNumero;
        break;
      case 'dividir':
        res = segundoNumero != 0 ? primerNumero! / segundoNumero : 0;
        break;
    }

    // EFECTO DESEADO: Pasamos exactamente lo que el usuario veía abajo hacia arriba sin el "="
    operacion = resultado;

    // Mostramos el resultado limpio abajo
    resultado = _formatearResultado(res);

    // Reset de control interno
    primerNumero = null;
    operadorActual = null;
    reiniciarPantalla = true;
  }

  void _manejarOperador(String nuevoOperador) {
    String simbolo = _obtenerSimbolo(nuevoOperador);

    // Si ya hay un operador en pantalla (ej: "2 × 2") y presionan otro (ej: "+")
    if (operadorActual != null && resultado.split(' ').length == 3) {
      _ejecutarCalculo(); // Resuelve la operación anterior primero
      primerNumero = _parsearPantalla(resultado);
      resultado =
          '$resultado $simbolo '; // Añade el nuevo operador al resultado acumulado
    } else if (operadorActual != null && resultado.endsWith(' ')) {
      // Si el usuario cambia de opinión de operador (ej: pulsó + y luego quiere ×)
      resultado = resultado.substring(0, resultado.length - 3) + ' $simbolo ';
    } else {
      // Primer operador que se introduce
      primerNumero = _parsearPantalla(resultado);
      resultado = '$resultado $simbolo ';
    }

    operadorActual = nuevoOperador;
    reiniciarPantalla =
        false; // Falso para permitir seguir escribiendo al lado del operador
  }

  // Helper para asignar los colores originales de iOS
  Color obtenerColorBoton(String texto) {
    if (['borrarNum', 'borrarTodo', '%'].contains(texto)) {
      return const Color(0xFFA5A5A5); // Gris Claro superior
    }
    if (['dividir', 'X', '-', '+', '='].contains(texto)) {
      return const Color(0xFFFF9F0A); // Naranja iOS para operadores
    }
    return const Color(0xFF333333); // Gris Oscuro para números
  }

  Color obtenerColorTexto(String texto) {
    if (['borrarNum', 'borrarTodo', '%'].contains(texto)) {
      return Colors.black; // Letras negras en los botones gris claro
    }
    return Colors.white; // Letras blancas para el resto
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo negro como Apple
      body: SafeArea(
        child: Column(
          children: [
            // --- ÁREA DE PANTALLA ---
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                color: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (operacion.isNotEmpty)
                      Text(
                        operacion,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 30,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        resultado,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 80,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- TECLADO DE BOTONES ---
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      boton('borrarNum', icono: CupertinoIcons.delete_left),
                      boton('borrarTodo', textoAlternativo: 'AC'),
                      boton('%', icono: CupertinoIcons.percent),
                      boton('dividir', icono: CupertinoIcons.divide),
                    ],
                  ),
                  Row(
                    children: [
                      boton('7'),
                      boton('8'),
                      boton('9'),
                      boton('X', icono: CupertinoIcons.multiply),
                    ],
                  ),
                  Row(
                    children: [
                      boton('4'),
                      boton('5'),
                      boton('6'),
                      boton('-', icono: CupertinoIcons.minus),
                    ],
                  ),
                  Row(
                    children: [
                      boton('1'),
                      boton('2'),
                      boton('3'),
                      boton('+', icono: CupertinoIcons.plus),
                    ],
                  ),
                  Row(
                    children: [
                      boton('0', esAncho: true), // El cero usa doble espacio
                      boton(','),
                      boton('=', icono: CupertinoIcons.equal),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Constructor dinámico de botones adaptativo
  Widget boton(
    String texto, {
    IconData? icono,
    String? textoAlternativo,
    bool esAncho = false,
  }) {
    return Expanded(
      flex: esAncho ? 2 : 1, // Si es ancho toma 2 espacios en el Row
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: obtenerColorTexto(texto),
            backgroundColor: obtenerColorBoton(texto),
            shape: esAncho
                ? const StadiumBorder() // Ovalado para el botón '0'
                : const CircleBorder(), // Redondo perfecto para el resto
            padding: EdgeInsets.symmetric(vertical: esAncho ? 22 : 24),
            elevation: 0,
          ),
          onPressed: () => actionBoton(texto),
          child: icono != null
              ? Icon(icono, size: 36)
              : Text(
                  textoAlternativo ?? texto,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                  ),
                ),
        ),
      ),
    );
  }
}
