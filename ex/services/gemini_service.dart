import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey = 'AIzaSyDNkMVPsw5uwQBU9zBo5Gc8oF3gqee1epY';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  
  static DateTime? _lastRequestTime;
  static const int _minDelayMs = 2000; // 2 giây giữa các request

  static Future<String?> sendMessage(String message) async {
    // Rate limiting: đảm bảo ít nhất 2 giây giữa các request
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!).inMilliseconds;
      if (timeSinceLastRequest < _minDelayMs) {
        await Future.delayed(Duration(milliseconds: _minDelayMs - timeSinceLastRequest));
      }
    }
    _lastRequestTime = DateTime.now();
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-goog-api-key': _apiKey,
        },
        body: json.encode({
          'contents': [
            {
              'parts': [
                {
                  'text': message,
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 20,
            'topP': 0.8,
            'maxOutputTokens': 256,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty && 
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          
          return data['candidates'][0]['content']['parts'][0]['text'];
        }
        
        return 'Tôi không thể trả lời câu hỏi này ngay bây giờ.';
      } else if (response.statusCode == 404) {
        print('Model not found: ${response.body}');
        return '🔍 Model AI không tồn tại.\n\nVui lòng kiểm tra lại cấu hình API.';
      } else if (response.statusCode == 429) {
        print('Quota exceeded: ${response.body}');
        return '🚫 API đã vượt giới hạn sử dụng hàng ngày.\n\nBạn có thể:\n• Đợi đến ngày mai để reset quota\n• Kiểm tra billing account trên Google Cloud\n• Sử dụng API key khác nếu có';
      } else if (response.statusCode == 401) {
        print('Unauthorized: ${response.body}');
        return '🔑 API key không hợp lệ hoặc đã hết hạn.\n\nVui lòng kiểm tra lại API key.';
      } else if (response.statusCode == 403) {
        print('Forbidden: ${response.body}');
        return '⛔ Không có quyền truy cập API.\n\nVui lòng kiểm tra cấu hình API key.';
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return '❌ Lỗi kết nối API (${response.statusCode}).\n\nVui lòng thử lại sau.';
      }
    } catch (e) {
      print('Gemini API Error: $e');
      return '🌐 Không thể kết nối với AI.\n\nVui lòng kiểm tra kết nối mạng và thử lại.';
    }
  }
}