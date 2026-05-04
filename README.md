# 🍱 Food Share App

Ứng dụng **Food Share** là nền tảng kết nối người dùng có nhu cầu **chia sẻ, trao đổi và tìm kiếm thực phẩm**.
Ứng dụng giúp giảm lãng phí thực phẩm và tạo ra một cộng đồng hỗ trợ lẫn nhau.

---

## 📱 Tính năng chính

* 🔐 Đăng ký / Đăng nhập (Firebase Authentication)
* 📝 Đăng bài chia sẻ thực phẩm (kèm hình ảnh, mô tả, giá)
* 🔍 Tìm kiếm sản phẩm theo từ khóa
* 💬 Chat realtime giữa người dùng
* ⭐ Đánh giá người dùng sau khi giao dịch
* 🖼 Upload ảnh (Supabase Storage)
* 🔗 Mở link sản phẩm bên ngoài
* 💰 Mua gói đăng tin (QR / MoMo / ZaloPay)

---

## 🛠 Công nghệ sử dụng

* **Flutter (Dart)** – phát triển đa nền tảng
* **Firebase Authentication** – xác thực người dùng
* **Cloud Firestore** – lưu trữ dữ liệu
* **Firebase Realtime Database** – chat realtime
* **Supabase Storage** – lưu trữ hình ảnh
* **intl** – format dữ liệu
* **url_launcher** – mở link ngoài
* **Git & GitHub** – quản lý mã nguồn
* **Figma** – thiết kế giao diện

---

## 📂 Cấu trúc dự án

```
lib/
 ├── models/        # Định nghĩa dữ liệu
 ├── screens/       # Giao diện
 ├── services/      # Xử lý logic & API
 ├── widgets/       # Component UI
```

---

## ⚙️ Cài đặt & chạy dự án

### 1. Clone project

```bash
git clone https://github.com/your-repo/food-share.git
cd food-share
```

---

### 2. Cài dependencies

```bash
flutter pub get
```

---

### 3. Cấu hình Firebase

* Tạo project trên Firebase
* Thêm app Android / iOS / Web
* Tải file:

```
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

---

### 4. Cấu hình Supabase

* Tạo project tại https://supabase.com
* Lấy:

  * `SUPABASE_URL`
  * `SUPABASE_ANON_KEY`
* Gán vào project

---

### 5. Chạy app

```bash
flutter run
```

---

## 📦 Build APK

```bash
flutter build apk --release
```

APK nằm tại:

```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🌐 Build Web

```bash
flutter build web
```

---


## 📸 Demo

Home: <img width="946" height="2049" alt="image" src="https://github.com/user-attachments/assets/c494ad89-7290-402b-8f03-40aa49eccf6e" />
Product-detail: <img width="946" height="2049" alt="image" src="https://github.com/user-attachments/assets/0cb8ae17-4b89-4870-be0d-3440dc51cf9b" />
Search: <img width="946" height="2049" alt="image" src="https://github.com/user-attachments/assets/ac6af171-ad13-4138-96d3-044addb88b5e" />
Message: <img width="946" height="2049" alt="image" src="https://github.com/user-attachments/assets/b7e1f8a5-fa15-4cba-9592-6f0391824a7a" />
Profile: <img width="946" height="2049" alt="image" src="https://github.com/user-attachments/assets/2f61a58b-622f-4d2d-9b8c-ee8231e3f402" />
Other: <img width="946" height="2049" alt="image" src="https://github.com/user-attachments/assets/14145acf-f8a6-45f5-b2a0-dd5cc0d13715" />
<img width="946" height="2049" alt="image" src="https://github.com/user-attachments/assets/e60d16a1-1931-44db-a7df-f2806371c187" />

---

## 📌 Hướng phát triển

* Thêm hệ thống điểm uy tín người dùng
* Thống kê đánh giá
* Thanh toán tự động
* Notification realtime
* AI gợi ý sản phẩm

---

## 👨‍💻 Tác giả

**Danh Nguyễn Bảo**

GitHub: https://github.com/DanhBNg

---
