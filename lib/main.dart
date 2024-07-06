import 'package:billbitzfinal/presentation/widgets/bottom_navbar.dart';
import 'package:billbitzfinal/domain/models/category_model.dart';
import 'package:billbitzfinal/domain/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import 'domain/models/userdata_model.dart';
import 'presentation/screens/signup.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  try {
    Hive.registerAdapter(UserModelAdapter());
    print("UserModelAdapter registered");

    Hive.registerAdapter(TransactionAdapter());
    print("TransactionAdapter registered");

    Hive.registerAdapter(CategoryModelAdapter());
    print("CategoryModelAdapter registered");

    await Hive.openBox<UserModel>('users');
    print("Users box opened");

    await Hive.openBox<Transaction>('transactions');
    print("Transactions box opened");

    await Hive.openBox<CategoryModel>('categories');
    print("Categories box opened");

     runApp(const MyApp());
  } catch (e) {
    print("Error registering adapters or opening boxes: $e");
  }
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignupPage(),
    );
  }
}
