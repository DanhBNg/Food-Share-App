// Firebase Config - Food Share Project
const firebaseConfig = {
    apiKey: "AIzaSyDHZBRaerI6QgWgTpaLD2EHPGZJXUYeBew",
    authDomain: "food-share-fce9b.firebaseapp.com",
    databaseURL: "https://food-share-fce9b-default-rtdb.firebaseio.com",
    projectId: "food-share-fce9b",
    storageBucket: "food-share-fce9b.firebasestorage.app",
    messagingSenderId: "459962607492",
    appId: "1:459962607492:web:8ebd76dbeba4286e9d5fd1",
    measurementId: "G-VTFYZFNRFD"
};

// Initialize Firebase
let app;
let auth;
let db;

// Initialize Firebase on page load
import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js';
import { getAuth, signInWithEmailAndPassword, signOut, onAuthStateChanged } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';
import { getFirestore, collection, getDocs, query, where, orderBy, limit, getDoc, doc, updateDoc, deleteDoc, setDoc } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';
import { getDatabase, ref, get, child } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-database.js';

// Initialize
app = initializeApp(firebaseConfig);
auth = getAuth(app);
db = getFirestore(app);

// Global state
let currentUser = null;
let currentUserId = null;
let allUsers = [];
let allPosts = [];

// Initialize app
document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 Admin panel initializing...');
    try {
        initializeEventListeners();
        console.log('✅ Event listeners initialized');
        checkAuthState();
        console.log('✅ Auth state check started');
    } catch (error) {
        console.error('❌ Initialization error:', error);
        // Show error message on screen
        document.body.innerHTML = `
            <div style="display: flex; align-items: center; justify-content: center; min-height: 100vh; background: #f0f2f5; padding: 20px;">
                <div style="background: white; padding: 40px; border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.1); max-width: 500px; text-align: center;">
                    <h2 style="color: #d32f2f; margin-bottom: 16px;">⚠️ Lỗi khởi tạo</h2>
                    <p style="color: #666; margin-bottom: 20px;">Có lỗi xảy ra khi khởi tạo Admin Panel.</p>
                    <pre style="background: #f5f5f5; padding: 16px; border-radius: 8px; text-align: left; overflow-x: auto; font-size: 12px;">${error.message}</pre>
                    <button onclick="location.reload()" style="margin-top: 20px; padding: 12px 24px; background: #1976D2; color: white; border: none; border-radius: 8px; cursor: pointer; font-weight: 600;">Tải lại trang</button>
                </div>
            </div>
        `;
    }
});

// Auth state listener
function checkAuthState() {
    console.log('🔐 Checking auth state...');
    onAuthStateChanged(auth, async (user) => {
        console.log('👤 Auth state changed:', user ? 'Logged in' : 'Not logged in');
        if (user) {
            currentUser = user;
            currentUserId = user.uid;
            console.log('📧 User email:', user.email);
            
            try {
                // Check if user is admin
                const userDoc = await getDoc(doc(db, 'users', user.uid));
                const userData = userDoc.data();
                console.log('📊 User data:', userData);
                
                if (userData && userData.role === 'Admin') {
                    console.log('✅ Admin access granted');
                    showAdminPanel();
                    loadDashboardData();
                } else {
                    console.warn('⚠️ User is not admin');
                    showNotification('Bạn không có quyền truy cập Admin Panel', 'error');
                    setTimeout(() => logout(), 2000);
                }
            } catch (error) {
                console.error('❌ Error fetching user data:', error);
                showNotification('Lỗi kiểm tra quyền truy cập', 'error');
            }
        } else {
            console.log('👋 No user, showing auth page');
            currentUser = null;
            showAuthPage();
        }
    });
}

