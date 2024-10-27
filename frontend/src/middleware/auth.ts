import { validateToken } from '../lib/auth';

export async function protect() {
  const token = localStorage.getItem('auth_token');
  if (!token) {
    window.location.href = '/login';
    return false;
  }

  const user = await validateToken();
  if (!user) {
    window.location.href = '/login';
    return false;
  }

  return user;
}