import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/zakat.dart';
import '../../services/zakat_service.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_dimensions.dart';
import '../../constants/app_text_styles.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';

class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _calculatorAmountController = TextEditingController();
  final TextEditingController _ricePriceController = TextEditingController();
  final ZakatService _zakatService = ZakatService();
  final _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String _selectedType = 'maal';
  double _calculatedZakat = 0;
  bool _isCalculatorMode = false;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
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
            _amountController.text = _calculatedZakat.toStringAsFixed(0);
          });
        } else {
          final ricePrice = double.parse(_ricePriceController.text);
          setState(() {
            _calculatedZakat = ZakatCalculator.calculateZakatFitrah(ricePriceKg: ricePrice);
            _amountController.text = _calculatedZakat.toStringAsFixed(0);
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveZakat() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final zakat = Zakat(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: double.parse(_amountController.text),
        type: _selectedType,
        date: _selectedDate,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );

      try {
        await _zakatService.addZakat(zakat);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.white),
                  const SizedBox(width: AppDimensions.spacingS),
                  const Text('Data zakat berhasil disimpan!'),
                ],
              ),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: AppColors.white),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(child: Text('Gagal menyimpan: $e')),
                ],
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: AppPadding.allL,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeSelector(),
                    const SizedBox(height: AppDimensions.spacingL),
                    if (_isCalculatorMode) _buildCalculator() else _buildInputForm(),
                    const SizedBox(height: AppDimensions.spacingXL),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: AppPadding.allL,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    _isCalculatorMode ? 'Kalkulator Zakat' : 'Input Data Zakat',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.white,
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(AppDimensions.spacingS),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.2),
            borderRadius: AppRadius.allS,
          ),
          child: IconButton(
            icon: Icon(
              _isCalculatorMode ? Icons.edit_note_rounded : Icons.calculate_rounded,
              color: AppColors.white,
            ),
            onPressed: () {
              setState(() {
                _isCalculatorMode = !_isCalculatorMode;
                _calculatedZakat = 0;
              });
            },
            tooltip: _isCalculatorMode ? 'Mode Input' : 'Mode Kalkulator',
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: AppPadding.allM,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.allL,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Jenis Zakat', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimensions.spacingM),
          Row(
            children: [
              Expanded(
                child: _buildTypeOption(
                  'maal',
                  'Zakat Maal',
                  Icons.account_balance_wallet_rounded,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: _buildTypeOption(
                  'fitrah',
                  'Zakat Fitrah',
                  Icons.rice_bowl_rounded,
                  AppColors.gold,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
  }

  Widget _buildTypeOption(String type, String label, IconData icon, Color color) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          _calculatedZakat = 0;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: AppPadding.allM,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.surfaceVariant,
          borderRadius: AppRadius.allM,
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculator() {
    return Column(
      children: [
        _buildCalculatorCard(),
        if (_calculatedZakat > 0) ...[
          const SizedBox(height: AppDimensions.spacingL),
          _buildResultCard(),
        ],
      ],
    );
  }

  Widget _buildCalculatorCard() {
    return Container(
      padding: AppPadding.allL,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.allL,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedType == 'maal' ? 'Kalkulator Zakat Maal (2.5%)' : 'Kalkulator Zakat Fitrah (2.5 kg)',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: AppDimensions.spacingM),
          TextFormField(
            controller: _selectedType == 'maal'
                ? _calculatorAmountController
                : _ricePriceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: _selectedType == 'maal' ? 'Total Harta' : 'Harga Beras per Kg',
              hintText: _selectedType == 'maal' ? 'Contoh: 10000000' : 'Contoh: 15000',
              prefixText: 'Rp ',
              border: OutlineInputBorder(
                borderRadius: AppRadius.allS,
              ),
              filled: true,
              fillColor: AppColors.surfaceVariant,
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
          const SizedBox(height: AppDimensions.spacingL),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _calculateZakat,
              icon: const Icon(Icons.calculate_rounded, color: AppColors.white),
              label: Text(
                'Hitung Zakat',
                style: AppTextStyles.buttonPrimary,
              ),
              style: ElevatedButton.styleFrom(
                padding: AppPadding.vM,
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.allS,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2);
  }

  Widget _buildResultCard() {
    return Container(
      padding: AppPadding.allL,
      decoration: BoxDecoration(
        gradient: AppTheme.goldGradient,
        borderRadius: AppRadius.allL,
        boxShadow: AppTheme.cardShadowL,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_rounded, color: AppColors.white),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                'Zakat yang Harus Dibayar',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            _currencyFormatter.format(_calculatedZakat),
            style: AppTextStyles.displayMedium.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
            ),
          ).animate().scale(),
          const SizedBox(height: AppDimensions.spacingL),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _isCalculatorMode = false;
                });
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Gunakan Nilai Ini'),
              style: OutlinedButton.styleFrom(
                padding: AppPadding.vM,
                foregroundColor: AppColors.white,
                side: const BorderSide(color: AppColors.white, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.allS,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).scale();
  }

  Widget _buildInputForm() {
    return Column(
      children: [
        _buildAmountCard(),
        const SizedBox(height: AppDimensions.spacingM),
        _buildDateCard(),
        const SizedBox(height: AppDimensions.spacingM),
        _buildNoteCard(),
        const SizedBox(height: AppDimensions.spacingXL),
        _buildSaveButton(),
      ],
    );
  }

  Widget _buildAmountCard() {
    return Container(
      padding: AppPadding.allL,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.allL,
        boxShadow: AppTheme.cardShadow,
      ),
      child: TextFormField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Jumlah Zakat',
          hintText: 'Masukkan jumlah zakat',
          prefixText: 'Rp ',
          border: OutlineInputBorder(
            borderRadius: AppRadius.allS,
          ),
          filled: true,
          fillColor: AppColors.surfaceVariant,
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
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2);
  }

  Widget _buildDateCard() {
    return Container(
      padding: AppPadding.allL,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.allL,
        boxShadow: AppTheme.cardShadow,
      ),
      child: InkWell(
        onTap: _selectDate,
        borderRadius: AppRadius.allS,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Tanggal Zakat',
            border: OutlineInputBorder(
              borderRadius: AppRadius.allS,
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            prefixIcon: Icon(Icons.calendar_today_rounded, color: AppColors.primary),
          ),
          child: Text(
            DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate),
            style: AppTextStyles.bodyLarge,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2);
  }

  Widget _buildNoteCard() {
    return Container(
      padding: AppPadding.allL,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.allL,
        boxShadow: AppTheme.cardShadow,
      ),
      child: TextFormField(
        controller: _noteController,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: 'Catatan (Opsional)',
          hintText: 'Masukkan catatan tambahan',
          border: OutlineInputBorder(
            borderRadius: AppRadius.allS,
          ),
          filled: true,
          fillColor: AppColors.surfaceVariant,
          prefixIcon: Icon(Icons.note_rounded, color: AppColors.primary),
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _saveZakat,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : const Icon(Icons.save_rounded, color: AppColors.white),
        label: _isLoading
            ? Text('Menyimpan...', style: AppTextStyles.buttonPrimary)
            : Text('Simpan Data Zakat', style: AppTextStyles.buttonPrimary),
        style: ElevatedButton.styleFrom(
          padding: AppPadding.vL,
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.allS,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 450.ms).scale();
  }
}
