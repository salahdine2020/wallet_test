import 'package:flutter/foundation.dart';
import 'package:wallet_test/models%20/transaction_model.dart';
import 'package:wallet_test/services/get_informations.dart';
import '../models /trans_model.dart';
import '../models /wallebalance_model.dart';

abstract class WalletServices {
  Future getWalletBalance();
  Future getWalletTransaction();
}

class WalletProvider extends ChangeNotifier implements WalletServices {
  final services = ProviderService();
  bool isLoding = false;
  WalletBalance? etherBalance;
  List<TransactionModel?>? transactions;

  @override
  getWalletBalance() async {
    isLoding = true;
    notifyListeners();
    WalletBalance? res = await services.loadWalletData();
    //print("res from provider class is : $res");
    etherBalance = res;
    isLoding = false;
    notifyListeners();
  }

  @override
  getWalletTransaction() async {
    isLoding = true;
    notifyListeners();
    List<TransactionModel?>? res = await services.fetchTransactionHistory();
    //print("res from provider class is : ${res}");
    transactions = res;
    isLoding = false;
    notifyListeners();
  }

}