const API_URL = 'http://localhost:3000/api/v1';

export async function validateToken() {
  const token = localStorage.getItem('auth_token');
  
  if (!token) return null;

  try {
    const response = await fetch(`${API_URL}/auth/validate_token`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      credentials: 'include'
    });

    if (!response.ok) {
      console.error('Token validation failed:', await response.text());
      localStorage.removeItem('auth_token');
      return null;
    }

    const data = await response.json();
    return data.valid ? data.user : null;
  } catch (error) {
    console.error('Auth error:', error);
    localStorage.removeItem('auth_token');
    return null;
  }
}

export function getLoginUrl() {
  return 'http://localhost:3000/users/auth/google_oauth2';
}

export function isAuthenticated() {
  return !!localStorage.getItem('auth_token');
}

export function logout() {
  localStorage.removeItem('auth_token');
  window.location.href = '/login';
}