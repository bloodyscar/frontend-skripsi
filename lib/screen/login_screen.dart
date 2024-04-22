import 'package:flutter/material.dart';
import 'package:frontend_skripsi/component/custom_text.dart';
import 'package:frontend_skripsi/component/custom_text_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController controllerUsername = TextEditingController();
    TextEditingController controllerPassword = TextEditingController();

    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(right: 10.0, left: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 30,
            ),
            const CustomText(
              'Log in',
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
              controller: controllerUsername,
              labelText: 'Username',
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
                onPressed: () {},
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
