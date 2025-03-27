import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe; // Add alias
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String? _selectedPaymentMethod = 'Apple Pay'; // Default selected payment method

  List<Map<String, String>> _cards = [
    {
      'type': 'Visa',
      'ending': '1234',
      'expiry': '06/2024',
      'logo': 'https://upload.wikimedia.org/wikipedia/commons/4/41/Visa_Logo.png',
    },
    {
      'type': 'Mastercard',
      'ending': '5678',
      'expiry': '08/2025',
      'logo': 'https://cdn-icons-png.flaticon.com/512/11378/11378185.png',
    },
  ];

  void _setDefaultPaymentMethod(String method) {
    setState(() {
      _selectedPaymentMethod = method;
    });
  }

  Future<void> _addNewCard(String cardNumber, String expiryDate,
      String cvv) async {
    try {
      // Create a payment method with Stripe
      final paymentMethod = await stripe.Stripe.instance.createPaymentMethod(
        params: stripe.PaymentMethodParams.card(
          paymentMethodData: stripe.PaymentMethodData(
            billingDetails: const stripe.BillingDetails(
              name: 'Ashwini',
              email: 'ashwini@example.com',
            ),
          ),
        ),
      );

      if (paymentMethod.id.isNotEmpty) {
        final newCard = {
          'type': 'Card',
          'ending': cardNumber.substring(cardNumber.length - 4),
          'expiry': expiryDate,
          'logo': 'https://cdn-icons-png.flaticon.com/512/189/189682.png',
        };

        setState(() {
          _cards.add(newCard);
          _setDefaultPaymentMethod(
              'Card ending in ${cardNumber.substring(cardNumber.length - 4)}');
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card added successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding card: $e')),
      );
    }
  }

  Future<void> _showAddCardModal() async {
    final TextEditingController cardNumberController = TextEditingController();
    final TextEditingController expiryDateController = TextEditingController();
    final TextEditingController cvvController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery
                .of(context)
                .viewInsets
                .bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Enter Card Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Card Number Field
                  TextField(
                    controller: cardNumberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Card Number",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Expiry Date Field
                  TextField(
                    controller: expiryDateController,
                    keyboardType: TextInputType.datetime,
                    decoration: const InputDecoration(
                      labelText: "Expiry Date (MM/YY)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // CVV Field
                  TextField(
                    controller: cvvController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "CVV",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      if (cardNumberController.text.isNotEmpty &&
                          expiryDateController.text.isNotEmpty &&
                          cvvController.text.isNotEmpty) {
                        Navigator.pop(context);
                        _addNewCard(
                          cardNumberController.text,
                          expiryDateController.text,
                          cvvController.text,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please fill all the fields.')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text("Add Card"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment Methods',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Default Payment Section
            const Text(
              'Default Payment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: Image.network(
                  'https://cdn-icons-png.flaticon.com/512/5977/5977576.png',
                  width: 40,
                  height: 40,
                ),
                title: const Text('Apple Pay'),
                subtitle: const Text('Default'),
                trailing: Radio<String>(
                  value: 'Apple Pay',
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) => _setDefaultPaymentMethod(value!),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Credit & Debit Card Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Credit & Debit Card',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _showAddCardModal,
                  child: const Text(
                    'Add new card',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Cards List
            ..._cards.map((card) {
              return Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Image.network(
                            card['logo']!,
                            width: 40,
                            height: 40,
                          ),
                          title: Text(
                              '${card['type']} ending in ${card['ending']}'),
                          subtitle: Text('Expiry ${card['expiry']}'),
                          trailing: Radio<String>(
                            value: '${card['type']} ending in ${card['ending']}',
                            groupValue: _selectedPaymentMethod,
                            onChanged: (value) =>
                                _setDefaultPaymentMethod(value!),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Set as default',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              const Text(
                                'Edit',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}