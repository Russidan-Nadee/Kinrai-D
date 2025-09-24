export interface UserDislike {
  id: number;
  user_profile_id: string;
  menu_id: number;
  reason?: string;
  created_at: Date;
}
