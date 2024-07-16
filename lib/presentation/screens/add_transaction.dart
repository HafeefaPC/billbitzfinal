import 'package:billbitzfinal/presentation/screens/payment.dart';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hive/hive.dart';
import 'package:billbitzfinal/data/utilty.dart';
import 'package:billbitzfinal/domain/models/category_model.dart';
import 'package:billbitzfinal/domain/models/transaction_model.dart';
import 'package:billbitzfinal/Constants/default_categories.dart';
import 'package:billbitzfinal/Constants/limits.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'camera.dart'; // Update the import if the location of your CameraScreen has changed

class AddScreen extends StatefulWidget {
  final String extractedText; // Parameter to receive extracted text

  const AddScreen({Key? key, required this.extractedText}) : super(key: key);

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  List<CategoryModel> incomeCategories = defaultIncomeCategories;
  List<CategoryModel> expenseCategories = defaultExpenseCategories;

  final boxTransaction = Hive.box<Transaction>('transactions');
  DateTime date = DateTime.now();
  CategoryModel? selectedCategoryItem;
  String? selectedTypeItem;

  late Box<CategoryModel> box;
  List<CategoryModel> categories = [];

  final List<String> types = ['Income', 'Expense'];
  final TextEditingController explainC = TextEditingController();
  FocusNode explainFocus = FocusNode();
  final TextEditingController amountC = TextEditingController();
  FocusNode amountFocus = FocusNode();

  bool isAmountValid = true;
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _wordSpoken = '';
  double _confidenceLevel = 0.0;

  @override
  void initState() {
    super.initState();
    explainFocus.addListener(() {
      setState(() {});
    });
    amountFocus.addListener(() {
      setState(() {});
    });
    openBox().then((_) {
      fetchCategories();

      List<String> parts = widget.extractedText.split(',');

      if (parts.length >= 3) {
        selectedTypeItem = 'Expense'; // Assuming type is 'Expense'
        explainC.text = parts[1].trim(); // Assuming notes is the second part
       String amountText = parts[2].trim();
    if (amountText.isNotEmpty) {
      amountText = amountText.substring(0, amountText.length - 1);
      }

amountC.text = amountText;// Assuming amount is the third part

     String categoryTitle = parts[0].trim();

  categoryTitle = categoryTitle.substring(1, categoryTitle.length );
 print('Category Title: $categoryTitle');

categoryTitle = categoryTitle.toLowerCase();

switch (categoryTitle) {
  case 'food':
    selectedCategoryItem = expenseCategories[0];
    break;
  case 'transportation':
    selectedCategoryItem = expenseCategories[1];
    break;
  case 'education':
    selectedCategoryItem = expenseCategories[2];
    break;
  case 'bills':
    selectedCategoryItem = expenseCategories[3];
    break;
  case 'travels':
    selectedCategoryItem = expenseCategories[4];
    break;
  case 'pets':
    selectedCategoryItem = expenseCategories[5];
    break;
  case 'tax':
    selectedCategoryItem = expenseCategories[6];
    break;
  default:
    selectedCategoryItem = expenseCategories[7]; // Default category if not found
    break;
}
      }
    });

    initSpeech();
  }

