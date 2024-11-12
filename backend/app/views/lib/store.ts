type ApiResponse<T> = {
    data: T | null;
    error: string | null;
    loading: boolean;
  };
  
  class ApiStore {
    private baseUrl = 'http://localhost:3000/api/v1';
    
    async fetchJson<T>(endpoint: string, options: RequestInit = {}): Promise<ApiResponse<T>> {
      try {
        const response = await fetch(`${this.baseUrl}${endpoint}`, {
          ...options,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            ...options.headers,
          },
        });
  
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
  
        const data = await response.json();
        return { data, error: null, loading: false };
      } catch (error) {
        console.error('API Error:', error);
        return {
          data: null,
          error: error instanceof Error ? error.message : 'An error occurred',
          loading: false
        };
      }
    }
  
    // Study Spaces
    async getStudySpaces() {
      return this.fetchJson('/study_spaces');
    }
  
    async getStudySpace(id: string) {
      return this.fetchJson(`/study_spaces/${id}`);
    }
  
    async searchStudySpaces(query: string) {
      return this.fetchJson(`/study_spaces/search?q=${encodeURIComponent(query)}`);
    }
  
    // Buildings
    async getBuildings() {
      return this.fetchJson('/buildings');
    }
  
    async getBuilding(id: string) {
      return this.fetchJson(`/buildings/${id}`);
    }
  
    // User
    async getCurrentUser() {
      const token = localStorage.getItem('auth_token');
      if (!token) return { data: null, error: 'No auth token', loading: false };
  
      return this.fetchJson('/me', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
    }
  }
  
  export const api = new ApiStore();