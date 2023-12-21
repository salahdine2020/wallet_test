import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'package:web3dart/web3dart.dart';

import '../models /transaction_model.dart';
import '../models /wallebalance_model.dart';

class ProviderService {

  Future<WalletBalance?> loadWalletData() async {
    try {
      if (privateKey != null) {
        var httpClient = http.Client();
        var ethClient = Web3Client(apiUrl, httpClient);
        EthPrivateKey credentials = EthPrivateKey.fromHex('0x' + privateKey);
        EtherAmount etherAmount = await ethClient.getBalance(credentials.address);
        final etherIntValue = etherAmount.getValueInUnit(EtherUnit.ether);
        print("etherAmount is : $etherAmount");
        print("etherAmount value units : ");
        print(etherIntValue);
        // Create and return an instance of WalletData
        return WalletBalance(ethBalance: etherIntValue);
      }
    } catch (e) {
      print("Error loading wallet data: $e");
      // Handle the error or return a default value as needed
      return null;
    }
  }

  Future<List<TransactionModel?>?> fetchTransactionHistory() async {
    try {
      final apiUrl = 'https://api-goerli.etherscan.io/api?module=account&action=txlist&address=$walletAddress&sort=desc&apikey=$etherscanApiKey';
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<TransactionModel> transactions = (jsonResponse['result'] as List).map((transaction) => TransactionModel.fromJson(transaction)).toList();
        return transactions;
      } else {
        throw Exception('Failed to load transaction history');
      }
    } catch (error) {
      print('Error: $error');
      throw Exception('Internal Server Error');
    }
  }

}