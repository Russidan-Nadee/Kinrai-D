export interface MenuRating {
  id: number;
  user_profile_id: string;
  menu_id: number;
  rating: number;
  review?: string;
  created_at: Date;
  updated_at: Date;
}
