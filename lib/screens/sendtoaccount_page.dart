import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:wallet_test/constants.dart';
import 'package:web3dart/web3dart.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/wallet_provider.dart';
import '../widget/qr_code.dart';

class SendAccountPage extends StatefulWidget {
  const SendAccountPage({Key? key}) : super(key: key);

  @override
  State<SendAccountPage> createState() => _SendAccountPageState();
}

class _SendAccountPageState extends State<SendAccountPage> {
  final TextEditingController recipientController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isAlphanumeric(String value) {
    // Use a regular expression to check if the string contains only letters and numbers
    RegExp regex = RegExp(r'^[a-zA-Z0-9]+$');
    return regex.hasMatch(value);
  }

  Future<String> sendTransaction(String receiver, EtherAmount txValue) async {
    // wss://holy-ancient-field.ethereum-goerli.quiknode.pro/f8b5ee7ceb9b77678da8143bd63e64f12c24b9a3/
    //var apiUrl = "https://holy-ancient-field.ethereum-goerli.quiknode.pro/f8b5ee7ceb9b77678da8143bd63e64f12c24b9a3/"; // Replace with your API
    // Replace with your API
    var httpClient = http.Client();
    var ethClient = Web3Client(apiUrl, httpClient);

    EthPrivateKey credentials = EthPrivateKey.fromHex('0x' + privateKey);

    EtherAmount etherAmount = await ethClient.getBalance(credentials.address);
    print("etherAmount is : $etherAmount");
    print("etherAmount value units : ");
    print(etherAmount.getValueInUnit(EtherUnit.ether));
    EtherAmount gasPrice = await ethClient.getGasPrice();
    print("gasPrice is : $gasPrice");

    String rawtransaction = await ethClient.sendTransaction(
      credentials,
      Transaction(
        to: EthereumAddress.fromHex(receiver),
        gasPrice: gasPrice,
        maxGas: 100000,
        value: txValue,
      ),
      chainId: 5,
    );

    return rawtransaction;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<WalletProvider>(context, listen: false)
          .getWalletTransaction();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: Container(),
        actions: [
          IconButton(
            icon: const Text(
              'Cancel',
              style: TextStyle(fontSize: 18, color: Colors.blue),
            ),
            onPressed: () {
              // Add logic for QR code icon press
              Navigator.pop(context);
            },
          ),
        ],
        title: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Text(
                    'Send To',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  Row(
                    children: const [
                      Icon(
                        Icons.do_not_disturb_on_total_silence_outlined,
                        color: Colors.green,
                        size: 10,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Ethereum Main Network',
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(width: 8),
              Icon(Icons.keyboard_arrow_down_sharp, color: Colors.white),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 38, right: 20, left: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // From Field
              TextFormField(
                readOnly: true,
                style: const TextStyle(color: Colors.white), // Set text colorT
                decoration: InputDecoration(
                  labelText: 'From :',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  // You can customize other properties like fillColor, filled, etc.
                ),
                // You may want to dynamically set the initial value based on the user's account
                initialValue: '0x1e0372d4D2BB295aB9D851A5cbB2063D2d4ef17E',
              ),
              const SizedBox(height: 20),
              // To Field with QR Code Scanner
              TextFormField(
                controller: amountController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the amount';
                  } else if (double.tryParse(value) == null) {
                    return 'Invalid amount. Enter a valid number';
                  }
                  return null;
                },
                style: const TextStyle(color: Colors.white), // Set text colorT
                decoration: InputDecoration(
                  labelText: 'Amount:',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  // You can customize other properties like fillColor, filled, etc.
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: recipientController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your wallet address (ex: 0xF234...) ';
                  } else if (value.length != 42 ||
                      !value.startsWith('0x') ||
                      !isAlphanumeric(value)) {
                    return 'Invalid wallet address';
                  }
                  return null;
                },
                style: const TextStyle(color: Colors.white), // Set text color
                decoration: InputDecoration(
                  labelText: 'To :',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => QrCodeWidget()));
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  // You can customize other properties like fillColor, filled, etc.
                ),
              ),

