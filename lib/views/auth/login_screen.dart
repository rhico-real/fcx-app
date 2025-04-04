import 'package:fcx_app/remote_db/auth_repository.dart';
import 'package:fcx_app/views/auth/register_screen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  ValueNotifier<bool> isLoading = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff17141f),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'FcX Fiber',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                ),
              ),
              SizedBox(height: 30),
              TextField(
                controller: _emailController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.email, color: Colors.white),
                  contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.password, color: Colors.white),
                  contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
              SizedBox(height: 20),
              _buildLoginButton(),
              SizedBox(height: 50),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No account yet?',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(width: 5),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                        ),
                      );
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        'Register Here',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ValueListenableBuilder<bool> _buildLoginButton() {
    return ValueListenableBuilder(
      valueListenable: isLoading,
      builder: (context, val, child) {
        if (isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return InkWell(
          onTap: () async {
            Map<String, dynamic> payload = {
              'email': _emailController.text,
              'password': _passwordController.text,
            };

            isLoading.value = true;
            var response = await AuthRepository().httpLogin(payload);

            if (response.statusCode == 200) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Login successful!')));
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(response.body)));
            }
            isLoading.value = false;
          },
          borderRadius: BorderRadius.circular(5),
          child: Material(
            color: Colors.orange.shade400,
            borderRadius: BorderRadius.circular(5),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Text(
                    'Login',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
