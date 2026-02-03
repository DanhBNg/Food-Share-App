# 📚 Food Share Admin Panel - API Reference

## Firebase SDK Methods Used

### Authentication (Firebase Auth)

#### 1. Sign In with Email & Password
```javascript
import { signInWithEmailAndPassword } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';

// Usage
await signInWithEmailAndPassword(auth, email, password);

// Returns: UserCredential
// {
//   user: {
//     uid: "user-id",
//     email: "user@example.com",
//     displayName: "User Name",
//     photoURL: "url",
//     emailVerified: boolean,
//     isAnonymous: boolean,
//     metadata: {...},
//     providerData: [...]
//   }
// }

// Errors
// - FirebaseError (auth/user-not-found)
// - FirebaseError (auth/wrong-password)
// - FirebaseError (auth/invalid-email)
```

#### 2. Sign Out
```javascript
import { signOut } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';

await signOut(auth);

// No return value
// Clears authentication state
```

#### 3. Auth State Listener
```javascript
import { onAuthStateChanged } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';

onAuthStateChanged(auth, (user) => {
    if (user) {
        // User is signed in
        currentUser = user;
    } else {
        // User is signed out
        currentUser = null;
    }
});

// Returns: unsubscribe function
// Call to stop listening: unsubscribe()
```

---

### Firestore Database

#### Collections & Structure

**users collection:**
```json
{
  "userId": {
    "name": "Nguyễn Văn A",
    "email": "user@example.com",
    "phone": "0123456789",
    "address": "123 Đường ABC, Hà Nội",
    "role": "Người dùng|Admin",
    "photo": "https://...",
    "createdAt": Timestamp,
    "updatedAt": Timestamp
  }
}
```

**posts collection:**
```json
{
  "postId": {
    "userId": "user-id",
    "userName": "Nguyễn Văn A",
    "ingredientName": "Rau cải",
    "ingredientNameLower": "rau cải",
    "quantity": "10 kg",
    "price": "50000",
    "productUrl": "https://example.com",
    "address": "Hà Nội",
    "description": "Rau sạch không hóa chất...",
    "imageUrl": "https://...",
    "createdAt": Timestamp
  }
}
```

#### Read Methods

##### Get All Documents from Collection
```javascript
import { getDocs, collection } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

const querySnapshot = await getDocs(collection(db, 'users'));

// Returns: QuerySnapshot
// {
//   docs: [QueryDocumentSnapshot, ...],
//   size: number,
//   empty: boolean
// }

// Iterate through results:
querySnapshot.forEach(doc => {
    console.log(doc.id, doc.data());
});

// Convert to array:
const users = querySnapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
}));
```

##### Get Document by ID
```javascript
import { getDoc, doc } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

const docSnapshot = await getDoc(doc(db, 'users', userId));

// Returns: DocumentSnapshot
// {
//   id: "document-id",
//   exists(): boolean,
//   data(): object | undefined,
//   ref: DocumentReference
// }

if (docSnapshot.exists()) {
    console.log('Document data:', docSnapshot.data());
} else {
    console.log('Document does not exist');
}
```

##### Query with Filters
```javascript
import { query, where, getDocs } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

const q = query(
    collection(db, 'posts'),
    where('userId', '==', userId),
    where('createdAt', '<=', date)
);

const querySnapshot = await getDocs(q);
```

##### Sort Results
```javascript
import { query, orderBy, getDocs } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

const q = query(
    collection(db, 'posts'),
    orderBy('createdAt', 'desc')
);

const querySnapshot = await getDocs(q);

// 'asc' = ascending
// 'desc' = descending
```

##### Limit Results
```javascript
import { query, limit, getDocs } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

const q = query(
    collection(db, 'posts'),
    limit(10) // Get only first 10 documents
);

const querySnapshot = await getDocs(q);
```

#### Write Methods

##### Create Document
```javascript
import { setDoc, doc } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

await setDoc(doc(db, 'users', userId), {
    name: 'Nguyễn Văn A',
    email: 'user@example.com',
    role: 'Người dùng',
    createdAt: new Date()
});

// With merge option (don't overwrite):
await setDoc(doc(db, 'users', userId), {
    role: 'Admin'
}, { merge: true });
```

##### Update Document
```javascript
import { updateDoc, doc } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

await updateDoc(doc(db, 'users', userId), {
    role: 'Admin',
    updatedAt: new Date()
});

// Update nested field:
await updateDoc(doc(db, 'posts', postId), {
    'metadata.views': increment(1)
});
```

