import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      // ignore: deprecated_member_use
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      title: 'Academia Flow',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue[800],
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade800, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIconColor: Colors.blue[800],
          labelStyle: const TextStyle(color: Colors.grey),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[800],
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const WelcomeScreen();
      },
    );
  }
}

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
            Icon(Icons.fitness_center, size: 100, color: Colors.blue[800]),
            Text(
              "ACADEMIA",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.blue[800],
                letterSpacing: -1,
              ),
            ),
            const Text(
              "SISTEMA DE GESTÃO",
              style: TextStyle(fontSize: 12, color: Colors.grey, letterSpacing: 3),
            ),
            const SizedBox(height: 80),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text("ENTRAR"),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue[800]!, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  "CRIAR CONTA",
                  style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  bool _isEmailValid(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Preencha todos os campos");
      return;
    }

    if (!_isEmailValid(email)) {
      _showMessage("E-mail inválido");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = "Erro ao fazer login";
      if (e.code == 'user-not-found') {
        message = 'Nenhum usuário encontrado para esse e-mail.';
      } else if (e.code == 'wrong-password') {
        message = 'Senha incorreta fornecida.';
      } else if (e.code == 'invalid-credential') {
        message = 'E-mail ou senha incorretos.';
      }
      _showMessage(message);
    } catch (e) {
      _showMessage("Ocorreu um erro inesperado.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: Colors.red));
  }

  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Recuperar Senha"),
          content: TextField(
            controller: resetEmailController,
            decoration: const InputDecoration(labelText: "Digite seu e-mail", hintText: "seu@email.com"),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                final email = resetEmailController.text.trim();
                if (!_isEmailValid(email)) {
                   ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text("E-mail inválido")));
                   return;
                }
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("E-mail de recuperação enviado!"), backgroundColor: Colors.green));
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao enviar e-mail."), backgroundColor: Colors.red));
                  }
                }
              },
              child: const Text("Enviar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: IconThemeData(color: Colors.blue[800])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Login", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue[900])),
            const SizedBox(height: 10),
            const Text("Acesse sua área exclusiva.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 50),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "E-mail", prefixIcon: Icon(Icons.email_outlined)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Senha", prefixIcon: Icon(Icons.lock_outline)),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showForgotPasswordDialog,
                child: Text("Esqueceu a senha?", style: TextStyle(color: Colors.blue[800])),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("ACESSAR SISTEMA"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  bool _isEmailValid(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage("Preencha todos os campos");
      return;
    }

    if (!_isEmailValid(email)) {
      _showMessage("E-mail inválido");
      return;
    }

    if (password.length < 6) {
      _showMessage("A senha deve ter pelo menos 6 caracteres");
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user?.updateDisplayName(name);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Conta criada com sucesso!"), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String message = "Erro ao criar conta";
      if (e.code == 'weak-password') {
        message = 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Já existe uma conta com este e-mail.';
      }
      _showMessage(message);
    } catch (e) {
      _showMessage("Ocorreu um erro inesperado.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: IconThemeData(color: Colors.blue[800])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nova Conta", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue[900])),
            const SizedBox(height: 10),
            const Text("Cadastre-se para começar.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Nome Completo", prefixIcon: Icon(Icons.assignment_ind_outlined)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "E-mail", prefixIcon: Icon(Icons.email_outlined)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Crie uma Senha", prefixIcon: Icon(Icons.lock_outline)),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("FINALIZAR CADASTRO"),
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
    final user = FirebaseAuth.instance.currentUser;
    String displayName = "Atleta";
    if (user != null && user.displayName != null && user.displayName!.isNotEmpty) {
      displayName = user.displayName!;
    }

    return Scaffold(
      appBar: AppBar(

        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
              } else if (value == 'delete') {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text("Excluir Conta"),
                    content: const Text("ATENÇÃO: Tem certeza que deseja excluir sua conta permanentemente? Você perderá o acesso."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          try {
                            await FirebaseAuth.instance.currentUser?.delete();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Conta excluída com sucesso!"), backgroundColor: Colors.green));
                            }
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'requires-recent-login') {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text("Por segurança, saia da conta e faça login novamente antes de excluir."),
                                  backgroundColor: Colors.red,
                                ));
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao excluir conta."), backgroundColor: Colors.red));
                              }
                            }
                          }
                        },
                        child: const Text("Excluir"),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [Icon(Icons.logout, color: Colors.black54), SizedBox(width: 10), Text("Sair da Conta")],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [Icon(Icons.delete_forever, color: Colors.red), SizedBox(width: 10), Text("Excluir Conta", style: TextStyle(color: Colors.red))],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Olá, ${displayName.split(' ').first}!",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "O que você deseja gerenciar hoje?",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildMenuCard(context, "Exercícios", Colors.blue, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ExercisesScreen()));
                  }),
                  _buildMenuCard(context, "Fichas de Treino", Colors.orange, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkoutsScreen()));
                  }),
                  _buildMenuCard(context, "Alimentação", Colors.green, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const FoodScreen()));
                  }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// CRUD DE EXERCÍCIOS
