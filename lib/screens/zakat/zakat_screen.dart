import 'package:flutter/material.dart';
import '../../models/zakat.dart';

class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _calculatorAmountController = TextEditingController();
  final TextEditingController _ricePriceController = TextEditingController();
  String _selectedType = 'maal';
  double _calculatedZakat = 0;
  bool _isCalculatorMode = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _calculatorAmountController.dispose();
    _ricePriceController.dispose();
    super.dispose();
  }

  void _calculateZakat() {
    if (_isCalculatorMode) {
      if (_formKey.currentState!.validate()) {
        if (_selectedType == 'maal') {
          final amount = double.parse(_calculatorAmountController.text);
          setState(() {
            _calculatedZakat = ZakatCalculator.calculateZakatMaal(amount);
            _amountController.text = _calculatedZakat.toString();
          });
        } else {
          final ricePrice = double.parse(_ricePriceController.text);
          setState(() {
            _calculatedZakat = ZakatCalculator.calculateZakatFitrah(ricePriceKg: ricePrice);
            _amountController.text = _calculatedZakat.toString();
          });
        }
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveZakat() {
    if (_formKey.currentState!.validate()) {
      final zakat = Zakat(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: double.parse(_amountController.text),
        type: _selectedType,
        date: _selectedDate,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data zakat berhasil disimpan!')),
      );

      Navigator.pop(context, zakat);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isCalculatorMode ? 'Kalkulator Zakat' : 'Input Data Zakat',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isCalculatorMode ? Icons.edit_note : Icons.calculate),
            onPressed: () {
              setState(() {
                _isCalculatorMode = !_isCalculatorMode;
                _calculatedZakat = 0;
              });
            },
            tooltip: _isCalculatorMode ? 'Mode Input' : 'Mode Kalkulator',
          ),
        ],
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
                        'Jenis Zakat',
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
              if (_isCalculatorMode) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedType == 'maal' ? 'Zakat Maal (2.5%)' : 'Zakat Fitrah (2.5 kg)',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _selectedType == 'maal'
                              ? _calculatorAmountController
                              : _ricePriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: _selectedType == 'maal'
                                ? 'Total Harta (Rp)'
                                : 'Harga Beras per Kg (Rp)',
                            border: const OutlineInputBorder(),
                            prefixIcon: Icon(_selectedType == 'maal'
                                ? Icons.money
                                : Icons.rice_bowl),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Masukkan nilai';
                            }
                            final num = double.tryParse(value);
                            if (num == null || num < 0) {
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
                ElevatedButton.icon(
                  onPressed: _calculateZakat,
                  icon: const Icon(Icons.calculate),
                  label: const Text('Hitung Zakat'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                if (_calculatedZakat > 0) ...[
                  const SizedBox(height: 20),
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
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _isCalculatorMode = false;
                              });
                            },
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Gunakan nilai ini'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
              if (!_isCalculatorMode) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Pemberi Zakat',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan nama pemberi zakat';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Zakat (Rp)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.money),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Masukkan jumlah zakat';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Masukkan jumlah yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Zakat',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (Opsional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _saveZakat,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan Data Zakat'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
