import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Definir la clave global para validar el formulario
  final _formKey = GlobalKey<FormState>();

  // Definir los controladores para capturar el texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Limpiar los controladores cuando el widget se destruye
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey, // Asignamos la clave al formulario
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- IMAGEN REDONDA AL INICIO ---
                const CircleAvatar(
                  radius: 60.0, // Define el tamaño del círculo
                  backgroundColor: Colors.transparent,
                  // Puedes usar una imagen de internet (NetworkImage) o un asset local (AssetImage)
                  backgroundImage: AssetImage('assets/images/RSlUy.jpg')
                ),
                const SizedBox(height: 32.0),

                // --- CAMPO DE EMAIL ---
                TextFormField(
                  controller: _emailController, // Asignamos el controlador
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu correo';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Ingresa un correo válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // --- CAMPO DE CONTRASEÑA ---
                TextFormField(
                  controller: _passwordController, // Asignamos el controlador
                  obscureText: true, // Oculta el texto
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),

                // --- BOTÓN DE ENTRAR ---
                SizedBox(
                  width: double.infinity,
                  height: 50.0,
                  child: ElevatedButton(
                    onPressed: () {
                      // Validamos si el formulario es correcto
                      if (_formKey.currentState!.validate()) {
                        // Accedemos a los valores usando los controllers
                        String email = _emailController.text;
                        String password = _passwordController.text;

                        // Aquí harías la lógica de autenticación
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Iniciando sesión con: $email')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: const Text(
                      'Iniciar Sesión',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