// ------------------------------------------------------------------

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  String _selectedFilter = 'Todos';
  final List<String> _filters = ['Todos', 'Peito', 'Costas', 'Perna', 'Ombro', 'Braço', 'Abdômen', 'Aeróbico'];

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance.collection('exercises').orderBy('name');
    if (_selectedFilter != 'Todos') {
      query = FirebaseFirestore.instance.collection('exercises').where('muscleGroup', isEqualTo: _selectedFilter).orderBy('name');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Exercícios"),
      ),
      body: Column(
        children: [
          // Barra de Filtro
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor: Colors.blue[100],
                  ),
                );
              },
            ),
          ),
          
          // Lista do Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Nenhum exercício encontrado.", style: TextStyle(color: Colors.grey)));
                }

                final exercises = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final doc = exercises[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[100],
                          child: Icon(Icons.fitness_center, color: Colors.blue[800]),
                        ),
                        title: Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(data['muscleGroup'] ?? ''),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExerciseDetailScreen(exerciseId: doc.id, exerciseData: data),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ExerciseFormScreen()));
        },
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ExerciseDetailScreen extends StatelessWidget {
  final String exerciseId;
  final Map<String, dynamic> exerciseData;

  const ExerciseDetailScreen({super.key, required this.exerciseId, required this.exerciseData});

  void _deleteExercise(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir Exercício"),
        content: const Text("Tem certeza que deseja excluir este exercício? Esta ação não pode ser desfeita."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('exercises').doc(exerciseId).delete();
              if (context.mounted) {
                Navigator.pop(context); // Fechar Dialog
                Navigator.pop(context); // Voltar para Lista
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Exercício excluído!")));
              }
            },
            child: const Text("Excluir"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(exerciseData['name'] ?? 'Detalhes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExerciseFormScreen(exerciseId: exerciseId, exerciseData: exerciseData),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteExercise(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Grupo Muscular", style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 5),
            Text(exerciseData['muscleGroup'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 30),
            const Text("Descrição / Instruções", style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 5),
            Text(exerciseData['description'] ?? 'Sem descrição.', style: const TextStyle(fontSize: 16)),
            const Divider(height: 30),
            const Text("Vídeo de Execução (Link)", style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 5),
            Text(
              (exerciseData['videoUrl'] != null && exerciseData['videoUrl'].toString().isNotEmpty) 
                  ? exerciseData['videoUrl'] 
                  : 'Nenhum vídeo cadastrado.',
              style: const TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline),
            ),
          ],
        ),
      ),
    );
  }
}

class ExerciseFormScreen extends StatefulWidget {
  final String? exerciseId; 
  final Map<String, dynamic>? exerciseData;

  const ExerciseFormScreen({super.key, this.exerciseId, this.exerciseData});

  @override
  State<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends State<ExerciseFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _videoController = TextEditingController();
  
