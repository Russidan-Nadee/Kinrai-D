import { MealTime } from '../dto/create-menu.dto';

export class Menu {
  id: number;
  subcategory_id: number;
  protein_type_id?: number;
  image_url?: string;
  contains: any; // JSON object
  meal_time: MealTime;
  is_active: boolean;
  created_at: Date;
  updated_at: Date;
}

export class MenuWithTranslations extends Menu {
  subcategory?: {
    id: number;
    name: string;
    category?: {
      id: number;
      name: string;
      food_type?: {
        id: number;
        name: string;
      };
    };
  };
  protein_type?: {
    id: number;
    name: string;
  };
  average_rating?: number;
  total_ratings?: number;
  name?: string;
}
