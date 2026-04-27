import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const AcademiaApp(),
    ),
  );
}

class AcademiaApp extends StatelessWidget {
  const AcademiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Removi o useInheritedMediaQuery que dava erro azul
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      
      debugShowCheckedModeBanner: false,
      title: 'Fitness Pro',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFCCFF00),
        scaffoldBackgroundColor: const Color(0xFF121212),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          // Atualizado de withOpacity para withAlpha para evitar avisos
          fillColor: Colors.white.withAlpha(13), 
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFFCCFF00), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIconColor: const Color(0xFFCCFF00),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFCCFF00),
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

// --- TELA DE BOAS-VINDAS ---
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, size: 100, color: Color(0xFFCCFF00)),
            const SizedBox(height: 20),
            const Text("FITNESS PRO", style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, letterSpacing: 3)),
            const Text("FOCO • FORÇA • RESULTADO", style: TextStyle(fontSize: 12, color: Colors.grey, letterSpacing: 2)),
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                child: const Text("ENTRAR"),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCCFF00), width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("CRIAR CONTA", style: TextStyle(color: Color(0xFFCCFF00))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- TELA DE LOGIN ---
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Login", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            const TextField(decoration: InputDecoration(labelText: "E-mail", prefixIcon: Icon(Icons.email_outlined))),
            const SizedBox(height: 20),
            const TextField(obscureText: true, decoration: InputDecoration(labelText: "Senha", prefixIcon: Icon(Icons.lock_outline))),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen())),
                child: const Text("ACESSAR SISTEMA"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- TELA DE CADASTRO ---
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Nova Conta", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            const TextField(decoration: InputDecoration(labelText: "Nome Completo", prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 20),
            const TextField(decoration: InputDecoration(labelText: "E-mail", prefixIcon: Icon(Icons.email_outlined))),
            const SizedBox(height: 20),
            const TextField(obscureText: true, decoration: InputDecoration(labelText: "Senha", prefixIcon: Icon(Icons.lock_outline))),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Conta criada!")));
                  Navigator.pop(context);
                },
                child: const Text("FINALIZAR CADASTRO"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Academia")),
      body: const Center(child: Text("BEM-VINDO AO TREINO!", style: TextStyle(fontSize: 20))),
    );
  }
}