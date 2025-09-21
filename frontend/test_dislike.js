// Test script สำหรับทดสอบ Dislike API
// รัน: node test_dislike.js

const axios = require('axios');

const BASE_URL = 'http://localhost:8000/api/v1';

// ใส่ token ที่ได้จาก login
const ACCESS_TOKEN = 'YOUR_ACCESS_TOKEN_HERE';

const api = axios.create({
  baseURL: BASE_URL,
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${ACCESS_TOKEN}`
  }
});

async function testDislikeAPI() {
  console.log('🧪 Testing Dislike API...\n');

  try {
    // Test 1: Get all menus first
    console.log('1️⃣ Getting menus list...');
    const menusResponse = await api.get('/menus?limit=1');
    console.log('✅ Menus response:', menusResponse.status);

    if (!menusResponse.data || !menusResponse.data.length) {
      console.log('❌ No menus found');
      return;
    }

    const testMenuId = menusResponse.data[0].id;
    console.log(`📝 Using menu ID: ${testMenuId}\n`);

    // Test 2: Add dislike
    console.log('2️⃣ Adding dislike...');
    const addDislikeResponse = await api.post('/user-profiles/me/dislikes', {
      menu_id: testMenuId,
      reason: 'Test dislike from script'
    });
    console.log('✅ Add dislike response:', addDislikeResponse.status);
    console.log('📄 Response data:', JSON.stringify(addDislikeResponse.data, null, 2));

    // Test 3: Get user dislikes
    console.log('\n3️⃣ Getting user dislikes...');
    const dislikesResponse = await api.get('/user-profiles/me/dislikes?language=th');
    console.log('✅ Get dislikes response:', dislikesResponse.status);
    console.log('📄 Dislikes count:', dislikesResponse.data.length);

    // Test 4: Try to add same dislike (should fail)
    console.log('\n4️⃣ Testing duplicate dislike...');
    try {
      await api.post('/user-profiles/me/dislikes', {
        menu_id: testMenuId,
        reason: 'Duplicate test'
      });
      console.log('❌ Duplicate dislike should have failed');
    } catch (error) {
      if (error.response?.status === 409) {
        console.log('✅ Duplicate dislike correctly rejected (409)');
      } else {
        console.log('❌ Unexpected error:', error.response?.status);
      }
    }

    // Test 5: Remove dislike
    console.log('\n5️⃣ Removing dislike...');
    const removeResponse = await api.delete('/user-profiles/me/dislikes', {
      data: { menu_id: testMenuId }
    });
    console.log('✅ Remove dislike response:', removeResponse.status);

    console.log('\n🎉 All tests completed successfully!');

  } catch (error) {
    console.error('❌ Test failed:');
    console.error('Status:', error.response?.status);
    console.error('Message:', error.response?.data?.message || error.message);
    console.error('Data:', error.response?.data);
  }
}

// Test authentication first
async function testAuth() {
  console.log('🔐 Testing authentication...\n');

  try {
    const response = await api.get('/user-profiles/me');
    console.log('✅ Authentication successful');
    console.log('👤 User:', response.data.email);
    return true;
  } catch (error) {
    console.error('❌ Authentication failed:');
    console.error('Status:', error.response?.status);
    console.error('Message:', error.response?.data?.message || error.message);
    return false;
  }
}

async function main() {
  console.log('🚀 Starting Dislike API Tests\n');

  if (ACCESS_TOKEN === 'YOUR_ACCESS_TOKEN_HERE') {
    console.log('❌ Please set ACCESS_TOKEN in the script');
    console.log('💡 Get token from:');
    console.log('   1. Login via frontend > DevTools > Application > Local Storage');
    console.log('   2. Or use POST /auth/login API');
    return;
  }

  const authSuccess = await testAuth();
  if (!authSuccess) {
    console.log('\n💡 Fix authentication first before testing dislike');
    return;
  }

  console.log('\n' + '='.repeat(50));
  await testDislikeAPI();
}

main();