##### Delete Document
```javascript
import { deleteDoc, doc } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

await deleteDoc(doc(db, 'posts', postId));

// No return value
// Document is permanently deleted
```

#### Real-time Listeners

##### Listen to Collection Changes
```javascript
import { collection, onSnapshot } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

const unsubscribe = onSnapshot(
    collection(db, 'posts'),
    (querySnapshot) => {
        const posts = [];
        querySnapshot.forEach(doc => {
            posts.push({
                id: doc.id,
                ...doc.data()
            });
        });
        // Update UI with posts
    },
    (error) => {
        console.error('Error listening to posts:', error);
    }
);

// Stop listening:
unsubscribe();
```

##### Listen to Single Document
```javascript
import { doc, onSnapshot } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

const unsubscribe = onSnapshot(
    doc(db, 'users', userId),
    (doc) => {
        if (doc.exists()) {
            console.log('User data:', doc.data());
        }
    }
);
```

---

## Admin Panel API

### Authentication Functions

#### Login
```javascript
async function handleLogin(email, password) {
    try {
        await signInWithEmailAndPassword(auth, email, password);
        // User object will be set via onAuthStateChanged
    } catch (error) {
        // Handle error
    }
}
```

#### Logout
```javascript
async function logout() {
    try {
        await signOut(auth);
        showAuthPage();
    } catch (error) {
        console.error('Logout error:', error);
    }
}
```

#### Check Auth State
```javascript
onAuthStateChanged(auth, async (user) => {
    if (user) {
        // Verify admin role
        const userDoc = await getDoc(doc(db, 'users', user.uid));
        if (userDoc.data().role === 'Admin') {
            showAdminPanel();
        } else {
            // Not admin - deny access
        }
    } else {
        // Not logged in
        showAuthPage();
    }
});
```

---

### Data Management Functions

#### Load Users
```javascript
async function loadUsersData() {
    const usersSnap = await getDocs(collection(db, 'users'));
    const users = usersSnap.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
    }));
    return users;
}
```

#### Load Posts
```javascript
async function loadPostsData() {
    const postsSnap = await getDocs(collection(db, 'posts'));
    const posts = postsSnap.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
    }));
    // Sort by createdAt (client-side)
    return posts.sort((a, b) => 
        b.createdAt.toDate() - a.createdAt.toDate()
    );
}
```

#### Update User
```javascript
async function updateUser(userId, updates) {
    try {
        await updateDoc(doc(db, 'users', userId), updates);
        showNotification('User updated', 'success');
    } catch (error) {
        showNotification('Error updating user', 'error');
    }
}
```

#### Delete User
```javascript
async function deleteUser(userId) {
    try {
        await deleteDoc(doc(db, 'users', userId));
        showNotification('User deleted', 'success');
    } catch (error) {
        showNotification('Error deleting user', 'error');
    }
}
```

#### Delete Post
```javascript
async function deletePost(postId) {
    try {
        await deleteDoc(doc(db, 'posts', postId));
        showNotification('Post deleted', 'success');
    } catch (error) {
        showNotification('Error deleting post', 'error');
    }
}
```

---

### UI Management Functions

#### Navigate to Page
```javascript
function navigateToPage(pageName) {
    // Hide all pages
    document.querySelectorAll('.page-section').forEach(el => {
        el.classList.remove('active');
    });
    
    // Show selected page
    document.getElementById(pageName + '-page').classList.add('active');
    
    // Update menu
    document.querySelectorAll('.menu-item').forEach(el => {
        el.classList.remove('active');
    });
    document.querySelector(`[data-page="${pageName}"]`).classList.add('active');
    
    // Load page data
    loadPageData(pageName);
}
```

#### Search/Filter
```javascript
function filterUsers(searchTerm) {
    return allUsers.filter(user => 
        (user.name || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
        (user.email || '').toLowerCase().includes(searchTerm.toLowerCase())
    );
}

function filterPosts(searchTerm, status) {
    return allPosts.filter(post => {
        const matchesSearch = (post.ingredientName || '')
            .toLowerCase()
            .includes(searchTerm.toLowerCase());
        
        const matchesStatus = !status || 
            (status === 'active' && !post.deleted) ||
            (status === 'inactive' && post.deleted);
        
        return matchesSearch && matchesStatus;
    });
}
```