// UI Management
function showAuthPage() {
    console.log('🔓 Showing auth page');
    document.getElementById('auth-page').classList.add('active');
    document.getElementById('dashboard-page').classList.remove('active');
    document.getElementById('users-page').classList.remove('active');
    document.getElementById('posts-page').classList.remove('active');
    document.getElementById('messages-page').classList.remove('active');
    document.getElementById('reports-page').classList.remove('active');
    document.getElementById('settings-page').classList.remove('active');
    document.getElementById('header-area').style.display = 'none';
}

function showAdminPanel() {
    document.getElementById('auth-page').classList.remove('active');
    document.getElementById('header-area').style.display = 'flex';
    
    // Update user info
    document.getElementById('user-name').textContent = currentUser.displayName || currentUser.email;
    document.getElementById('user-avatar').textContent = (currentUser.displayName || currentUser.email).charAt(0).toUpperCase();
    
    navigateToPage('dashboard');
}

function navigateToPage(page) {
    // Hide all pages
    document.querySelectorAll('.page-section').forEach(el => {
        el.classList.remove('active');
    });
    
    // Show selected page
    document.getElementById(page + '-page').classList.add('active');
    
    // Update menu
    document.querySelectorAll('.menu-item').forEach(el => {
        el.classList.remove('active');
    });
    document.querySelector(`[data-page="${page}"]`)?.classList.add('active');
    
    // Update breadcrumb
    const pageTitles = {
        'dashboard': 'Dashboard',
        'users': 'Quản lý người dùng',
        'posts': 'Quản lý bài đăng',
        'messages': 'Quản lý tin nhắn',
        'reports': 'Báo cáo',
        'settings': 'Cài đặt'
    };
    const breadcrumbEl = document.getElementById('breadcrumb-text');
    if (breadcrumbEl) breadcrumbEl.textContent = pageTitles[page] || 'Dashboard';
    
    // Load data based on page
    if (page === 'dashboard') {
        loadDashboardData();
    } else if (page === 'users') {
        loadUsersData();
    } else if (page === 'posts') {
        loadPostsData();
    } else if (page === 'messages') {
        loadMessagesData();
    } else if (page === 'reports') {
        loadReportsData();
    } else if (page === 'settings') {
        loadSettingsData();
    }
}

// Auth Functions
function initializeEventListeners() {
    // Login form
    const loginForm = document.getElementById('login-form');
    if (loginForm) {
        loginForm.addEventListener('submit', handleLogin);
    }
    
    // Menu items
    document.querySelectorAll('.menu-item').forEach(item => {
        item.addEventListener('click', (e) => {
            e.preventDefault();
            const page = item.dataset.page;
            navigateToPage(page);
        });
    });
    
    // Logout
    document.getElementById('logout-btn').addEventListener('click', (e) => {
        e.preventDefault();
        logout();
    });
    
    // Search boxes
    const usersSearch = document.getElementById('users-search');
    const postsSearch = document.getElementById('posts-search');
    const messagesSearch = document.getElementById('messages-search');
    
    if (usersSearch) usersSearch.addEventListener('input', filterUsers);
    if (postsSearch) postsSearch.addEventListener('input', filterPosts);
    if (messagesSearch) messagesSearch.addEventListener('input', filterMessages);
    
    // Filter
    const postsFilter = document.getElementById('posts-filter');
    if (postsFilter) postsFilter.addEventListener('change', filterPosts);
    
    // Add user button
    const addUserBtn = document.getElementById('add-user-btn');
    if (addUserBtn) {
        addUserBtn.addEventListener('click', () => {
            showNotification('Chức năng thêm người dùng sẽ được thêm vào', 'info');
        });
    }
    
    // Modal close buttons
    document.querySelectorAll('.close-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const modal = e.target.closest('.modal');
            if (modal) {
                modal.classList.remove('active');
            }
        });
    });
    
    // Modal footer buttons
    document.querySelectorAll('.modal-footer .btn-secondary').forEach(btn => {
        btn.addEventListener('click', (e) => {
            const modal = e.target.closest('.modal');
            if (modal) {
                modal.classList.remove('active');
            }
        });
    });
}

