class PaymentService {
  /// QR code (giữ cách cũ)
  static String generateQrUrl({
    required String packageId,
    required int peopleCount,
    required int price,
  }) {
    return "https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=FOODSHARE-$packageId-$peopleCount-$price";
  }

  /// Tạo link thanh toán MoMo / ZaloPay (giả lập – sau này nối backend Firebase)
  static Future<String> generateAppPaymentUrl({
    required String packageId,
    required int peopleCount,
    required int price,
  }) async {
    // Sau này: gọi Firebase Cloud Function tạo order thật
    return "https://momo.vn/pay?amount=$price&orderId=$packageId-$peopleCount";
  }
}