#### Open/Close Modal
```javascript
function openModal(modalId) {
    document.getElementById(modalId).classList.add('active');
}

function closeModal(modalId) {
    document.getElementById(modalId).classList.remove('active');
}
```

#### Show Notification
```javascript
function showNotification(message, type = 'info') {
    // type: 'success', 'error', 'warning', 'info'
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.textContent = message;
    document.body.appendChild(notification);
    
    setTimeout(() => notification.remove(), 3000);
}
```

---

## Error Handling

### Firebase Auth Errors
```javascript
try {
    await signInWithEmailAndPassword(auth, email, password);
} catch (error) {
    switch (error.code) {
        case 'auth/user-not-found':
            showNotification('User not found', 'error');
            break;
        case 'auth/wrong-password':
            showNotification('Incorrect password', 'error');
            break;
        case 'auth/invalid-email':
            showNotification('Invalid email', 'error');
            break;
        default:
            showNotification(error.message, 'error');
    }
}
```

### Firestore Errors
```javascript
try {
    const doc = await getDoc(doc(db, 'users', userId));
} catch (error) {
    if (error.code === 'permission-denied') {
        showNotification('Permission denied', 'error');
    } else if (error.code === 'not-found') {
        showNotification('Document not found', 'error');
    } else {
        showNotification('Error loading data: ' + error.message, 'error');
    }
}
```

---

## Common Query Patterns

### Get User Posts
```javascript
const q = query(
    collection(db, 'posts'),
    where('userId', '==', currentUser.uid)
);
const posts = await getDocs(q);
```

### Get Recent Posts
```javascript
const oneWeekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
const q = query(
    collection(db, 'posts'),
    where('createdAt', '>=', oneWeekAgo),
    orderBy('createdAt', 'desc'),
    limit(10)
);
const posts = await getDocs(q);
```

### Get Active Users
```javascript
const q = query(
    collection(db, 'users'),
    where('role', '!=', 'Banned'),
    orderBy('role')
);
const users = await getDocs(q);
```

### Aggregation (Client-side)
```javascript
const posts = await getDocs(collection(db, 'posts'));
const totalPosts = posts.size;
const avgPostsPerUser = totalPosts / (await getDocs(collection(db, 'users'))).size;
const recentPosts = posts.docs
    .map(doc => doc.data())
    .filter(p => p.createdAt.toDate() > oneWeekAgo)
    .length;
```

---

## Performance Tips

1. **Use appropriate queries:**
   ```javascript
   // ❌ Bad: Get all, filter client-side
   const all = await getDocs(collection(db, 'posts'));
   const filtered = all.docs.filter(doc => doc.data().userId === userId);
   
   // ✅ Good: Filter in query
   const q = query(collection(db, 'posts'), where('userId', '==', userId));
   const filtered = await getDocs(q);
   ```

2. **Limit results:**
   ```javascript
   const q = query(collection(db, 'posts'), limit(20));
   ```

3. **Use indexes for complex queries:**
   - Firestore automatically suggests indexes
   - Create composite indexes in Firebase Console

4. **Paginate large datasets:**
   ```javascript
   // Not implemented yet, but use startAfter() for pagination
   const lastDoc = docs[docs.length - 1];
   const nextPage = query(
       collection(db, 'posts'),
       startAfter(lastDoc),
       limit(20)
   );
   ```

5. **Cache data locally:**
   ```javascript
   // Store in JavaScript variables/state
   let cachedUsers = [];
   let cacheTimestamp = Date.now();
   const CACHE_DURATION = 5 * 60 * 1000; // 5 minutes
   
   async function getUsersWithCache() {
       if (Date.now() - cacheTimestamp < CACHE_DURATION) {
           return cachedUsers;
       }
       cachedUsers = await loadUsersData();
       cacheTimestamp = Date.now();
       return cachedUsers;
   }
   ```

---

## Firestore Limits & Quotas

| Metric | Limit |
|--------|-------|
| Max read ops/sec | Unlimited (pay per read) |
| Max write ops/sec | Unlimited (pay per write) |
| Max document size | 1 MB |
| Max collection size | Unlimited |
| Max indexes | 200 |
| Max compound indexes | 200 |
| Max subcollection depth | No limit |

---

**API Reference Version:** 1.0.0  
**Last Updated:** 2024-02-03  
**Firebase SDK:** v10.7.0
