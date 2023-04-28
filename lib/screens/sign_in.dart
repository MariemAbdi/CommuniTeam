// ignore_for_file: prefer_const_constructors, duplicate_ignore

import 'package:communiteam/screens/sign_up.dart';
import 'package:communiteam/services/Theme/custom_theme.dart';
import 'package:communiteam/utils.dart';
import 'package:communiteam/widgets/custom_button.dart';
import 'package:communiteam/widgets/email_field.dart';
import 'package:communiteam/widgets/password_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/firebase_auth_methods.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final Color purple=CustomTheme.darkPurple;
  
  Future signIn() async {
    context.read<FirebaseAuthMethods>().signInWithEmailAndPassword(email: _emailController.text.trim(), password: _passwordController.text.trim(), context: context);
  }

  void goToSignupScreen() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const SignupScreen()));
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Theme(
          data: CustomTheme.lightTheme,
          child: Scaffold(
            backgroundColor: purple,
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(20)),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.8),
                              spreadRadius: 3,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Image
                              Image.asset(
                                'assets/images/logo.png',
                                width: MediaQuery.of(context).size.width*0.3,
                              ),
                              //Title
                              FittedBox(
                                child: Text('WELCOME BACK!', style: GoogleFonts.robotoCondensed(fontSize: 40, fontWeight: FontWeight.w800, color: purple),
                                ),
                              ),
                              SizedBox(height: 20),

                              //EMAIL FIELD
                              EmailField(emailController: _emailController),

                              //SOME SPACE
                              SizedBox(height: 15),

                              //PASSWORD FIELD
                              PasswordField(passwordController: _passwordController),

                              //SOME SPACE
                              SizedBox(height: 20),

                              //SIGN IN BUTTON
                              CustomButton(text: "SIGN IN", function: (){
                                if (_formKey.currentState?.validate() ?? false) {
                                  signIn();
                                }
                              }),

                              //SOME SPACE
                              SizedBox(height: 20),

                              FittedBox(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Not A Member Yet? ',
                                      style: GoogleFonts.robotoCondensed(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: goToSignupScreen,
                                      child: Text(
                                        'Sign Up Now',
                                        style: GoogleFonts.robotoCondensed(
                                            fontSize: 16,
                                            color: CustomTheme.green,
                                            fontWeight: FontWeight.w800,
                                            decoration: TextDecoration.underline
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}