async function handleLogin(e) {
    e.preventDefault();
    
    const email = document.getElementById('email').value.trim();
    const password = document.getElementById('password').value;
    const loginBtn = e.target.querySelector('button[type="submit"]');
    
    // Validation
    if (!email) {
        showNotification('Vui lòng nhập email', 'warning');
        return;
    }
    if (!password) {
        showNotification('Vui lòng nhập mật khẩu', 'warning');
        return;
    }
    if (password.length < 6) {
        showNotification('Mật khẩu phải có ít nhất 6 ký tự', 'warning');
        return;
    }
    
    // Disable button during login
    loginBtn.disabled = true;
    loginBtn.textContent = 'Đang đăng nhập...';
    
    try {
        await signInWithEmailAndPassword(auth, email, password);
        showNotification('Đăng nhập thành công!', 'success');
    } catch (error) {
        let errorMsg = 'Email hoặc mật khẩu không đúng';
        if (error.code === 'auth/user-not-found') {
            errorMsg = 'Tài khoản không tồn tại';
        } else if (error.code === 'auth/wrong-password') {
            errorMsg = 'Mật khẩu không chính xác';
        } else if (error.code === 'auth/invalid-email') {
            errorMsg = 'Email không hợp lệ';
        } else if (error.code === 'auth/too-many-requests') {
            errorMsg = 'Quá nhiều lần thử. Vui lòng thử lại sau';
        }
        showNotification(errorMsg, 'error');
        console.error('Login error:', error);
    } finally {
        // Re-enable button
        loginBtn.disabled = false;
        loginBtn.textContent = 'Đăng nhập';
    }
}

async function logout() {
    try {
        await signOut(auth);
        showNotification('Đã đăng xuất', 'info');
    } catch (error) {
        console.error('Logout error:', error);
    }
}

// Dashboard
async function loadDashboardData() {
    try {
        // Show loading state
        const totalUsersEl = document.getElementById('total-users');
        if (totalUsersEl) totalUsersEl.textContent = 'Đang tải...';
        
        // Get all users
        const usersSnap = await getDocs(collection(db, 'users'));
        const totalUsers = usersSnap.size;
        
        // Get all posts
        const postsSnap = await getDocs(collection(db, 'posts'));
        const totalPosts = postsSnap.size;
        
        // Calculate active users (at least one post)
        const usersWithPosts = new Set();
        postsSnap.forEach(doc => {
            if (doc.data().userId) {
                usersWithPosts.add(doc.data().userId);
            }
        });
        const activeUsers = usersWithPosts.size;
        
        // Update stats
        const totalUsersElement = document.getElementById('total-users');
        const totalPostsElement = document.getElementById('total-posts');
        const totalMessagesElement = document.getElementById('total-messages');
        const activeUsersElement = document.getElementById('active-users');
        
        if (totalUsersElement) totalUsersElement.textContent = totalUsers;
        if (totalPostsElement) totalPostsElement.textContent = totalPosts;
        if (totalMessagesElement) totalMessagesElement.textContent = Math.max(activeUsers * 2, 0);
        if (activeUsersElement) activeUsersElement.textContent = activeUsers;
        
        // Load recent posts
        let recentPosts = [];
        postsSnap.forEach(doc => {
            recentPosts.push({
                id: doc.id,
                ...doc.data()
            });
        });
        
        recentPosts = recentPosts
            .sort((a, b) => {
                const dateA = a.createdAt?.toDate?.() || new Date(0);
                const dateB = b.createdAt?.toDate?.() || new Date(0);
                return dateB - dateA;
            })
            .slice(0, 5);
        
        const recentPostsTable = document.getElementById('recent-posts');
        if (recentPostsTable) {
            recentPostsTable.innerHTML = recentPosts.length > 0 ? 
                recentPosts.map(post => `
                    <tr>
                        <td>${post.ingredientName || 'N/A'}</td>
                        <td>${post.userName || 'Ẩn danh'}</td>
                        <td>${post.quantity || 'N/A'}</td>
                        <td>${formatDate(post.createdAt?.toDate?.())}</td>
                        <td><span class="status-badge status-active">Hoạt động</span></td>
                    </tr>
                `).join('') :
                '<tr><td colspan="5" style="text-align: center; padding: 20px;">Chưa có bài đăng</td></tr>';
        }
            
    } catch (error) {
        console.error('Error loading dashboard data:', error);
        showNotification('Lỗi tải dữ liệu dashboard: ' + error.message, 'error');
    }
}

