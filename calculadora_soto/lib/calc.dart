import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Calculadora extends StatefulWidget {
  const Calculadora({super.key});

  @override
  State<Calculadora> createState() => _CalculadoraState();
}

class _CalculadoraState extends State<Calculadora> {
  String operacion = '';
  String resultado = '0'; 
  double? primerNumero;
  String? operadorActual;
  bool reiniciarPantalla = false;

  void actionBoton(String valor) {
    setState(() {
      switch (valor) {
        case '=':
          if (primerNumero != null &&
              operadorActual != null &&
              resultado.isNotEmpty) {
            double segundoNumero = double.parse(resultado.replaceAll(',', '.'));
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

            // Formatearr el resultado eliminando el .0 innecesario
            String resString = res.toString();
            if (resString.endsWith('.0')) {
              resString = resString.substring(0, resString.length - 2);
            }

            operacion = '';
            resultado = resString.replaceAll(
              '.',
              ',',
            ); // Mostramos coma al usuario
            primerNumero = null;
            operadorActual = null;
            reiniciarPantalla = true;
          }
          break;

        case 'borrarTodo':
          resultado = '0';
          operacion = '';
          primerNumero = null;
          operadorActual = null;
          reiniciarPantalla = false;
          break;

        case 'borrarNum':
          if (resultado.isNotEmpty && resultado != '0') {
            resultado = resultado.substring(0, resultado.length - 1);
            if (resultado.isEmpty) resultado = '0';
          }
          break;

        case '%':
          if (resultado != '0') {
            double num = double.parse(resultado.replaceAll(',', '.'));
            resultado = (num / 100).toString().replaceAll('.', ',');
          }
          break;

        case 'dividir':
        case 'X':
        case '-':
        case '+':
          if (resultado.isNotEmpty) {
            primerNumero = double.parse(resultado.replaceAll(',', '.'));
            operadorActual = valor;

            // Mapeo visual para el histórico superior
            String simboloOperador = valor == 'dividir'
                ? '÷'
                : (valor == 'X' ? '×' : valor);
            operacion = '$resultado $simboloOperador';
            reiniciarPantalla = true;
          }
          break;

        case ',':
          if (!resultado.contains(',')) {
            resultado += ',';
          }
          break;

        case ' ': // Botón vacío estético
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
                      // Evita que números gigantes rompan el diseño clonando el auto-shrink de iOS
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
      flex: esAncho
          ? 2
          : 1, // Si es ancho toma 2 espacios en el Row (Clave para el "0")
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
              ? Icon(icono, size: 30)
              : Text(
                  textoAlternativo ?? texto,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                  ),
                ),
        ),
      ),
    );
  }
}
