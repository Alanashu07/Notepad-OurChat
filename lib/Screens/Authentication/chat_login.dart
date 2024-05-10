import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:notepad/Constants/utils.dart';
import 'package:notepad/Screens/Authentication/chat_signup.dart';
import 'package:notepad/Services/AuthServices/auth_services.dart';
import 'package:notepad/Widgets/button.dart';
import '../../Styles/app_style.dart';
import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  AuthService authService = AuthService();
  bool isSecurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void SignInUser(){
    authService.signInUser(context: context, email: _emailController.text, password: _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/iphone.png'), fit: BoxFit.fill)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 25,
                ),
                Image.asset('images/chat.png', scale: 3.5),
                const Text(
                  'OUR CHAT',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isLightTheme(context) ? Colors.white : Colors.black,
                    ),
                    height: 400,
                    width: mq.width,
                    child: Column(
                      children: [
                        Container(
                            padding: const EdgeInsets.only(top: 25),
                            child: const Text(
                              "Hello",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 35),
                            )),
                        const Text(
                          "Sign in to your Account",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)
                                ),label: const Text('E-Mail ID'),
                                hintText: 'Email ID'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 18.0, right: 18, left: 18),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: isSecurePassword,
                            decoration: InputDecoration(
                              suffixIcon: togglePassword(),
                                prefixIcon: const Icon(Icons.password),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)
                                ),label: const Text('Password'),
                                hintText: 'Password'),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(right: 18),
                          alignment: Alignment.topRight,
                          child: const Text('Forgot Password?'),
                        ),
                        CustomButton(text: 'Login', onTap: (){
                          if(_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
                            SignInUser();
                          }
                          else{
                            showSnackBar(context, 'Please Fill out fields!');
                          }
                        }, bgColor: isLightTheme(context) ? LightMode.mainColor : DarkMode.mainColor, textColor: Colors.white,)
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Don\'t have an account?',
                      style: TextStyle(color: Colors.black)),
                    GestureDetector(
                        onTap: (){
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const SignUpScreen()));
                        },
                        child: Text('   Sign Up', style: TextStyle(color: isLightTheme(context) ? LightMode.mainColor : DarkMode.mainColor))),
                  ],
                ),
                SizedBox(height: mq.height*.3,)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget togglePassword() {
    return IconButton(
        onPressed: () {
          setState(() {
            isSecurePassword = !isSecurePassword;
          });
        },
        icon: isSecurePassword
            ? Icon(
          CupertinoIcons.eye,
          color: isLightTheme(context) ? Colors.black : Colors.white,
        )
            : Icon(
          CupertinoIcons.eye_slash,
          color: isLightTheme(context) ? Colors.black : Colors.white,
        ));
  }
}
