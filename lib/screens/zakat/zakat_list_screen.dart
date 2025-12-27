import 'package:flutter/material.dart';
import '../../models/zakat.dart';
import '../../services/zakat_service.dart';
import 'zakat_screen.dart';

class ZakatListScreen extends StatefulWidget {
  final bool isAdmin;

  const ZakatListScreen({
    super.key,
    required this.isAdmin,
  });

  @override
  State<ZakatListScreen> createState() => _ZakatListScreenState();
}

class _ZakatListScreenState extends State<ZakatListScreen> {
  final ZakatService _zakatService = ZakatService();
  List<Zakat> _zakatList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadZakatData();
  }

  Future<void> _loadZakatData() async {
    try {
      final data = await _zakatService.getAllZakat();
      if (mounted) {
        setState(() {
          _zakatList = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalMaal = _zakatList
        .where((z) => z.type == 'maal')
        .fold<double>(0, (sum, item) => sum + item.amount);
    final totalFitrah = _zakatList
        .where((z) => z.type == 'fitrah')
        .fold<double>(0, (sum, item) => sum + item.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isAdmin ? 'Pencatatan Zakat' : 'Total Zakat Diterima',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ZakatScreen()),
                );
                if (result != null) {
                  await _loadZakatData(); // Reload list
                }
              },
              backgroundColor: Colors.green,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Zakat'),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Column(
              children: [
                // Summary Card
                Card(
                  margin: const EdgeInsets.all(16.0),
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          'Total Zakat Diterima',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryItem('Zakat Maal', totalMaal, Colors.green),
                            _buildSummaryItem('Zakat Fitrah', totalFitrah, Colors.orange),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        Text(
                          'Total: Rp ${(totalMaal + totalFitrah).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Zakat List
                Expanded(
                  child: _zakatList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox, size: 80, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                          'Belum ada data zakat',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _zakatList.length,
                    itemBuilder: (context, index) {
                      final zakat = _zakatList[index];
                      return _buildZakatCard(zakat);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          'Rp ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildZakatCard(Zakat zakat) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: zakat.type == 'maal' ? Colors.green : Colors.orange,
          child: Icon(
            zakat.type == 'maal' ? Icons.monetization_on : Icons.rice_bowl,
            color: Colors.white,
          ),
        ),
        title: Text(
          zakat.type == 'maal' ? 'Zakat Maal' : 'Zakat Fitrah',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rp ${zakat.amount.toStringAsFixed(2)}'),
            Text(
              _formatDate(zakat.date),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            if (zakat.note != null && zakat.note!.isNotEmpty)
              Text(
                zakat.note!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: widget.isAdmin
            ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _showDeleteDialog(zakat.id);
                },
              )
            : null,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog( // Rename 'context' to 'dialogContext'
        title: const Text('Hapus Zakat'),
        content: const Text('Apakah Anda yakin ingin menghapus data zakat ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), // Use dialogContext
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Use dialogContext
              if (!mounted) return;
              
              try {
                await _zakatService.deleteZakat(id);
                await _loadZakatData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar( // Now correctly uses outer context
                    const SnackBar(content: Text('Data zakat berhasil dihapus')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar( // Now correctly uses outer context
                    SnackBar(content: Text('Gagal menghapus: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