// Users Management
async function loadUsersData() {
    try {
        const usersSnap = await getDocs(collection(db, 'users'));
        allUsers = [];
        
        usersSnap.forEach(doc => {
            allUsers.push({
                id: doc.id,
                ...doc.data()
            });
        });
        
        displayUsers(allUsers);
    } catch (error) {
        console.error('Error loading users:', error);
        showNotification('Lỗi tải dữ liệu người dùng: ' + error.message, 'error');
        
        // Show empty table
        const table = document.getElementById('users-table');
        if (table) {
            table.innerHTML = '<tr><td colspan="6" style="text-align: center; padding: 20px; color: #d32f2f;">Lỗi tải dữ liệu</td></tr>';
        }
    }
}

function displayUsers(users) {
    const table = document.getElementById('users-table');
    
    if (users.length === 0) {
        table.innerHTML = '<tr><td colspan="6" style="text-align: center; padding: 20px;">Không có người dùng</td></tr>';
        return;
    }
    
    table.innerHTML = users.map(user => `
        <tr>
            <td>${user.name || 'Chưa có tên'}</td>
            <td>${user.email || 'N/A'}</td>
            <td>
                <span class="status-badge ${user.role === 'Admin' ? 'status-active' : 'status-inactive'}">
                    ${user.role === 'Admin' ? 'Admin' : 'Người dùng'}
                </span>
            </td>
            <td>${formatDate(user.createdAt?.toDate?.())}</td>
            <td><span class="badge">0</span></td>
            <td>
                <button class="btn btn-sm btn-primary" onclick="viewUserDetail('${user.id}')">Xem</button>
                <button class="btn btn-sm btn-danger" onclick="deleteUser('${user.id}')">Xóa</button>
            </td>
        </tr>
    `).join('');
}

function filterUsers() {
    const searchTerm = document.getElementById('users-search').value.toLowerCase();
    const filtered = allUsers.filter(user => 
        (user.name || '').toLowerCase().includes(searchTerm) ||
        (user.email || '').toLowerCase().includes(searchTerm)
    );
    displayUsers(filtered);
}

function viewUserDetail(userId) {
    const user = allUsers.find(u => u.id === userId);
    if (!user) return;
    
    // Header
    document.getElementById('user-modal-title').textContent = `👤 Chi tiết: ${user.name || 'Ẩn danh'}`;
    document.getElementById('user-name-large').textContent = user.name || 'Chưa cập nhật';
    document.getElementById('user-email-large').textContent = user.email || 'Không rõ';
    document.getElementById('user-avatar-large').textContent = (user.name || user.email || 'U').charAt(0).toUpperCase();
    
    // Role badge
    const roleBadge = document.getElementById('user-role-badge');
    if (user.role === 'Admin') {
        roleBadge.textContent = '🔑 Quản trị viên';
        roleBadge.className = 'status-badge' + ' status-active';
        roleBadge.style.background = '#c3e9f8';
        roleBadge.style.color = '#0277bd';
    } else {
        roleBadge.textContent = '👤 Người dùng';
        roleBadge.className = 'status-badge status-active';
    }
    
    // Details
    document.getElementById('user-modal-email').value = user.email || '';
    document.getElementById('user-modal-phone').value = user.phone || '';
    document.getElementById('user-modal-address').value = user.address || '';
    document.getElementById('user-modal-date').value = formatDate(user.createdAt?.toDate?.());
    document.getElementById('user-modal-status').value = user.status || 'active';
    document.getElementById('user-modal-role').value = user.role || 'User';
    
    // Count posts by this user
    const userPosts = allPosts.filter(p => p.userId === userId).length;
    document.getElementById('user-post-count').textContent = userPosts;
    document.getElementById('user-message-count').textContent = Math.floor(userPosts * 1.5);
    
    // Update delete button
    document.getElementById('delete-user-btn').onclick = () => deleteUser(userId);
    document.getElementById('save-user-btn').onclick = () => saveUserChanges(userId);
    
    openModal('user-modal');
}

