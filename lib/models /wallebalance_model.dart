import 'dart:math';

class WalletBalance {
  final double ethBalance;

  WalletBalance({
    required this.ethBalance,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      ethBalance: json['ethBalance'],
    );
  }

  double get roundedEthBalance => _roundToDecimalPlaces(ethBalance, 4);

  double _roundToDecimalPlaces(double value, int decimalPlaces) {
    if (value.isNaN) {
      return value;
    }
    final multiplier = pow(10, decimalPlaces);
    return (value * multiplier).round() / multiplier;
  }
}
