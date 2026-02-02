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
          border: Border.all(
            color: selected ? Colors.transparent : Colors.grey.shade300,
            width: 1,
          ),
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
            Icon(
              _planIcon(p.id),
              color: selected ? Colors.white : Colors.blue.shade700,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${p.basePosts} lượt đăng • ${p.durationMonths} tháng",
                    style: TextStyle(
                      color: selected ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "${p.basePrice}đ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: selected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _peopleChip(int value, String priceText) {
    final selected = selectedPeople == value;
    return ChoiceChip(
      label: Text("$value người ($priceText)"),
      selected: selected,
      onSelected: (_) => setState(() => selectedPeople = value),
      selectedColor: const Color(0xFF1976D2),
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text(
          "Mua gói đăng tin",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1976D2),
                Color(0xFFFBC2EB),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("📦 Chọn gói đăng tin",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...plans.map(_planCard),

            const SizedBox(height: 16),
            const Text("👥 Số người hiển thị",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: [
                _peopleChip(50, "+0đ"),
                _peopleChip(100, "+20k"),
                _peopleChip(200, "+50k"),
              ],
            ),

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
              child: Row(
                children: [
                  const Text(
                    "Tổng tiền:",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const Spacer(),
                  Text(
                    "$totalPrice đ",
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: selectedPlan == null ? null : () {
                  final qrUrl = PaymentService.generateQrUrl(
                    packageId: selectedPlan!.id,
                    peopleCount: selectedPeople,
                    price: totalPrice,
                  );

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Quét QR để thanh toán"),
                      content: Image.network(qrUrl),
                    ),
                  );
                },
                icon: const Icon(Icons.post_add),
                label: const Text("Thanh toán gói đăng tin",
                    style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