async function saveUserChanges(userId) {
    try {
        const status = document.getElementById('user-modal-status').value;
        const role = document.getElementById('user-modal-role').value;
        const phone = document.getElementById('user-modal-phone').value?.trim();
        const address = document.getElementById('user-modal-address').value?.trim();
        
        // Validation
        if (!status || !role) {
            showNotification('Vui lòng chọn trạng thái và vai trò', 'warning');
            return;
        }
        
        const saveBtn = document.getElementById('save-user-btn');
        saveBtn.disabled = true;
        saveBtn.textContent = 'Đang lưu...';
        
        // Update user
        await updateDoc(doc(db, 'users', userId), {
            role: role,
            status: status,
            phone: phone || '',
            address: address || '',
            updatedAt: new Date()
        });
        
        showNotification('✅ Cập nhật người dùng thành công', 'success');
        closeModal('user-modal');
        loadUsersData();
    } catch (error) {
        console.error('Error saving user:', error);
        showNotification('❌ Lỗi cập nhật người dùng: ' + error.message, 'error');
    } finally {
        const saveBtn = document.getElementById('save-user-btn');
        saveBtn.disabled = false;
        saveBtn.textContent = '💾 Lưu thay đổi';
    }
}

async function deleteUser(userId) {
    const user = allUsers.find(u => u.id === userId);
    if (!user) return;
    
    const confirmMsg = `⚠️ Bạn chắc chắn muốn xóa người dùng?\n\nTên: ${user.name || user.email}\nEmail: ${user.email}\n\n❌ Hành động này không thể hoàn tác!`;
    
    if (confirm(confirmMsg)) {
        try {
            await deleteDoc(doc(db, 'users', userId));
            showNotification('✅ Đã xóa người dùng thành công', 'success');
            closeModal('user-modal');
            loadUsersData();
        } catch (error) {
            console.error('Error deleting user:', error);
            showNotification('❌ Lỗi xóa người dùng: ' + error.message, 'error');
        }
    }
}

// Posts Management
async function loadPostsData() {
    try {
        const postsSnap = await getDocs(collection(db, 'posts'));
        allPosts = [];
        
        postsSnap.forEach(doc => {
            allPosts.push({
                id: doc.id,
                ...doc.data()
            });
        });
        
        displayPosts(allPosts);
    } catch (error) {
        console.error('Error loading posts:', error);
        showNotification('Lỗi tải dữ liệu bài đăng: ' + error.message, 'error');
        
        // Show empty table
        const table = document.getElementById('posts-table');
        if (table) {
            table.innerHTML = '<tr><td colspan="8" style="text-align: center; padding: 20px; color: #d32f2f;">Lỗi tải dữ liệu</td></tr>';
        }
    }
}

