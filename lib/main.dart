import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:communiteam/firebase_options.dart';
import 'package:communiteam/providers/firebase_auth_methods.dart';
import 'package:communiteam/screens/addNewTeam.dart';
import 'package:communiteam/screens/auth.dart';
import 'package:communiteam/screens/homepage.dart';
import 'package:communiteam/screens/profile.dart';
import 'package:communiteam/screens/settings.dart';
import 'package:communiteam/services/Theme/custom_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'screens/sign_in.dart';
import 'screens/sign_up.dart';

Future<void> main() async{
  //USED FOR THE BINDING TO BE INITIALIZED BEFORE CALLING runApp.
  WidgetsFlutterBinding.ensureInitialized();

  //SET THE ORIENTATION TO BE PORTRAIT ONLY
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown]);

  //MAKE THE APP FULL SCREEN => HIDES THE STATUS AND NAVIGATION BAR OF THE PHONE
// SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky, overlays: []);

  //INITIALIZE THE LOCALIZATION
  await EasyLocalization.ensureInitialized();

  //INITIALIZE FIREBASE
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //RUN THE APP
  runApp(
      EasyLocalization(
      supportedLocales: const [Locale('ar'),Locale('en'),Locale('fr')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
    Provider<FirebaseAuthMethods>(create: (_)=>FirebaseAuthMethods(FirebaseAuth.instance),),

    StreamProvider(
    create: (context)=>context.read<FirebaseAuthMethods>().authState, initialData: null),

    ],
    child: GetMaterialApp(
      debugShowCheckedModeBanner: false,
      //APP THEME CONFIGURATION
      theme: CustomTheme.lightTheme,
      darkTheme: CustomTheme.darkTheme,
      themeMode: ThemeMode.system,//ThemeService().theme,
      //LOCALIZATION CONFIGURATION
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      //FIRST SCREEN
      home: const Auth(),
      routes: {
        HomePage.routeName: (context) => HomePage(isCanal:true,title: "Channel Name",widget: Container()),
        LoginScreen.routeName: (context) => const LoginScreen(),
        SignupScreen.routeName: (context) => const SignupScreen(),
        SettingsScreen.routeName: (context) => const SettingsScreen(),
        ProfileScreen.routeName: (context) => const ProfileScreen(),
        AddNewTeamScreen.routeName:(context)=>const AddNewTeamScreen(),
      },
    )
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedSplashScreen(
          backgroundColor: CustomTheme.darkPurple,
          splashIconSize: MediaQuery.of(context).size.width*0.5,
          splash: "assets/images/logo_circle.png",
          nextScreen: const Auth(),
          duration: 3000,
          splashTransition: SplashTransition.scaleTransition,
        ),
      ),
    );
  }
}