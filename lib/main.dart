import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_test/providers/wallet_provider.dart';
import 'package:wallet_test/screens/home_page.dart';
import 'package:wallet_test/screens/intro_page.dart';
import 'package:wallet_test/screens/profile_page.dart';
import 'package:wallet_test/screens/support_page.dart';
import 'package:wallet_test/screens/transaction_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //runApp(const MyApp());
  runApp(
    /// Providers are above [MyApp] instead of inside it, so that tests
    /// can use [MyApp] while mocking the providers
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WalletProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const IntroPage(),
      /*
      routes: {
        '/HomePage': (context) => const HomePage(),
        '/TransactionPage': (context) => const TransactionPage(),
        '/ProfilePage': (context) => const ProfilePage(),
        '/SupportPage': (context) => const SupportPage(),
      },
      */
    );
  }
}