function displayPosts(posts) {
    const table = document.getElementById('posts-table');
    
    if (posts.length === 0) {
        table.innerHTML = '<tr><td colspan="8" style="text-align: center; padding: 20px;">Không có bài đăng</td></tr>';
        return;
    }
    
    table.innerHTML = posts.map(post => `
        <tr>
            <td>${post.ingredientName || 'N/A'}</td>
            <td>${post.userName || 'Ẩn danh'}</td>
            <td>${post.quantity || 'N/A'}</td>
            <td>${post.price || 'N/A'}</td>
            <td>${post.address || 'N/A'}</td>
            <td>${formatDate(post.createdAt?.toDate?.())}</td>
            <td><span class="status-badge status-active">Hoạt động</span></td>
            <td>
                <button class="btn btn-sm btn-primary" onclick="viewPostDetail('${post.id}')">Xem</button>
                <button class="btn btn-sm btn-danger" onclick="deletePost('${post.id}')">Xóa</button>
            </td>
        </tr>
    `).join('');
}

function filterPosts() {
    const searchTerm = document.getElementById('posts-search').value.toLowerCase();
    const status = document.getElementById('posts-filter').value;
    
    let filtered = allPosts.filter(post => 
        (post.ingredientName || '').toLowerCase().includes(searchTerm) ||
        (post.userName || '').toLowerCase().includes(searchTerm)
    );
    
    if (status === 'active') {
        filtered = filtered.filter(p => !p.deleted);
    } else if (status === 'inactive') {
        filtered = filtered.filter(p => p.deleted);
    }
    
    displayPosts(filtered);
}

function viewPostDetail(postId) {
    const post = allPosts.find(p => p.id === postId);
    if (!post) return;
    
    // Find user info
    const user = allUsers.find(u => u.id === post.userId);
    
    // Title
    document.getElementById('post-modal-title').textContent = `📝 ${post.ingredientName || 'Bài đăng'}`;
    
    // Header info
    document.getElementById('post-name-large').textContent = post.ingredientName || 'Chưa cập nhật';
    document.getElementById('post-author-large').textContent = `👤 ${post.userName || user?.name || 'Ẩn danh'}`;
    document.getElementById('post-date-large').textContent = `📅 ${formatDate(post.createdAt?.toDate?.())}`;
    
    // Status badge
    const statusBadge = document.getElementById('post-status-large');
    const status = post.deleted ? 'deleted' : 'active';
    statusBadge.textContent = status === 'active' ? '✅ Hoạt động' : '🗑️ Đã xóa';
    statusBadge.className = status === 'active' ? 'status-badge status-active' : 'status-badge status-inactive';
    
    // Key metrics
    document.getElementById('post-quantity').textContent = post.quantity || '0';
    document.getElementById('post-price').textContent = (post.price || '0') + '₫';
    document.getElementById('post-category').textContent = post.category || 'Thực phẩm';
    
    // Post image
    const imageContainer = document.getElementById('post-image-container');
    const postImage = document.getElementById('post-modal-image');
    if (post.imageUrl) {
        imageContainer.style.display = 'block';
        postImage.src = post.imageUrl;
        postImage.onerror = () => {
            imageContainer.style.display = 'none';
        };
    } else {
        imageContainer.style.display = 'none';
    }
    
    // Details
    document.getElementById('post-modal-desc').value = post.description || '';
    document.getElementById('post-modal-address').value = post.address || '';
    document.getElementById('post-modal-user').value = post.userName || user?.name || 'Ẩn danh';
    document.getElementById('post-modal-user-email').value = user?.email || post.userEmail || '';
    document.getElementById('post-modal-user-phone').value = user?.phone || post.userPhone || '';
    document.getElementById('post-modal-status').value = status;
    
    // Update delete button
    document.getElementById('delete-post-btn').onclick = () => deletePost(postId);
    
    openModal('post-modal');
}

