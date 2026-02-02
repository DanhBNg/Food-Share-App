class PaymentService {
  /// Fake QR URL – sau này thay bằng API thật
  static String generateQrUrl({
    required String packageId,
    required int peopleCount,
    required int price,
  }) {
    return "https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=FOODSHARE-$packageId-$peopleCount-$price";
  }
}
