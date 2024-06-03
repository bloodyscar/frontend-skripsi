import 'package:flutter/material.dart';
import 'package:frontend_skripsi/component/custom_text.dart';
import 'package:frontend_skripsi/component/custom_text_field.dart';
import 'package:frontend_skripsi/provider/home_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  getInit(BuildContext context) async {
    final localStorage = await SharedPreferences.getInstance();
    // var isLogged = localStorage.getBool('isLogin') ?? false;
    var token = localStorage.getString('token');
    print("token: $token");
    token != null ? Navigator.pushNamed(context, '/home-screen') : '/';
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getInit(context);
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controlNpk = TextEditingController();
    TextEditingController controllerPassword = TextEditingController();
    HomeProvider homeProvider = Provider.of<HomeProvider>(context);
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(right: 10.0, left: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 30,
            ),
            const CustomText(
              'Selamat Datang',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 30,
            ),
            CustomTextField(
              controller: controlNpk,
              labelText: 'No. Karyawan',
              prefixIcon: Icons.person,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                print(value);
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 12,
            ),
            CustomTextField(
              controller: controllerPassword,
              labelText: 'Password',
              prefixIcon: Icons.lock,
              obscureText: true,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 12,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  String npk = controlNpk.text;
                  String password = controllerPassword.text;
                  if (npk.isNotEmpty && password.isNotEmpty) {
                    homeProvider.login(npk, password, context);
                  }
                },
                style: ButtonStyle(
                  minimumSize:
                      MaterialStateProperty.all(const Size(double.infinity, 0)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("Login"),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
