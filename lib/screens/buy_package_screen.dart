import 'package:flutter/material.dart';
import '../models/package_plan.dart';
import '../services/payment_service.dart';

class BuyPackageScreen extends StatefulWidget {
  const BuyPackageScreen({super.key});

  @override
  State<BuyPackageScreen> createState() => _BuyPackageScreenState();
}

class _BuyPackageScreenState extends State<BuyPackageScreen> {
  final plans = [
    PackagePlan(id: 'month', name: 'Gói Tháng', basePosts: 40, durationMonths: 1, basePrice: 50000),
    PackagePlan(id: 'quarter', name: 'Gói Quý', basePosts: 150, durationMonths: 3, basePrice: 120000),
    PackagePlan(id: 'year', name: 'Gói Năm', basePosts: 550, durationMonths: 12, basePrice: 400000),
  ];

  PackagePlan? selectedPlan;
  int selectedPeople = 50;

  int get totalPrice {
    if (selectedPlan == null) return 0;
    int extra = 0;
    if (selectedPeople == 100) extra = 20000;
    if (selectedPeople == 200) extra = 50000;
    return selectedPlan!.basePrice + extra;
  }

  IconData _planIcon(String id) {
    switch (id) {
      case 'month':
        return Icons.event_note;
      case 'quarter':
        return Icons.calendar_view_month;
      case 'year':
        return Icons.calendar_today;
      default:
        return Icons.post_add;
    }
  }

  Widget _planCard(PackagePlan p) {
    final selected = selectedPlan == p;
    return GestureDetector(
      onTap: () => setState(() => selectedPlan = p),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFFFBC2EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black.withOpacity(0.06),
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(_planIcon(p.id), color: selected ? Colors.white : Colors.blue, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.name,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: selected ? Colors.white : Colors.black)),
                const SizedBox(height: 4),
                Text("${p.basePosts} lượt • ${p.durationMonths} tháng",
                    style: TextStyle(color: selected ? Colors.white70 : Colors.grey)),
              ]),
            ),
            Text("${p.basePrice}đ",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: selected ? Colors.white : Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _peopleChip(int value, String priceText) {
    final selected = selectedPeople == value;
    return ChoiceChip(
      label: Text("$value người ($priceText)"),
      selected: selected,
      selectedColor: const Color(0xFF1976D2),
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
      onSelected: (_) => setState(() => selectedPeople = value),
    );
  }

  /// QR
  void _showQrDialog() {
    final qrUrl = PaymentService.generateQrUrl(
      packageId: selectedPlan!.id,
      peopleCount: selectedPeople,
      price: totalPrice,
    );

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFFFBC2EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text("Quét mã QR để thanh toán",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(qrUrl, height: 220, width: 220),
            ),
            const SizedBox(height: 12),
            Text("Gói: ${selectedPlan!.name} • $selectedPeople người",
                style: const TextStyle(color: Colors.white)),
            Text("Số tiền: $totalPrice đ",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text("Đóng", style: TextStyle(color: Color(0xFF1976D2))),
            )
          ]),
        ),
      ),
    );
  }

  /// App payment (MoMo / ZaloPay link)
  Future<void> _payWithApp() async {
    final url = await PaymentService.generateAppPaymentUrl(
      packageId: selectedPlan!.id,
      peopleCount: selectedPeople,
      price: totalPrice,
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Thanh toán bằng app"),
        content: Text("Mở link:\n\n$url"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Đóng"))
        ],
      ),
    );
  }

  /// Chọn phương thức
  void _showPaymentMethodDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text("Chọn phương thức thanh toán",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.qr_code_2, color: Color(0xFF1976D2)),
            title: const Text("Quét mã QR"),
            onTap: () {
              Navigator.pop(context);
              _showQrDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet, color: Colors.pink),
            title: const Text("MoMo / ZaloPay"),
            onTap: () {
              Navigator.pop(context);
              _payWithApp();
            },
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text("Mua gói đăng tin",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18
            )
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFFFBC2EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("📦 Chọn gói đăng tin", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...plans.map(_planCard),
          const SizedBox(height: 16),
          const Text("👥 Số người hiển thị", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [
            _peopleChip(50, "+0đ"),
            _peopleChip(100, "+20k"),
            _peopleChip(200, "+50k"),
          ]),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFFFBC2EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              const Text("Tổng tiền:", style: TextStyle(color: Colors.white)),
              const Spacer(),
              Text("$totalPrice đ",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: selectedPlan == null ? null : _showPaymentMethodDialog,
              icon: const Icon(Icons.payment, color: Colors.white),
              label: const Text("Thanh toán gói đăng tin",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