  String? _selectedMuscleGroup;
  final List<String> _muscleGroups = ['Peito', 'Costas', 'Perna', 'Ombro', 'Braço', 'Abdômen', 'Aeróbico'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.exerciseData != null) {
      _nameController.text = widget.exerciseData!['name'] ?? '';
      _descController.text = widget.exerciseData!['description'] ?? '';
      _videoController.text = widget.exerciseData!['videoUrl'] ?? '';
      _selectedMuscleGroup = widget.exerciseData!['muscleGroup'];
    }
  }

  Future<void> _saveExercise() async {
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();
    final video = _videoController.text.trim();

    if (name.isEmpty || _selectedMuscleGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nome e Grupo Muscular são obrigatórios"), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'name': name,
      'muscleGroup': _selectedMuscleGroup,
      'description': desc,
      'videoUrl': video,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (widget.exerciseId == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('exercises').add(data);
      } else {
        await FirebaseFirestore.instance.collection('exercises').doc(widget.exerciseId).update(data);
      }
      
      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Exercício salvo com sucesso!"), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao salvar exercício."), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseId == null ? "Novo Exercício" : "Editar Exercício"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Nome do Exercício *", hintText: "Ex: Supino Reto"),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _selectedMuscleGroup,
              decoration: const InputDecoration(labelText: "Grupo Muscular *"),
              items: _muscleGroups.map((String group) {
                return DropdownMenuItem<String>(value: group, child: Text(group));
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMuscleGroup = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: "Descrição / Instruções", hintText: "Como executar o movimento..."),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _videoController,
              decoration: const InputDecoration(labelText: "Link do Vídeo (Opcional)", hintText: "https://youtube.com/..."),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveExercise,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("SALVAR EXERCÍCIO"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// CRUD DE FICHAS DE TREINO
// ------------------------------------------------------------------

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fichas de Treino"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('workouts').orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Nenhuma ficha encontrada.", style: TextStyle(color: Colors.grey)));
          }

          final workouts = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final doc = workouts[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange[100],
                    child: Text(data['letter'] ?? '', style: TextStyle(color: Colors.orange[800], fontWeight: FontWeight.bold)),
                  ),
                  title: Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkoutDetailScreen(workoutId: doc.id, workoutData: data),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const WorkoutFormScreen()));
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class WorkoutDetailScreen extends StatefulWidget {
  final String workoutId;
  final Map<String, dynamic> workoutData;

  const WorkoutDetailScreen({super.key, required this.workoutId, required this.workoutData});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  void _deleteWorkout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir Ficha"),
        content: const Text("Tem certeza que deseja excluir esta ficha?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('workouts').doc(widget.workoutId).delete();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ficha excluída!")));
              }
            },
            child: const Text("Excluir"),
          ),
        ],
      ),
    );
  }

  void _updateWeight(String exerciseName, String newWeight, int exerciseIndex) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('workouts').doc(widget.workoutId);
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        List<dynamic> exercises = docSnap.data()?['exercises'] ?? [];
        if (exercises.length > exerciseIndex) {
          exercises[exerciseIndex]['weight'] = newWeight;
          await docRef.update({'exercises': exercises});
        }
      }
    } catch (e) {
      debugPrint("Erro ao atualizar peso: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workoutData['name'] ?? 'Detalhes do Treino'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkoutFormScreen(workoutId: widget.workoutId, workoutData: widget.workoutData),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteWorkout(context),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('workouts').doc(widget.workoutId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Ficha não encontrada."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final exercises = data['exercises'] as List<dynamic>? ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text("Exercícios (${exercises.length})", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: exercises.isEmpty
                    ? const Center(child: Text("Nenhum exercício cadastrado.", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: exercises.length,
                        itemBuilder: (context, index) {
                          final ex = exercises[index] as Map<String, dynamic>;
                          final weightController = TextEditingController(text: ex['weight'] ?? '');

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ex['name'] ?? 'Exercício sem nome', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Séries: ${ex['sets'] ?? '-'}", style: const TextStyle(color: Colors.black87)),
                                          Text("Reps: ${ex['reps'] ?? '-'}", style: const TextStyle(color: Colors.black87)),
                                          Text("Descanso: ${ex['restTime'] ?? '-'}", style: const TextStyle(color: Colors.black87)),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: TextField(
                                          controller: weightController,
                                          decoration: const InputDecoration(
                                            labelText: "Carga (kg)",
                                            isDense: true,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          ),
                                          onSubmitted: (value) {
                                            _updateWeight(ex['name'] ?? '', value, index);
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Carga salva!"), duration: Duration(seconds: 1)));
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class WorkoutFormScreen extends StatefulWidget {
  final String? workoutId;
  final Map<String, dynamic>? workoutData;

  const WorkoutFormScreen({super.key, this.workoutId, this.workoutData});

  @override
  State<WorkoutFormScreen> createState() => _WorkoutFormScreenState();
}

class _WorkoutFormScreenState extends State<WorkoutFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _letterController = TextEditingController();
  
  List<Map<String, dynamic>> _exercises = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.workoutData != null) {
      _nameController.text = widget.workoutData!['name'] ?? '';
      _letterController.text = widget.workoutData!['letter'] ?? '';
      if (widget.workoutData!['exercises'] != null) {
        _exercises = List<Map<String, dynamic>>.from(widget.workoutData!['exercises']);
      }
    }
  }

  void _addExercise() {
    showDialog(
      context: context,
      builder: (context) {
        final exNameController = TextEditingController();
        final exSetsController = TextEditingController();
        final exRepsController = TextEditingController();
        final exRestController = TextEditingController();

        return AlertDialog(
          title: const Text("Adicionar Exercício"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: exNameController, decoration: const InputDecoration(labelText: "Nome *")),
                const SizedBox(height: 10),
                TextField(controller: exSetsController, decoration: const InputDecoration(labelText: "Séries (ex: 3)")),
                const SizedBox(height: 10),
                TextField(controller: exRepsController, decoration: const InputDecoration(labelText: "Repetições (ex: 10 a 12)")),
                const SizedBox(height: 10),
                TextField(controller: exRestController, decoration: const InputDecoration(labelText: "Descanso (ex: 60s)")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () {
                if (exNameController.text.trim().isEmpty) return;
                setState(() {
                  _exercises.add({
                    'name': exNameController.text.trim(),
                    'sets': exSetsController.text.trim(),
                    'reps': exRepsController.text.trim(),
                    'restTime': exRestController.text.trim(),
                    'weight': '',
                  });
                });
                Navigator.pop(context);
              },
              child: const Text("Adicionar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveWorkout() async {
    final name = _nameController.text.trim();
    final letter = _letterController.text.trim();

    if (name.isEmpty || letter.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nome e Letra são obrigatórios"), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'name': name,
      'letter': letter,
      'exercises': _exercises,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      if (widget.workoutId == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('workouts').add(data);
      } else {
        await FirebaseFirestore.instance.collection('workouts').doc(widget.workoutId).update(data);
      }
      
      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ficha salva com sucesso!"), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao salvar ficha."), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workoutId == null ? "Nova Ficha" : "Editar Ficha"),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Nome do Treino *", hintText: "Ex: Treino de Peito"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _letterController,
                    decoration: const InputDecoration(labelText: "Letra *", hintText: "Ex: A"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Exercícios", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add),
                  label: const Text("Adicionar"),
                )
              ],
            ),
            const SizedBox(height: 10),
            _exercises.isEmpty
                ? const Text("Nenhum exercício adicionado.", style: TextStyle(color: Colors.grey))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _exercises.length,
                    itemBuilder: (context, index) {
                      final ex = _exercises[index];
                      return Card(
                        child: ListTile(
                          title: Text(ex['name']),
                          subtitle: Text("Séries: ${ex['sets']} | Reps: ${ex['reps']} | Descanso: ${ex['restTime']}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _exercises.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: _isLoading ? null : _saveWorkout,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("SALVAR FICHA"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// CRUD DE ALIMENTAÇÃO
// ------------------------------------------------------------------

class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alimentação"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('meals').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Nenhuma refeição registrada.", style: TextStyle(color: Colors.grey)));
          }

          final meals = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: meals.length,
            itemBuilder: (context, index) {
              final doc = meals[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[100],
                    child: Icon(Icons.restaurant, color: Colors.green[800]),
                  ),
                  title: Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(data['description'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await FirebaseFirestore.instance.collection('meals').doc(doc.id).delete();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Refeição removida!")));
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const FoodFormScreen()));
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class FoodFormScreen extends StatefulWidget {
  const FoodFormScreen({super.key});

  @override
  State<FoodFormScreen> createState() => _FoodFormScreenState();
}

class _FoodFormScreenState extends State<FoodFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveMeal() async {
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("O nome da refeição é obrigatório"), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('meals').add({
        'name': name,
        'description': desc,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Refeição registrada!"), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao salvar refeição."), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar Refeição"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "O que você comeu? *", hintText: "Ex: Arroz com Frango"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: "Detalhes (Opcional)", hintText: "Ex: 200g de frango, salada"),
              maxLines: 3,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _isLoading ? null : _saveMeal,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("SALVAR REFEIÇÃO"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}