import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:wallet_test/providers/wallet_provider.dart';
import 'package:wallet_test/screens/profile_page.dart';
import 'package:wallet_test/screens/sendtoaccount_page.dart';
import 'package:wallet_test/screens/support_page.dart';
import 'package:wallet_test/screens/transaction_page.dart';
import 'package:wallet_test/widget/asset_card.dart';

import '../widget/qr_code.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    DetailPage(),
    TransactionPage(),
    SupportPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black, // Set your desired background color
          leading: IconButton(
            icon: const Icon(
              Icons.wallet,
              color: Colors.white,
            ), // Replace with your logo icon
            onPressed: () {
              // Add logic for logo icon press
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.qr_code,
                color: Colors.white,
              ), // Replace with your QR code icon
              onPressed: () {
                // Add logic for QR code icon press
                Navigator.push(context, MaterialPageRoute(builder: (context) => QrCodeWidget()));
              },
            ),
          ],
          title: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Ethereum Goerli Network',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                SizedBox(width: 8),
                Icon(Icons.keyboard_arrow_down_sharp, color: Colors.white),
              ],
            ),
          ),
        ),
        body:  IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30), topLeft: Radius.circular(35)),
              boxShadow: [
                BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(35.0),
                topRight: Radius.circular(45.0),
              ),
              child: BottomNavigationBar(
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  selectedItemColor: Colors.purpleAccent[200],
                  unselectedItemColor: Colors.white54,
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  type: BottomNavigationBarType.fixed,
                  elevation: 0,
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(
                        IconlyBroken.wallet,
                        size: 25,
                      ),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        IconlyBroken.time_circle,
                        size: 25,
                      ),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        IconlyBroken.chat,
                        size: 25,
                      ),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        IconlyBroken.profile,
                        size: 25,
                      ),
                      label: '',
                    ),
                  ]),
            )),
    );
  }
}

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List _currency = [];

  Future<void> readJson() async {
    final String response =
    await rootBundle.loadString('assets/json/currency.json');
    final data = await json.decode(response);

    setState(() {
      _currency = data['currency'];
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<WalletProvider>(context,listen: false).getWalletBalance();
    });
    readJson();
    Future.delayed(const Duration(milliseconds: 500) * 5, () {
      if (!mounted) {
        return;
      }
    });
  }

  Widget _buildAnimatedItem(
      BuildContext context,
      int index,
      Animation<double> animation,
      ) =>
      FadeTransition(
        opacity: Tween<double>(
          begin: 0,
          end: 1,
        ).animate(animation),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.1),
            end: Offset.zero,
          ).animate(animation),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: AssetsCard(
              title: _currency[index]['name'] +
                  ' ' +
                  '(' +
                  _currency[index]["symbol"] +
                  ')',
              price: _currency[index]['symbol'],
              logo: _currency[index]['logo'],
              chart: 'chart',
              rise: '\$5,017',
              percent: '3.75%',
            ),
          ),
        ),
      );

  _viewAll({required String title}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
              color: Colors.grey[300],
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        TextButton(
            onPressed: () {},
            child: const Text(
              'See all',
              style: TextStyle(color: Colors.grey),
            ))
      ],
    );
  }

  _sendReceive(BuildContext context, {required Icon icon, required String title}) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.17,
          height: MediaQuery.of(context).size.width * 0.17,
          decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: icon,
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          title,
          style: TextStyle(color: Colors.grey[300], fontSize: 20),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 38, right: 10, left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDownBig(
              child: const Center(
                  child: Text(
                    'Current Wallet Ballance',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
              ),
          ),
          const SizedBox(
            height: 5,
          ),
          FadeInDownBig(
              child: Center(
                  child: Consumer<WalletProvider?>(
                    builder: (context, value, child){
                      if (value == null || value!.isLoding) {
                        return Container();
                      }
                      double? etherBalance = value.etherBalance?.ethBalance;
                      if (etherBalance == null) {
                        return Container(); // Handle the case where etherBalance is null
                      }
                      return Text(
                        "${etherBalance.toStringAsFixed(4)} Ether",
                        style: TextStyle(
                            color: Colors.purpleAccent[200],
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                            fontFamily: ''
                        ),
                      );
                    },
                  ),
              ),
          ),
          const SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                child: FadeInLeft(
                    child: _sendReceive(context,
                        title: 'Send',
                        icon: Icon(IconlyBroken.arrow_up,
                            size: 30, color: Colors.grey[400]))),
                onTap: () {
                  print("send ether to other account...");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SendAccountPage()));
                },
              ),
              const SizedBox(
                width: 20,
              ),
              FadeInDown(
                child: _sendReceive(
                  context,
                  title: 'Receive',
                  icon: Icon(
                    IconlyBroken.arrow_down,
                    size: 30,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              FadeInUp(
                  child: _sendReceive(context,
                      title: 'Buy',
                      icon: Icon(IconlyBroken.bag_2,
                          size: 30, color: Colors.grey[400]))),
              const SizedBox(
                width: 20,
              ),
              FadeInRight(
                  child: _sendReceive(context,
                      title: 'Swap',
                      icon: Icon(IconlyBroken.swap,
                          size: 30, color: Colors.grey[400]))),
            ],
          ),
          const SizedBox(
            height: 25,
          ),
          const Divider(
            height: 1,
            thickness: 0.5,
            color: Colors.grey,
          ),
          const SizedBox(
            height: 16,
          ),
          _viewAll(title: 'Your Assets'),
          LiveList(
            showItemInterval: const Duration(milliseconds: 300),
            showItemDuration: const Duration(seconds: 1),
            padding: const EdgeInsets.only(top: 0, bottom: 16),
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: _currency.length,
            itemBuilder: _buildAnimatedItem,
          ),

        ],
      ),
    );
  }
}

