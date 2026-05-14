// api.js
const BASE_URL = 'http://localhost:5000/api'; // change to your server URL when deployed

// SIGN UP
async function register(email, password, role, fullName) {
  const res = await fetch(`${BASE_URL}/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password, role, full_name: fullName })
  });
  return res.json();
}

// SIGN IN
async function login(email, password) {
  const res = await fetch(`${BASE_URL}/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password })
  });
  const data = await res.json();
  if (data.token) {
    localStorage.setItem('token', data.token);
    localStorage.setItem('user', JSON.stringify(data.user));
  }
  return data;
}

// GET ALL MENTORS
async function getMentors() {
  const res = await fetch(`${BASE_URL}/mentors`);
  return res.json();
}

// BOOK A SESSION
async function bookSession(mentorId, menteeId, date, time) {
  const res = await fetch(`${BASE_URL}/sessions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${localStorage.getItem('token')}`
    },
    body: JSON.stringify({ mentor_id: mentorId, mentee_id: menteeId, date, time })
  });
  return res.json();
}

// LOGOUT
function logout() {
  localStorage.removeItem('token');
  localStorage.removeItem('user');
  window.location.href = 'index.html';
}