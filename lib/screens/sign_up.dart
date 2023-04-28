import 'package:communiteam/screens/sign_in.dart';
import 'package:communiteam/widgets/nickname_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/firebase_auth_methods.dart';
import '../services/Theme/custom_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/email_field.dart';
import '../widgets/password_field.dart';

class SignupScreen extends StatefulWidget {
  static String routeName = '/signup';
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final Color purple=CustomTheme.darkPurple;

  Future signUp() async {
    context.read<FirebaseAuthMethods>().signUpWithEmailAndPassword(nickname: _nicknameController.text.trim(), email: _emailController.text.trim(), password: _passwordController.text.trim(), context: context).whenComplete(()
    {
      context.read<FirebaseAuthMethods>().signInWithEmailAndPassword(email: _emailController.text.trim(), password: _passwordController.text.trim(), context: context);
    });
  }

  void goToSignupScreen() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const LoginScreen()));
  }

  @override
  void dispose() {
    super.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
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
                            child: Text('JOIN US', style: GoogleFonts.robotoCondensed(fontSize: 40, fontWeight: FontWeight.w800, color: purple),
                            ),
                          ),

                          //SOME SPACE
                          const SizedBox(height: 20),

                          //USERNAME FIELD
                          NicknameField(nicknameController: _nicknameController),

                          //SOME SPACE
                          const SizedBox(height: 15),

                          //EMAIL FIELD
                          EmailField(emailController: _emailController),

                          //SOME SPACE
                          const SizedBox(height: 15),

                          //PASSWORD FIELD
                          PasswordField(passwordController: _passwordController),

                          //SOME SPACE
                          const SizedBox(height: 20),

                          //SIGN IN BUTTON
                          CustomButton(text: "SIGN UP", function: (){
                            if (_formKey.currentState?.validate() ?? false) {
                              signUp();
                            }
                          }),

                          //SOME SPACE
                          const SizedBox(height: 20),

                          FittedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already A Member? ',
                                  style: GoogleFonts.robotoCondensed(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                InkWell(
                                  onTap: goToSignupScreen,
                                  child: Text(
                                    'Sign In Now',
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
    );
  }
}