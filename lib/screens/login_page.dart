import 'package:demo_app/components/button_large.dart';
import 'package:demo_app/components/my_textfield.dart';
import 'package:demo_app/resources/auth_method.dart';
import 'package:demo_app/screens/signup_screen.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void logInUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().logInUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim());

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }

    if (res != "success") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email veya Şifre yanlış Girilmiştir"),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(
                  color: Color.fromARGB(255, 16, 99, 166))
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      const Image(
                        width: 300,
                        image: AssetImage("assets/Havelsan_logo.svg.png"),
                      ),
                      Text(
                        "HAVELSAN servis takip sistemi",
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 25),
                      MyTextField(
                        controller: _emailController,
                        hintText: "E-mail",
                        icon: const Icon(Icons.person_2_outlined),
                        isObscure: false,
                      ),
                      const SizedBox(height: 10),
                      MyTextField(
                        controller: _passwordController,
                        hintText: "Password",
                        icon: const Icon(Icons.lock),
                        isObscure: true,
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Şifremi Unuttum ?",
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      ButtonLarge(title: "Giriş Yap", onTapFunction: logInUser),
                      const SizedBox(height: 50),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Üye Değil Misiniz?",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => SignUpScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Kaydol",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 16, 99, 166)),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
