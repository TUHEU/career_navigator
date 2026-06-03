const BASE_URL = 'http://localhost:5000'; 


function getToken() {
  return localStorage.getItem('access_token');
}

function getUser() {
  const user = localStorage.getItem('user');
  return user ? JSON.parse(user) : null;
}

function isLoggedIn() {
  return !!getToken();
}

function requireAuth() {
  if (!isLoggedIn()) window.location.href = 'auth.html';
}

function authHeaders() {
  return {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${getToken()}`
  };
}

function publicHeaders() {
  return { 'Content-Type': 'application/json' };
}

async function refreshAccessToken() {
  const refresh = localStorage.getItem('refresh_token');
  if (!refresh) { logout(); return false; }
  try {
    const res = await fetch(`${BASE_URL}/auth/refresh`, {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${refresh}` }
    });
    const data = await res.json();
    if (res.ok && data.access_token) {
      localStorage.setItem('access_token', data.access_token);
      return true;
    }
    logout(); return false;
  } catch {
    logout(); return false;
  }
}

async function apiFetch(url, options = {}) {
  let res = await fetch(url, options);
  if (res.status === 401) {
    const refreshed = await refreshAccessToken();
    if (refreshed) {
      options.headers['Authorization'] = `Bearer ${getToken()}`;
      res = await fetch(url, options);
    }
  }
  return res;
}

// ── AUTH ──────────────────────────────────────────────────

async function register(fullName, email, password, role) {
  try {
    const res = await fetch(`${BASE_URL}/auth/register`, {
      method: 'POST',
      headers: publicHeaders(),
      body: JSON.stringify({ full_name: fullName, email, password, role })
    });
    const data = await res.json();
    return { ok: res.ok, data };
  } catch {
    return { ok: false, data: { error: 'Could not connect to server.' } };
  }
}

async function verifyEmail(email, code) {
  try {
    const res = await fetch(`${BASE_URL}/auth/verify-email`, {
      method: 'POST',
      headers: publicHeaders(),
      body: JSON.stringify({ email, code })
    });
    const data = await res.json();
    return { ok: res.ok, data };
  } catch {
    return { ok: false, data: { error: 'Could not connect to server.' } };
  }
}

async function resendCode(email) {
  try {
    const res = await fetch(`${BASE_URL}/auth/resend-code`, {
      method: 'POST',
      headers: publicHeaders(),
      body: JSON.stringify({ email })
    });
    const data = await res.json();
    return { ok: res.ok, data };
  } catch {
    return { ok: false, data: { error: 'Could not connect to server.' } };
  }
}

async function login(email, password) {
  try {
    const res = await fetch(`${BASE_URL}/auth/login`, {
      method: 'POST',
      headers: publicHeaders(),
      body: JSON.stringify({ email, password })
    });
    const data = await res.json();
    if (res.ok) {
      localStorage.setItem('access_token', data.access_token);
      localStorage.setItem('refresh_token', data.refresh_token);
      localStorage.setItem('user', JSON.stringify(data.user));
    }
    return { ok: res.ok, data };
  } catch {
    return { ok: false, data: { error: 'Could not connect to server. Make sure Flask is running.' } };
  }
}

async function forgotPassword(email) {
  try {
    const res = await fetch(`${BASE_URL}/auth/forgot-password`, {
      method: 'POST',
      headers: publicHeaders(),
      body: JSON.stringify({ email })
    });
    const data = await res.json();
    return { ok: res.ok, data };
  } catch {
    return { ok: false, data: { error: 'Could not connect to server.' } };
  }
}

async function resetPassword(email, code, newPassword) {
  try {
    const res = await fetch(`${BASE_URL}/auth/reset-password`, {
      method: 'POST',
      headers: publicHeaders(),
      body: JSON.stringify({ email, code, new_password: newPassword })
    });
    const data = await res.json();
    return { ok: res.ok, data };
  } catch {
    return { ok: false, data: { error: 'Could not connect to server.' } };
  }
}

function logout() {
  localStorage.removeItem('access_token');
  localStorage.removeItem('refresh_token');
  localStorage.removeItem('user');
  window.location.href = 'auth.html';
}

// ── MENTORS ───────────────────────────────────────────────

async function getMentors() {
  try {
    const res = await apiFetch(`${BASE_URL}/mentors`, {
      method: 'GET',
      headers: authHeaders()
    });
    const data = await res.json();
    return { ok: res.ok, data };
  } catch {
    return { ok: false, data: { error: 'Could not load mentors.' } };
  }
}

// ── CONNECTIONS ───────────────────────────────────────────

async function sendConnectionRequest(mentorId) {
  try {
    const res = await apiFetch(`${BASE_URL}/requests`, {
      method: 'POST',
      headers: authHeaders(),
      body: JSON.stringify({ mentor_id: mentorId })
    });
    const data = await res.json();
    return { ok: res.ok, data };
  } catch {
    return { ok: false, data: { error: 'Could not send request.' } };
  }
}

async function getConnectionRequests() {
  try {
    const res = await apiFetch(`${BASE_URL}/requests`, {
      method: 'GET',
      headers: authHeaders()
    });
    const data = await res.json();
    return { ok: res.ok, data };
  } catch {
    return { ok: false, data: { error: 'Could not load requests.' } };
  }
}

// ── NOTIFICATIONS ─────────────────────────────────────────

async function getNotifications() {
  try {
    const res = await apiFetch(`${BASE_URL}/notifications`, {
      method: 'GET',
      headers: authHeaders()
    });
    const data = await res.json();
    return { ok: res.ok, data };
  } catch {
    return { ok: false, data: { error: 'Could not load notifications.' } };
  }
}

async function markNotificationsRead() {
  try {
    const res = await apiFetch(`${BASE_URL}/notifications/read`, {
      method: 'PUT',
      headers: authHeaders()
    });
    const data = await res.json();
    return { ok: res.ok, data };
  } catch {
    return { ok: false, data: { error: 'Could not update notifications.' } };
  }
}