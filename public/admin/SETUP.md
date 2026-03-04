#!/usr/bin/env bash

# ==============================================================
# SETUP GUIDE FOR FOOD SHARE ADMIN PANEL
# ==============================================================
# Hướng dẫn chi tiết để cài đặt và chạy Web Admin Panel
# ==============================================================

echo "🚀 FOOD SHARE ADMIN PANEL - SETUP GUIDE"
echo "========================================"
echo ""

# Step 1: Firebase Project
echo "📋 Step 1: Chuẩn bị Firebase Project"
echo "-----------------------------------"
echo "1. Vào https://console.firebase.google.com"
echo "2. Chọn project 'food-share-fce9b'"
echo "3. Nếu chưa có, tạo project mới"
echo ""
echo "✅ Project ID: food-share-fce9b"
echo ""

# Step 2: Authentication Setup
echo "🔐 Step 2: Cấu hình Firebase Authentication"
echo "--------------------------------------------"
echo "1. Vào Authentication → Users"
echo "2. Bấm 'Add User'"
echo "3. Nhập:"
echo "   Email: admin@test.com"
echo "   Password: 123456"
echo "4. Bấm 'Add User'"
echo ""

# Step 3: Create Admin User in Firestore
echo "👤 Step 3: Tạo Admin User trong Firestore"
echo "------------------------------------------"
echo "1. Vào Firestore → Collections → users"
echo "2. Bấm 'Add collection' → Đặt tên: 'users'"
echo "3. Bấm 'Add document'"
echo "4. Document ID: <admin-user-uid-từ-auth>"
echo "5. Thêm fields:"
echo ""
echo "   name: (string) 'Admin'"
echo "   email: (string) 'admin@test.com'"
echo "   role: (string) 'Admin'"
echo "   createdAt: (timestamp) NOW"
echo "   phone: (string) '0123456789'"
echo "   address: (string) 'Admin Address'"
echo ""

# Step 4: Setup Firestore Rules
echo "🔒 Step 4: Cấu hình Firestore Security Rules"
echo "---------------------------------------------"
echo "1. Vào Firestore → Rules tab"
echo "2. Xóa rules hiện tại"
echo "3. Dán nội dung từ file: firestore.rules"
echo "4. Bấm 'Publish'"
echo ""

# Step 5: Update Firebase Config
echo "⚙️  Step 5: Cập nhật Firebase Config"
echo "-----------------------------------"
echo "1. Vào Project Settings (Biểu tượng gear)"
echo "2. Chọn tab 'Your apps'"
echo "3. Chọn ứng dụng Web"
echo "4. Copy Firebase config object"
echo "5. Dán vào file: admin.js (dòng ~1-8)"
echo ""
echo "Cấu trúc config:"
echo "{
  apiKey: 'YOUR_API_KEY',
  authDomain: 'food-share-fce9b.firebaseapp.com',
  projectId: 'food-share-fce9b',
  storageBucket: 'food-share-fce9b.appspot.com',
  messagingSenderId: 'YOUR_MESSAGING_ID',
  appId: 'YOUR_APP_ID'
}"
echo ""

# Step 6: Enable Firestore
echo "📦 Step 6: Enable Firestore Database"
echo "------------------------------------"
echo "1. Vào Firestore → Database"
echo "2. Bấm 'Create Database'"
echo "3. Chọn region gần nhất"
echo "4. Chọn 'Start in test mode' (hoặc production)"
echo "5. Bấm 'Enable'"
echo ""

# Step 7: Add Test Data
echo "🗂️  Step 7: Thêm Test Data (Tùy chọn)"
echo "-----------------------------------"
echo "1. Tạo collection 'posts'"
echo "2. Thêm document với:"
echo ""
echo "{
  userId: 'test-user-id',
  userName: 'Test User',
  ingredientName: 'Rau cải',
  quantity: '10 kg',
  price: '50000',
  address: 'Hà Nội',
  description: 'Rau sạch không hóa chất',
  createdAt: NOW,
  productUrl: 'https://example.com'
}"
echo ""