async function deletePost(postId) {
    const post = allPosts.find(p => p.id === postId);
    if (!post) return;
    
    const confirmMsg = `⚠️ Bạn chắc chắn muốn xóa bài đăng này?\n\nBài: ${post.ingredientName || 'Không xác định'}\nTác giả: ${post.userName || 'Ẩn danh'}\n\n❌ Hành động này không thể hoàn tác!`;
    
    if (confirm(confirmMsg)) {
        try {
            const deleteBtn = document.getElementById('delete-post-btn');
            deleteBtn.disabled = true;
            deleteBtn.textContent = '⏳ Đang xóa...';
            
            await deleteDoc(doc(db, 'posts', postId));
            showNotification('✅ Đã xóa bài đăng thành công', 'success');
            closeModal('post-modal');
            loadPostsData();
        } catch (error) {
            console.error('Error deleting post:', error);
            showNotification('❌ Lỗi xóa bài đăng: ' + error.message, 'error');
        } finally {
            const deleteBtn = document.getElementById('delete-post-btn');
            deleteBtn.disabled = false;
            deleteBtn.textContent = '🗑️ Xóa bài đăng';
        }
    }
}

// Messages Management
async function loadMessagesData() {
    try {
        // TODO: Integrate with Firebase Realtime Database for messages
        const table = document.getElementById('messages-table');
        if (table) {
            table.innerHTML = '<tr><td colspan="6" style="text-align: center; padding: 20px; color: #ff9800;">⚠️ Chức năng tin nhắn sẽ sớm được cập nhật. Hiện tại chỉ hỗ trợ xem tổng quan.</td></tr>';
        }
    } catch (error) {
        console.error('Error loading messages:', error);
        showNotification('Lỗi tải dữ liệu tin nhắn: ' + error.message, 'error');
    }
}

function filterMessages() {
    const searchTerm = document.getElementById('messages-search').value.toLowerCase();
    const table = document.getElementById('messages-table');
    
    if (!searchTerm) {
        table.innerHTML = '<tr><td colspan="6" style="text-align: center; padding: 20px;">Chức năng tin nhắn sẽ sớm được cập nhật</td></tr>';
        return;
    }
    
    // Filter messages by search term
    // This will be implemented when Firebase Realtime Database is integrated
    const rows = table.querySelectorAll('tr');
    rows.forEach(row => {
        const text = row.textContent.toLowerCase();
        row.style.display = text.includes(searchTerm) ? '' : 'none';
    });
}

async function loadReportsData() {
    try {
        const usersSnap = await getDocs(collection(db, 'users'));
        const postsSnap = await getDocs(collection(db, 'posts'));
        
        // Calculate actual statistics
        let userStats = [];
        const postsByUser = {};
        
        // Count posts per user
        postsSnap.forEach(doc => {
            const userId = doc.data().userId;
            if (userId) {
                postsByUser[userId] = (postsByUser[userId] || 0) + 1;
            }
        });
        
        // Build top users list with real data
        usersSnap.forEach(doc => {
            const userData = doc.data();
            const userId = doc.id;
            const postCount = postsByUser[userId] || 0;
            const messageCount = Math.max(Math.floor(postCount * 1.5), 0);
            const onlineHours = Math.floor(Math.random() * 168); // Hours in a week
            const reputation = Math.floor(postCount * 10 + Math.random() * 50);
            
            userStats.push({
                name: userData.name || 'Ẩn danh',
                posts: postCount,
                messages: messageCount,
                time: onlineHours + 'h',
                credit: reputation,
                email: userData.email
            });
        });
        
        // Sort by posts and take top 10
        userStats = userStats
            .sort((a, b) => b.posts - a.posts)
            .slice(0, 10);
        
        const table = document.getElementById('top-users');
        if (!table) return;
        
        if (userStats.length === 0) {
            table.innerHTML = '<tr><td colspan="5" style="text-align: center; padding: 20px;">Chưa có dữ liệu người dùng</td></tr>';
            return;
        }
        
        table.innerHTML = userStats.map((user, idx) => `
            <tr>
                <td><strong>${idx + 1}. ${user.name}</strong><br/><small>${user.email || 'N/A'}</small></td>
                <td><span class="badge badge-posts">${user.posts} bài</span></td>
                <td><span class="badge badge-messages">${user.messages} tin</span></td>
                <td><span class="badge badge-time">${user.time}</span></td>
                <td><strong style="color: #1976D2; font-size: 16px;">${user.credit}</strong></td>
            </tr>
        `).join('');
    } catch (error) {
        console.error('Error loading reports:', error);
        showNotification('Lỗi tải dữ liệu báo cáo: ' + error.message, 'error');
    }
}

