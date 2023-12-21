import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:local_auth/local_auth.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:wallet_test/screens/home_page.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {

  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _authenticateWithBiometrics();
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(() => _supportState = isSupported
          ? _SupportState.supported
          : _SupportState.unsupported),
    );
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason:
        'Scan your fingerprint (or face or whatever) to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }

    final String message = authenticated ? 'Authorized' : 'Not Authorized';
    setState(() {
      _authorized = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 64, right: 16),
            child: Column(children: [
              FadeInDown(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/logo.png'), // NFT_4
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 70,
              ),
              FadeInLeft(
                  child: Text(
                'Blockchain-Powered Privacy on the Move',
                style: TextStyle(
                    color: Colors.purpleAccent[200],
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    fontFamily: ''),
              )),
              const SizedBox(
                height: 20,
              ),
              FadeInLeft(
                child: const Text(
                'Tectone23 is a project built for the security, trust and stability of mobile life using blockchain technology.',
                style: TextStyle(color: Colors.grey, fontSize: 20),
              )),
              const SizedBox(
                height: 100,
              ),
            ]),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Builder(
              builder: (context) {
                final GlobalKey<SlideActionState> key = GlobalKey();
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SlideAction(
                    sliderRotate: false,
                    outerColor: Colors.grey[900],
                    innerColor: Colors.purpleAccent[200],
                    key: key,
                    sliderButtonIcon: const Icon(IconlyBroken.arrow_right), // Icons.fingerprint / IconlyBroken.arrow_right
                    onSubmit: () {
                      Future.delayed(
                        const Duration(seconds: 1),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomePage()),// HomePage()
                          );
                        },
                      );
                    },
                    child: FadeInRight(
                        child: const Text(
                      'Swipe to get started',
                      style: TextStyle(color: Colors.white, fontSize: 17),
                    )),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}
