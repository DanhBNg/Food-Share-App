/**
 * FIREBASE CONFIGURATION TEMPLATE
 * Sao chép file này thành firebase-config.js
 * Rồi cập nhật giá trị từ Firebase Console
 */

const firebaseConfig = {
    // API Key - Từ Firebase Console → Project Settings → Web API Key
    apiKey: "AIzaSyDHZBRaerI6QgWgTpaLD2EHPGZJXUYeBew",
    
    // Auth Domain - Thường là: your-project-id.firebaseapp.com
    authDomain: "food-share-fce9b.firebaseapp.com",
    
    // Database URL - Optional, cho Realtime Database
    databaseURL: "https://food-share-fce9b-default-rtdb.firebaseio.com",
    
    // Project ID - ID của Firebase project
    projectId: "food-share-fce9b",
    
    // Storage Bucket - Từ Firebase Console → Cloud Storage
    storageBucket: "food-share-fce9b.firebasestorage.app",
    
    // Messaging Sender ID - Từ Firebase Console
    messagingSenderId: "459962607492",
    
    // App ID - Từ Firebase Console → Project Settings
    appId: "1:459962607492:web:8ebd76dbeba4286e9d5fd1",
    
    // Measurement ID - Optional, cho Google Analytics
    measurementId: "G-VTFYZFNRFD"
};

/**
 * ============ HOW TO GET YOUR FIREBASE CONFIG ============
 * 
 * 1. Vào https://console.firebase.google.com
 * 2. Chọn project của bạn
 * 3. Settings (Biểu tượng Gear) → Project Settings
 * 4. Tab "Your apps" → Chọn web app
 * 5. Copy object firebaseConfig (dạng CDN)
 * 6. Dán vào file này
 * 
 * ============ EXAMPLE CONFIG ============
 * const firebaseConfig = {
 *   apiKey: "AIzaSyDHZBRaerI6QgWgTpaLD2EHPGZJXUYeBew",
 *   authDomain: "food-share-fce9b.firebaseapp.com",
 *   projectId: "food-share-fce9b",
 *   storageBucket: "food-share-fce9b.appspot.com",
 *   messagingSenderId: "989820434733",
 *   appId: "1:989820434733:web:2f4e3ab9e39f7b4e5e1c8f"
 * };
 * 
 * ============ SECURITY NOTE ============
 * - KHÔNG đưa API key lên public repositories
 * - API key này có domain restrictions
 * - Chỉ hoạt động từ domain được phép
 * - Luôn sử dụng proper Firebase Security Rules
 */

export default firebaseConfig;
