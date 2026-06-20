import 'package:flutter/material.dart';

/// A demo persona used to sign in. Drives whether the wallet starts active.
class Account {
  const Account({
    required this.name,
    required this.role,
    required this.email,
    required this.investor,
    this.phone = '',
  });

  final String name;
  final String role;
  final String email;
  final bool investor;
  final String phone;

  String get initials {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}

const kNormalAccount = Account(
  name: 'Dara Sok',
  role: 'Home buyer',
  email: 'dara.sok@gmail.com',
  investor: false,
);

const kInvestorAccount = Account(
  name: 'Sophea Lim',
  role: 'Investor Club member',
  email: 'sophea.lim@gmail.com',
  investor: true,
);

const mockAccounts = [kNormalAccount, kInvestorAccount];

/// Current signed-in persona — null means "guest" (playing without an account).
class Session extends ChangeNotifier {
  Account? _current;

  Account? get current => _current;
  bool get isGuest => _current == null;

  void signIn(Account a) {
    _current = a;
    notifyListeners();
  }

  void signOut() {
    _current = null;
    notifyListeners();
  }
}

final session = Session();