  Future<void> initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onStatus: (status) => print('onStatus: $status'),
        onError: (errorNotification) => print('onError: $errorNotification'),
      );
    } catch (e) {
      print("Error initializing SpeechToText: $e");
    }
    setState(() {});
  }

  Future<void> _startListening() async {
    if (_speechEnabled) {
      try {
        await _speechToText.listen(onResult: _onSpeechResult);
        setState(() {
          _confidenceLevel = 0.0;
        });
      } catch (e) {
        print("Error starting to listen: $e");
      }
    }
  }

  Future<void> _stopListening() async {
    try {
      await _speechToText.stop();
      if (_wordSpoken.isNotEmpty) {
        await _processSpokenText(_wordSpoken);
      }
    } catch (e) {
      print("Error stopping listening: $e");
    }
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _wordSpoken = result.recognizedWords;
      print('Word Spoken: $_wordSpoken');
      _confidenceLevel = result.confidence;
    });
  }

  Future<void> _processSpokenText(String text) async {
    try {
      final String apiKey =
          'AIzaSyDHmh4P92aN9GGSug0cwwZrp2WnfWJ3RzM'; // Replace with your actual API key
      final model = GenerativeModel(
          model: 'models/gemini-1.5-pro-latest', apiKey: apiKey);

      final prompt = TextPart(
          "Provide output as a three-word array with comma separation containing category, a small note, and amount of rupees . Use these select the from thse categories: Food, Transportation, Education, Bills, Travels, Pets, Tax, Others Expense. Format: [category, note, amount]. For example, [food, dinner, 100].");

      final textPart = TextPart(text);

      final response = await model.generateContent([
        Content.multi([prompt, textPart])
      ]);

      // Assuming the response is a single text string
      final extractedText = response.text;

      // Extract the array from the response
      final startIndex = extractedText?.indexOf('[');
      final endIndex = extractedText!.indexOf(']') + 1;

      if (startIndex != -1 && endIndex != -1) {
        final arrayString = extractedText.substring(startIndex!, endIndex);
        final extractedData = arrayString
            .replaceAll('[', '')
            .replaceAll(']', '')
            .split(',')
            .map((e) => e.trim())
            .toList();

        // Print the extracted data
        print('Extracted Data: $extractedData');

        // Update the UI with the extracted data
        setState(() {
          _wordSpoken = extractedData.join(', ');
        });

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddScreen(
              extractedText: extractedText,
            ),
          ),
        );
      } else {
        print('Error: Unable to extract data');
      }
    } catch (e) {
      print('Error processing spoken text: $e');
    }
  }

  Future<void> openBox() async {
    box = await Hive.openBox<CategoryModel>('categories');
  }

  Future<void> fetchCategories() async {
    categories = box.values.toList();
    setState(() {
      incomeCategories = [
        ...defaultIncomeCategories,
        ...box.values.where((category) => category.type == 'Income').toList(),
      ];
      expenseCategories = [
        ...defaultExpenseCategories,
        ...box.values.where((category) => category.type == 'Expense').toList(),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            backgroundAddContainer(context),
            Positioned(
              top: 120,
              child: mainAddContainer(),
            )
          ],
        ),
      ),
    );
  }

  Container mainAddContainer() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), color: Colors.white),
      height: 680,
      width: 360,
      child: Column(children: [
        const SizedBox(height: 35),
        typeField(),
        const SizedBox(height: 35),
        noteField(),
        const SizedBox(height: 35),
        amountField(),
        const SizedBox(height: 35),
        categoryField(),
        const SizedBox(height: 35),
        timeField(),
        const SizedBox(height: 35),
        addTransaction(),
        const SizedBox(height: 20)
      ]),
    );
  }

  GestureDetector addTransaction() {
    bool isWarningShown = false;
    return GestureDetector(
      onTap: () {
        if (selectedCategoryItem == null ||
            selectedTypeItem == null ||
            explainC.text.isEmpty ||
            amountC.text.isEmpty) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: const Text('Please fill in all the fields.'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
          return;
        }

        double amount = double.tryParse(amountC.text) ?? 0.0;
        if (selectedTypeItem == 'Expense' &&
            amount > limitPerExpense &&
            !isWarningShown) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Warning'),
              content: Text(
                  'The amount exceeds the spending limit(${formatCurrency(limitPerExpense)}).'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
          isWarningShown = true;
          return;
        }
        var newTransaction = Transaction(selectedTypeItem!, amountC.text, date,
            explainC.text, selectedCategoryItem!);
        boxTransaction.add(newTransaction);
        Navigator.of(context).pop();

        if (selectedTypeItem == 'Expense' && totalBalance() < limitTotal) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Warning'),
              content: Text(
                  'Total balance is less than ${formatCurrency(limitTotal)}!'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
          return;
        }
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color(0xFF0D47A1)),
        height: 50,
        width: 140,
        child: const Text(
          'Add',
          style: TextStyle(
              fontFamily: 'f',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white),
        ),
      ),
    );
  }

  Padding timeField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        alignment: Alignment.bottomLeft,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 2, color: const Color(0xFF0D47A1))),
        width: double.infinity,
        child: TextButton(
          onPressed: () async {
            DateTime? newDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020, 1, 1),
              lastDate: DateTime(2030),
            );
            if (newDate == null) return;
            setState(() {
              date = newDate;
            });
          },
          child: Text(
            'Date : ${date.day}/${date.month}/${date.year}',
            style: const TextStyle(fontSize: 15, color: Colors.black),
          ),
        ),
      ),
    );
  }

  Padding amountField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        keyboardType: TextInputType.number,
        focusNode: amountFocus,
        controller: amountC,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          labelText: 'Amount',
          labelStyle: TextStyle(fontSize: 17, color: Colors.grey.shade800),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(width: 2, color: Color(0xFF0D47A1))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(width: 2, color: Color(0xFF0D47A1))),
          errorText: isAmountValid ? null : 'Amount must be greater than 0',
        ),
        onChanged: (value) {
          setState(() {
            if (value.isEmpty) {
              isAmountValid = true;
            } else {
              isAmountValid =
                  double.tryParse(value) != null && double.parse(value) > 0;
            }
          });
        },
      ),
    );
  }

  Padding typeField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              width: 2,
              color: const Color(0xFF0D47A1),
            )),
        child: DropdownButton<String>(
          value: selectedTypeItem,
          items: types
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Row(children: [
                      SizedBox(
                        width: 40,
                        child: Image.asset('images/$e.png'),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        e,
                        style: const TextStyle(fontSize: 15),
                      )
                    ]),
                  ))
              .toList(),
          selectedItemBuilder: (BuildContext context) => types
              .map((e) => Row(
                    children: [
                      SizedBox(
                        width: 42,
                        child: Image.asset('images/$e.png'),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(e)
                    ],
                  ))
              .toList(),
          hint: const Text(
            'Select Type',
            style: TextStyle(color: Colors.grey),
          ),
          dropdownColor: Colors.white,
          isExpanded: true,
          underline: Container(),
          onChanged: ((value) {
            setState(() {
              selectedTypeItem = value!;
              selectedCategoryItem = null;
            });
          }),
        ),
      ),
    );
  }

  Padding noteField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        focusNode: explainFocus,
        controller: explainC,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          labelText: 'Notes',
          labelStyle: TextStyle(fontSize: 17, color: Colors.grey.shade800),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(width: 2, color: Color(0xFF0D47A1))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(width: 2, color: Color(0xFF0D47A1))),
        ),
      ),
    );
  }

  Padding categoryField() {
    final List<CategoryModel> currCategories =
        selectedTypeItem == 'Income' ? incomeCategories : expenseCategories;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 2,
            color: const Color(0xFF0D47A1),
          ),
        ),
        child: DropdownButton<CategoryModel>(
          value: selectedCategoryItem,
          items: currCategories
              .map(
                (e) => DropdownMenuItem<CategoryModel>(
                  value: e,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Image.asset('images/${e.categoryImage}'),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        e.title,
                        style: const TextStyle(fontSize: 15),
                      )
                    ],
                  ),
                ),
              )
              .toList(),
          selectedItemBuilder: (BuildContext context) => currCategories
              .map(
                (e) => Row(
                  children: [
                    SizedBox(
                      width: 42,
                      child: Image.asset('images/${e.categoryImage}'),
                    ),
                    const SizedBox(width: 5),
                    Text(e.title),
                  ],
                ),
              )
              .toList(),
          hint: const Text(
            'Select category',
            style: TextStyle(color: Colors.grey),
          ),
          dropdownColor: Colors.white,
          isExpanded: true,
          underline: Container(),
          onChanged: (value) {
            setState(() {
              selectedCategoryItem = value;
            });
          },
        ),
      ),
    );
  }

  Column backgroundAddContainer(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 240,
          decoration: const BoxDecoration(
              color: Color(0xFF0D47A1),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20))),
          child: Column(children: [
            const SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    "Add Transaction",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CameraScreen(),
                        ),
                      );
                    },
                    child: const Icon(
                      IconData(0xe4b6, fontFamily: 'MaterialIcons'),
                      color: Colors.white,
                    ),
                  ),
                 GestureDetector(
  onTap: () {
    if (_speechToText.isListening) {
      _stopListening(); // Call stop method if already listening
    } else {
      _startListening(); // Call start method if not listening
    }
  },
  child: Icon(
    _speechToText.isListening ? Icons.stop : Icons.mic,
    color: _speechToText.isListening ? Colors.red : Colors.white,
  ),
),

                  // Add Pay button here
                  GestureDetector(
                    onTap: () {
                      // Implement pay functionality
                      // For example:
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Pay'),
                          content:
                              const Text('Payment functionality goes here.'),
                          actions: [
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => Scanner(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.payment,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          ]),
        )
      ],
    );
  }
}
