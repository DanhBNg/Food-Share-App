# 🎛️ Food Share Admin Panel

Trang quản trị hoàn chỉnh cho hệ thống chia sẻ thực phẩm Food Share.

## 📋 Nội dung

- [Tính năng](#tính-năng)
- [Yêu cầu hệ thống](#yêu-cầu-hệ-thống)
- [Cài đặt & Chạy](#cài-đặt--chạy)
- [Hướng dẫn sử dụng](#hướng-dẫn-sử-dụng)
- [Kiến trúc](#kiến-trúc)
- [Firebase Integration](#firebase-integration)

## 🌟 Tính năng

### 1. **Xác thực & Bảo mật** 🔐
- Đăng nhập bằng Firebase Authentication
- Kiểm tra quyền Admin
- Quản lý phiên đăng nhập
- Bảo mật token JWT

### 2. **Dashboard** 📊
- Thống kê tổng quan hệ thống
- Số lượng người dùng, bài đăng, tin nhắn
- Người dùng hoạt động trong 24h
- Bài đăng gần đây
- Biểu đồ thực thời

### 3. **Quản lý Người dùng** 👥
- Xem danh sách tất cả người dùng
- Tìm kiếm người dùng
- Xem chi tiết người dùng
- Cập nhật trạng thái
- Phân quyền (Admin/Người dùng)
- Xóa người dùng

### 4. **Quản lý Bài đăng** 📝
- Xem tất cả bài đăng
- Tìm kiếm bài đăng
- Lọc theo trạng thái
- Xem chi tiết bài đăng
- Xóa bài đăng không phù hợp
- Xem ảnh bài đăng

### 5. **Quản lý Tin nhắn** 💬
- Xem lịch sử cuộc trò chuyện
- Tìm kiếm tin nhắn
- Xem nội dung tin nhắn
- Xóa tin nhắn
- Giám sát giao tiếp

### 6. **Báo cáo & Thống kê** 📈
- Tỷ lệ tăng trưởng người dùng
- Bài đăng trung bình/ngày
- Thời gian phản hồi trung bình
- Tỷ lệ giữ chân người dùng
- Top người dùng hoạt động
- Thống kê chi tiết

### 7. **Cài đặt hệ thống** ⚙️
- Cài đặt chung
- Bảo trì hệ thống
- Quản lý thông báo
- Cấu hình Firebase

## 🔧 Yêu cầu hệ thống

- **Browser**: Chrome, Firefox, Safari, Edge (phiên bản mới)
- **JavaScript**: ES6+
- **Firebase**: Firestore & Firebase Auth (tích hợp sẵn)
- **Node.js**: Không cần (thuần JavaScript)

## 🚀 Cài đặt & Chạy

### 1. Clone/Download dự án
```bash
cd Food-Share-App/web_admin
```

### 2. Cấu hình Firebase (trong admin.js)
```javascript
const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_AUTH_DOMAIN",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_STORAGE_BUCKET",
    messagingSenderId: "YOUR_MESSAGING_ID",
    appId: "YOUR_APP_ID"
};
```

### 3. Tạo admin account
Trong Firebase Console:
1. Authentication → Users → Add user
   - Email: admin@test.com
   - Password: 123456

2. Firestore → users → Tạo document:
   ```json
   {
     "email": "admin@test.com",
     "name": "Admin",
     "role": "Admin",
     "createdAt": "2024-01-01T00:00:00Z"
   }
   ```

### 4. Chạy local server
```bash
# Nếu có Python 3
python -m http.server 8000

# Hoặc nếu có Node.js
npx http-server

# Hoặc dùng VS Code Live Server
# Cấu hình Launch.json để mở index.html
```

### 5. Truy cập
```
http://localhost:8000/
```

## 📖 Hướng dẫn sử dụng

### Đăng nhập
1. Nhập email: `admin@test.com`
2. Nhập mật khẩu: `123456`
3. Bấm "Đăng nhập"

### Dashboard
- Xem thống kê tổng quan
- Theo dõi bài đăng gần đây
- Kiểm tra hoạt động người dùng

### Quản lý Người dùng
1. Bấm "Người dùng" trên menu
2. Tìm kiếm người dùng
3. Bấm "Xem" để chi tiết
4. Cập nhật trạng thái nếu cần
5. Bấm "Lưu thay đổi"

### Quản lý Bài đăng
1. Bấm "Bài đăng" trên menu
2. Tìm kiếm hoặc lọc bài đăng
3. Xem chi tiết hoặc xóa bài
4. Xác nhận khi xóa

### Báo cáo
1. Bấm "Báo cáo" trên menu
2. Xem thống kê chung
3. Xem top người dùng

## 🏗️ Kiến trúc

### File Structure
```
web_admin/
├── index.html          # Giao diện HTML
├── admin.js           # Logic & Firebase Integration
└── README.md          # Tài liệu này
```

### Công nghệ sử dụng
```
┌─────────────────────────────────────┐
│        Food Share Admin Panel       │
├─────────────────────────────────────┤
│  HTML5 (Semantic) + CSS3 + ES6 JS  │
├─────────────────────────────────────┤
│         Firebase SDK v10.7          │
├─────────────────────────────────────┤
│  Firebase Auth + Firestore + RTDB  │
├─────────────────────────────────────┤
│      Flutter Mobile Application    │
└─────────────────────────────────────┘
```

### Luồng dữ liệu

```
┌─────────────┐
│  User Login │
└──────┬──────┘
       │
       ▼
┌──────────────────┐      ┌─────────────┐
│  Firebase Auth   │─────▶│  Token JWT  │
└──────┬───────────┘      └─────────────┘
       │
       ▼
┌──────────────────┐
│ Check Admin Role │
└──────┬───────────┘
       │
       ├─ YES ─▶ ┌──────────────────┐
       │         │ Load Admin Panel  │
       │         └──────────────────┘
       │
       └─ NO ──▶ ┌──────────────────┐
                 │ Show Error & Exit │
                 └──────────────────┘
```

## 🔗 Firebase Integration

### Collections sử dụng

#### 1. **users**
```json
{
  "userId": {
    "name": "Nguyễn Văn A",
    "email": "user@example.com",
    "role": "Người dùng",
    "photo": "url",
    "createdAt": "timestamp",
    "phone": "0123456789",
    "address": "123 Đường ABC"
  }
}
```

#### 2. **posts**
```json
{
  "postId": {
    "userId": "uid",
    "userName": "Nguyễn Văn A",
    "ingredientName": "Rau cải",
    "quantity": "10 kg",
    "price": "50000",
    "address": "Hà Nội",
    "description": "Rau sạch...",
    "imageUrl": "url",
    "createdAt": "timestamp",
    "productUrl": "url"
  }
}
```

#### 3. **messages** (Realtime Database)
```json
{
  "messages": {
    "chatId": {
      "messageId": {
        "senderId": "uid",
        "text": "Hello",
        "imageUrl": "url",
        "timestamp": 1234567890,
        "seen": false
      }
    }
  }
}
```

## 📊 API Endpoints (Firebase)

### Authentication
```javascript
// Login
await signInWithEmailAndPassword(auth, email, password);

// Logout
await signOut(auth);

// Check auth state
onAuthStateChanged(auth, (user) => { ... });
```

### Firestore Queries
```javascript
// Get all users
const usersSnap = await getDocs(collection(db, 'users'));

// Get user by ID
const userDoc = await getDoc(doc(db, 'users', userId));

// Get posts with filter
const q = query(collection(db, 'posts'), where('userId', '==', userId));
const postsSnap = await getDocs(q);

// Update user
await updateDoc(doc(db, 'users', userId), { role: 'Admin' });

// Delete post
await deleteDoc(doc(db, 'posts', postId));
```

## 🎨 Tùy chỉnh Giao diện

### Thay đổi màu chủ đề
Trong `index.html`, tìm và sửa:
```css
/* Gradient màu chính */
background: linear-gradient(135deg, #1976D2 0%, #FBC2EB 100%);

/* Màu primary */
color: #1976D2;

/* Màu success */
color: #4caf50;
```

### Thêm màn hình mới
1. Thêm HTML trong `index.html`:
```html
<div id="new-page" class="page-section">
    <!-- Nội dung -->
</div>
```

2. Thêm menu item:
```html
<li><a href="#" class="menu-item" data-page="new">📌 Trang mới</a></li>
```

3. Thêm function trong `admin.js`:
```javascript
async function loadNewPageData() {
    // Load data
}
```

## 🔒 Bảo mật

### Best Practices

1. **Firebase Security Rules** (Firestore)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId || 
                            request.auth.uid in get(/databases/$(database)/documents/users/$(request.auth.uid)).data.adminIds;
      allow read: if request.auth.uid != null;
    }
    match /posts/{postId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == resource.data.userId;
      allow delete: if request.auth.uid in get(/databases/$(database)/documents/users/$(request.auth.uid)).data.adminIds;
    }
  }
}
```

2. **Admin Verification**
```javascript
// Luôn kiểm tra role trước khi render admin features
if (userData && userData.role === 'Admin') {
    // Show admin panel
}
```

3. **Token Management**
```javascript
// Firebase SDK quản lý JWT token tự động
// Không cần lưu token thủ công
```

## 🐛 Troubleshooting

### Lỗi: "Bạn không có quyền truy cập Admin Panel"
- **Nguyên nhân**: User không có role 'Admin'
- **Giải pháp**: Vào Firestore, tìm user document và thêm `"role": "Admin"`

### Lỗi: "Firebase initialization error"
- **Nguyên nhân**: Config Firebase sai
- **Giải pháp**: Kiểm tra Firebase config trong `admin.js`

### Dữ liệu không hiển thị
- **Nguyên nhân**: Firestore Security Rules từ chối truy cập
- **Giải pháp**: Sửa rules hoặc tạo test data

## 📚 Tài liệu thêm

- [Firebase Documentation](https://firebase.google.com/docs)
- [Firestore Guide](https://firebase.google.com/docs/firestore)
- [Firebase Auth](https://firebase.google.com/docs/auth)
- [Web Standards](https://developer.mozilla.org/en-US/)

## 📝 Ghi chú

- Admin panel này chỉ dùng JavaScript thuần, không có framework
- Tích hợp trực tiếp với Firebase project của ứng dụng Flutter
- Tất cả dữ liệu đều được lưu trữ trong Firebase (không backend server riêng)
- Có thể triển khai lên Firebase Hosting hoặc bất kỳ web server nào

## 🚢 Triển khai lên Firebase Hosting

```bash
# 1. Cài đặt Firebase CLI
npm install -g firebase-tools

# 2. Login Firebase
firebase login

# 3. Initialize Firebase Hosting
firebase init hosting

# 4. Deploy
firebase deploy --only hosting
```

Sau đó truy cập URL: `https://your-project.web.app/web_admin`

## 📞 Hỗ trợ

Nếu gặp vấn đề:
1. Kiểm tra console (F12 → Console tab)
2. Xem lỗi Firebase trong Firestore Rules
3. Đảm bảo security rules cho phép truy cập

---

**Phiên bản**: 1.0.0  
**Cập nhật**: 2024-02-03  
**Tác giả**: GitHub Copilot  
**License**: MIT