# Step 8: Run Local Server
echo "🌐 Step 8: Chạy Local Server"
echo "---------------------------"
echo ""
echo "Lựa chọn 1 - Python:"
echo "  cd web_admin"
echo "  python -m http.server 8000"
echo ""
echo "Lựa chọn 2 - Node.js (http-server):"
echo "  npm install -g http-server"
echo "  cd web_admin"
echo "  http-server"
echo ""
echo "Lựa chọn 3 - VS Code Live Server:"
echo "  Cấu hình extension Live Server"
echo "  Chuột phải vào index.html → 'Open with Live Server'"
echo ""

# Step 9: Access Admin Panel
echo "✨ Step 9: Truy cập Admin Panel"
echo "------------------------------"
echo ""
echo "URL: http://localhost:8000"
echo ""
echo "Đăng nhập với:"
echo "  Email: admin@test.com"
echo "  Mật khẩu: 123456"
echo ""

# Step 10: Features
echo "🎯 Step 10: Tính năng Admin Panel"
echo "--------------------------------"
echo ""
echo "✅ Dashboard"
echo "   - Thống kê tổng quan"
echo "   - Bài đăng gần đây"
echo ""
echo "✅ Quản lý Người dùng"
echo "   - Xem danh sách users"
echo "   - Tìm kiếm users"
echo "   - Xem chi tiết, xóa user"
echo ""
echo "✅ Quản lý Bài đăng"
echo "   - Xem tất cả bài đăng"
echo "   - Tìm kiếm, lọc bài đăng"
echo "   - Xem chi tiết, xóa bài"
echo ""
echo "✅ Quản lý Tin nhắn"
echo "   - Xem lịch sử trò chuyện"
echo "   - Tìm kiếm tin nhắn"
echo ""
echo "✅ Báo cáo & Thống kê"
echo "   - Thống kê chi tiết"
echo "   - Top users hoạt động"
echo ""
echo "✅ Cài đặt hệ thống"
echo "   - Cấu hình chung"
echo ""

# Troubleshooting
echo ""
echo "⚠️  TROUBLESHOOTING"
echo "==================="
echo ""
echo "❌ 'Bạn không có quyền truy cập Admin Panel'"
echo "   → Kiểm tra role trong users collection"
echo "   → Phải có: role = 'Admin'"
echo ""
echo "❌ 'Firebase initialization error'"
echo "   → Kiểm tra Firebase config"
echo "   → Kiểm tra console (F12) để xem lỗi"
echo ""
echo "❌ Dữ liệu không hiển thị"
echo "   → Kiểm tra Firestore Rules"
echo "   → Kiểm tra security rules cho phép truy cập"
echo ""
echo "❌ CORS error"
echo "   → Dùng http://localhost thay vì file://"
echo "   → Chạy local server"
echo ""

# Deployment
echo ""
echo "🚢 DEPLOYMENT (Tùy chọn)"
echo "========================"
echo ""
echo "Deploy lên Firebase Hosting:"
echo ""
echo "1. npm install -g firebase-tools"
echo "2. firebase login"
echo "3. firebase init hosting"
echo "4. firebase deploy --only hosting"
echo ""
echo "URL sẽ là: https://your-project.web.app"
echo ""

# Security Tips
echo ""
echo "🔒 SECURITY TIPS"
echo "================"
echo ""
echo "1. Đổi mật khẩu admin mặc định"
echo "2. Sử dụng strong passwords"
echo "3. Enable 2FA cho Firebase"
echo "4. Định kỳ review Firestore Rules"
echo "5. Backup dữ liệu Firestore"
echo "6. Monitor admin activities"
echo ""

# Contact & Support
echo ""
echo "📞 SUPPORT"
echo "=========="
echo "Firebase Docs: https://firebase.google.com/docs"
echo "Firestore: https://firebase.google.com/docs/firestore"
echo "Firebase Auth: https://firebase.google.com/docs/auth"
echo ""

echo "✅ SETUP COMPLETE!"
echo ""
echo "Chúc bạn sử dụng Food Share Admin Panel thành công! 🎉"
echo ""
