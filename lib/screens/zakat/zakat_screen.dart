import 'package:flutter/material.dart';
import '../../models/zakat.dart';

class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _ricePriceController = TextEditingController();
  String _selectedType = 'maal';
  double _calculatedZakat = 0;

  @override
  void dispose() {
    _amountController.dispose();
    _ricePriceController.dispose();
    super.dispose();
  }

  void _calculateZakat() {
    if (_formKey.currentState!.validate()) {
      if (_selectedType == 'maal') {
        final amount = double.parse(_amountController.text);
        setState(() {
          _calculatedZakat = ZakatCalculator.calculateZakatMaal(amount);
        });
      } else {
        final ricePrice = double.parse(_ricePriceController.text);
        setState(() {
          _calculatedZakat = ZakatCalculator.calculateZakatFitrah(ricePriceKg: ricePrice);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator Zakat', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pilih Jenis Zakat',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'maal',
                            label: Text('Zakat Maal'),
                            icon: Icon(Icons.account_balance_wallet),
                          ),
                          ButtonSegment(
                            value: 'fitrah',
                            label: Text('Zakat Fitrah'),
                            icon: Icon(Icons.rice_bowl),
                          ),
                        ],
                        selected: {_selectedType},
                        onSelectionChanged: (Set<String> newSelection) {
                          setState(() {
                            _selectedType = newSelection.first;
                            _calculatedZakat = 0;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_selectedType == 'maal')
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Zakat Maal (2.5%)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Total Harta (Rp)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.money),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Masukkan total harta';
                            }
                            final amount = double.tryParse(value);
                            if (amount == null || amount < 0) {
                              return 'Masukkan angka yang valid';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              if (_selectedType == 'fitrah')
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Zakat Fitrah (2.5 kg)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _ricePriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Harga Beras per Kg (Rp)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.rice_bowl),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Masukkan harga beras per kg';
                            }
                            final price = double.tryParse(value);
                            if (price == null || price < 0) {
                              return 'Masukkan angka yang valid';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calculateZakat,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Hitung Zakat', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20),
              if (_calculatedZakat > 0)
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          'Zakat yang Harus Dibayar:',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Rp ${_calculatedZakat.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
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
