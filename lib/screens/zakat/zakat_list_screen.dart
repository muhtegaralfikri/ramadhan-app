import 'package:flutter/material.dart';
import '../../models/zakat.dart';
import 'zakat_screen.dart';

class ZakatListScreen extends StatefulWidget {
  final List<Zakat> zakatList;
  final Function(Zakat) onEdit;
  final Function(String) onDelete;
  final Function(Zakat) onAdd;

  const ZakatListScreen({
    super.key,
    required this.zakatList,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
  });

  @override
  State<ZakatListScreen> createState() => _ZakatListScreenState();
}

class _ZakatListScreenState extends State<ZakatListScreen> {
  @override
  Widget build(BuildContext context) {
    final totalMaal = widget.zakatList
        .where((z) => z.type == 'maal')
        .fold<double>(0, (sum, item) => sum + item.amount);
    final totalFitrah = widget.zakatList
        .where((z) => z.type == 'fitrah')
        .fold<double>(0, (sum, item) => sum + item.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencatatan Zakat', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ZakatScreen()),
          );
          if (result != null) {
            widget.onAdd(result);
          }
        },
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Zakat'),
      ),
      body: Column(
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
            child: widget.zakatList.isEmpty
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
                    itemCount: widget.zakatList.length,
                    itemBuilder: (context, index) {
                      final zakat = widget.zakatList[index];
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => widget.onEdit(zakat),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _showDeleteDialog(zakat.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Zakat'),
        content: const Text('Apakah Anda yakin ingin menghapus data zakat ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onDelete(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data zakat berhasil dihapus')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
