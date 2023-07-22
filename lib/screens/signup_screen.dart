import 'package:google_mao/components/button_large.dart';
import 'package:google_mao/components/my_textfield.dart';
import 'package:google_mao/resources/auth_method.dart';
import 'package:google_mao/screens/login_page.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  final _addressController = TextEditingController();

  final roles = ["Çalışan", "Şöför", "Stajyer"];
  String _defaultValue = "Çalışan";

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void signUpUser() async {
    if (_passwordController.text == _passwordConfController.text) {
      String res = await AuthMethods().signUpUser(
          email: _emailController.text.trim(),
          password: _passwordConfController.text.trim(),
          name: _nameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          position: _defaultValue,
          carPlate: _vehiclePlateController.text,
          userAddress: _addressController.text);
      if (res != "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("bir hatayla karşılaşıldı"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Kaydol Başarılı"),
          ),
        );
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Şifreleriniz Uyuşmuyor"),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                const Image(
                  width: 200,
                  image: AssetImage("assets/Havelsan_logo.svg.png"),
                ),
                Text(
                  "HAVELSAN servis takip sistemi",
                  style: TextStyle(
                      color: Colors.grey[700], fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: _nameController,
                  hintText: "İsim",
                  isObscure: false,
                ),
                MyTextField(
                  controller: _lastNameController,
                  hintText: "Soyisim",
                  isObscure: false,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Şirketteki Rolünüz : "),
                    DropdownButton<String>(
                        value: _defaultValue,
                        items:
                            roles.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? dummy) {
                          setState(() {
                            _defaultValue = dummy!;
                          });
                        }),
                  ],
                ),
                _defaultValue == roles[1]
                    ? MyTextField(
                        controller: _vehiclePlateController,
                        hintText: "Araç Plakası",
                        isObscure: false)
                    : MyTextField(
                        controller: _addressController,
                        hintText: "Addresiniz",
                        isObscure: false),
                const SizedBox(height: 10),
                MyTextField(
                  controller: _emailController,
                  hintText: "E-mail",
                  isObscure: false,
                ),
                MyTextField(
                  controller: _passwordController,
                  hintText: "Şifre",
                  isObscure: true,
                ),
                MyTextField(
                  controller: _passwordConfController,
                  hintText: "Şifre Tekrar",
                  isObscure: true,
                ),
                const SizedBox(height: 25),
                ButtonLarge(title: "Kaydol", onTapFunction: signUpUser),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Zaten Üye Misiniz?",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Giriş Yap",
                        style:
                            TextStyle(color: Color.fromARGB(255, 16, 99, 166)),
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