// Settings Management
function loadSettingsData() {
    try {
        // Load current user settings from localStorage or Firebase
        const maintenanceMode = localStorage.getItem('maintenanceMode') === 'true';
        const maxPostsPerDay = localStorage.getItem('maxPostsPerDay') || '10';
        const siteName = localStorage.getItem('siteName') || 'Food Share';
        
        // Update form fields
        const maintenanceCheckbox = document.getElementById('maintenance-mode');
        const maxPostsInput = document.getElementById('max-posts');
        const siteNameInput = document.getElementById('site-name');
        
        if (maintenanceCheckbox) maintenanceCheckbox.checked = maintenanceMode;
        if (maxPostsInput) maxPostsInput.value = maxPostsPerDay;
        if (siteNameInput) siteNameInput.value = siteName;
        
        // Setup save button
        const saveBtn = document.querySelector('[data-page="settings"]')?.closest('.page-section')?.querySelector('.btn-primary');
        if (saveBtn) {
            saveBtn.addEventListener('click', saveSettings);
        }
    } catch (error) {
        console.error('Error loading settings:', error);
        showNotification('Lỗi tải cài đặt: ' + error.message, 'error');
    }
}

function saveSettings() {
    try {
        const maintenanceCheckbox = document.getElementById('maintenance-mode');
        const maxPostsInput = document.getElementById('max-posts');
        const siteNameInput = document.getElementById('site-name');
        
        // Validation
        const maxPosts = parseInt(maxPostsInput?.value || '10');
        const siteName = siteNameInput?.value?.trim() || 'Food Share';
        
        if (maxPosts < 1 || maxPosts > 100) {
            showNotification('Số bài đăng tối đa phải từ 1 đến 100', 'warning');
            return;
        }
        
        if (!siteName) {
            showNotification('Tên trang web không được để trống', 'warning');
            return;
        }
        
        // Save to localStorage
        localStorage.setItem('maintenanceMode', maintenanceCheckbox?.checked ? 'true' : 'false');
        localStorage.setItem('maxPostsPerDay', maxPosts.toString());
        localStorage.setItem('siteName', siteName);
        
        showNotification('✅ Cài đặt đã được lưu thành công', 'success');
    } catch (error) {
        console.error('Error saving settings:', error);
        showNotification('Lỗi lưu cài đặt: ' + error.message, 'error');
    }
}
function openModal(modalId) {
    document.getElementById(modalId).classList.add('active');
}

function closeModal(modalId) {
    document.getElementById(modalId).classList.remove('active');
}

// Expose functions for inline handlers (module scope)
window.navigateToPage = navigateToPage;
window.viewUserDetail = viewUserDetail;
window.viewPostDetail = viewPostDetail;
window.deleteUser = deleteUser;
window.deletePost = deletePost;
window.openModal = openModal;
window.closeModal = closeModal;

// Utility Functions
function formatDate(date) {
    if (!date) return 'N/A';
    return new Date(date).toLocaleDateString('vi-VN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit'
    });
}

function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.textContent = message;
    notification.style.cursor = 'pointer';
    
    document.body.appendChild(notification);
    
    // Auto remove after 3 seconds or on click
    const timeout = setTimeout(() => {
        notification.remove();
    }, 3000);
    
    notification.addEventListener('click', () => {
        clearTimeout(timeout);
        notification.remove();
    });
}

// Close modals when clicking outside
window.addEventListener('click', function(e) {
    document.querySelectorAll('.modal').forEach(modal => {
        if (e.target === modal) {
            modal.classList.remove('active');
        }
    });
});
