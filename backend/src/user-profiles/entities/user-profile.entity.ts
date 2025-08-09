export interface UserProfile {
  id: string;
  name?: string;
  phone?: string;
  is_active: boolean;
  created_at: Date;
  updated_at: Date;
}