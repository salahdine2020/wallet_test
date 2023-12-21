
import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_test/models%20/trans_model.dart';

import '../models /transaction_model.dart';
import '../providers/wallet_provider.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<WalletProvider>(context, listen: false)
          .getWalletTransaction();
    });
  }

  // Example data for demonstration
  final List<TransactionModelDummy> transactions = List.generate(
    20,
    (index) => TransactionModelDummy(
      id: 'Transaction ID $index',
      date: '2023-01-${index + 1}',
      senderReceiver: 'Sender $index / Receiver $index',
      amount: '${(index + 1) * 10}.00',
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<WalletProvider?>(
       builder: (context, value, child) {
        if (value == null || value!.isLoding!) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.purpleAccent,
            ),
          );
        }
        return LiveList(
            showItemInterval: const Duration(milliseconds: 300),
            showItemDuration: const Duration(seconds: 1),
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: value?.transactions?.length ?? 100,
            itemBuilder: (BuildContext? context, int index, Animation<double> animation) {
              if (value == null || value!.isLoding) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.purpleAccent,
                  ),
                );
              }
              double? valueEther = int.parse(value?.transactions?[index]?.value ?? "0") / 1000000000000000000;
              String? timestringformat = value?.transactions?[index]?.timestamp;
              DateTime dateTrans = DateTime.fromMillisecondsSinceEpoch(int.parse(timestringformat ?? "0"), isUtc: true);
              // Extract time components
              int hour = dateTrans.hour;
              int minute = dateTrans.minute;
              int second = dateTrans.second;
              return FadeTransition(
                opacity: Tween<double>(
                  begin: 0,
                  end: 1,
                ).animate(animation),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: Container(
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(1),
                          spreadRadius: 2,
                          blurRadius: 2,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ExpansionTile(
                      title: Text(
                        'Tx $index : ${value?.transactions?[index]?.transactionHash}',
                        //overflow: TextOverflow.ellipsis,
                        //maxLines: 2, // Set the maximum number of lines
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      children: [
                        ListTile(
                          subtitle: Text(
                              'Date:  $hour:$minute:$second'
                          ),
                        ),
                        ListTile(
                          subtitle: Text(
                              'Sender : ${value?.transactions?[index]?.from}',
                          ),
                        ),
                        ListTile(
                          subtitle: Text(
                              'Receiver: ${value?.transactions?[index]?.to}'),
                        ),
                        ListTile(
                          subtitle: Text('Amount: $valueEther Ether'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            //_buildAnimatedItem,
            );
      },
      ),
    );
  }
}