              // Add any additional widgets or form elements as needed
              const SizedBox(height: 12),
              const Divider(height: 20),
              const SizedBox(height: 12),
              // "Your Accounts" Section
              const Text(
                'Your Accounts',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              // List of Accounts
              Consumer<WalletProvider?>(builder: (context, value, child) {
                if (value == null || value!.isLoding!) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.purpleAccent,
                    ),
                  );
                }
                return Column(
                  children: [
                    _buildAccountItem(
                        'Transaction 1',
                        value!.transactions![0]!.transactionHash
                    ),
                    _buildAccountItem(
                        'Transaction 2',
                        value!.transactions![1]!.transactionHash
                    ),
                    _buildAccountItem(
                        'Transaction 3',
                        value!.transactions![2]!.transactionHash
                    ),
                  ],
                );
              }),
              /*
              _buildAccountItem('Transaction 1',
                  '0x1e0372d4D2BB295aB9D851A5cbB2063D2d4ef17E'),
              const SizedBox(
                height: 16,
              ),
              _buildAccountItem('Transaction 2',
                  '0x1e0372d4D2BB295aB9D851A5cbB2063D2d4ef17E'),


              const SizedBox(
                height: 16,
              ),
              _buildAccountItem('Transaction 3',
                  '0x1e0372d4D2BB295aB9D851A5cbB2063D2d4ef17E'),
              */
              SizedBox(
                height: MediaQuery.of(context).size.height * .18,
              ),
              // Add any additional widgets or form elements as needed
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        String recipient = recipientController.text;
                        double amount = double.parse(amountController.text);
                        BigInt bigIntValue = BigInt.from(amount * pow(10, 18));
                        print(bigIntValue);
                        EtherAmount ethAmount =
                            EtherAmount.fromBigInt(EtherUnit.wei, bigIntValue);
                        print(ethAmount);
                        // Convert the amount to EtherAmount
                        String rawtrans =
                            await sendTransaction(recipient, ethAmount);
                        print("rawtrans : $rawtrans");
                        print('recipent: $recipient, Amount: $amount');

                        // TODO: Show an alert dialog if rawtrans is not empty and not null
                        if (rawtrans != null && rawtrans.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  'Transaction Successful',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                content: RichText(
                                  text: TextSpan(
                                    text:
                                        'Your transaction hash is : $rawtrans and it was successful! View it on ',
                                    style: TextStyle(
                                      color: Colors.black,
                                      decoration: TextDecoration.underline,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      /*
                                      TextSpan(
                                        text: 'Etherscan',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                          fontSize: 14,
                                        ),
                                        recognizer: TapGestureRecognizer()..onTap = () async {
                                            // TODO: Implement navigation to the Etherscan link
                                            String url_string = "https://goerli.etherscan.io/tx/$rawtrans";
                                            print("url_string : $url_string" );
                                            final Uri _url = Uri.parse(url_string);
                                            await launchUrl(_url);
                                          },
                                      ),
                                      */
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      // TODO: Implement resend logic if needed
                                      Navigator.pop(
                                          context); // Close the dialog
                                    },
                                    child: Text('Resend'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // TODO: Implement navigation logic or go back
                                      Navigator.pop(
                                          context); // Close the dialog
                                      // delet all textcontroller
                                      Navigator.pop(
                                          context); // Navigate back (assuming this is the second screen)
                                      // Clear text from controllers
                                      recipientController.clear();
                                      amountController.clear();
                                    },
                                    child: Text('Go Back'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.purpleAccent, // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Next',
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildAccountItem(String title, String subtitle) {
  return ListTile(
    title: Text(
      title,
      style: const TextStyle(fontSize: 18, color: Colors.white),
    ),
    subtitle: Text(
      subtitle,
      overflow: TextOverflow.ellipsis,
      maxLines: 1, // Set the maximum number of lines
      style: const TextStyle(fontSize: 14, color: Colors.grey),
    ),
    leading: Container(
      width: 48,
      height: 48,
      child: const Center(
        child: Icon(
          Icons.swap_horiz_outlined,
          color: Colors.white, // Icon color
        ),
      ),
    ),
  );
}
