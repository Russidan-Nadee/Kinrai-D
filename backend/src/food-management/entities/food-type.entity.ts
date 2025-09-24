export class FoodType {
  id: number;
  name: string;
  description: string | null;
  is_active: boolean;
  created_at: Date;
  updated_at: Date;

  // Relations
  Categories?: Category[];
}

export class Category {
  id: number;
  food_type_id: number;
  name: string;
  description: string | null;
  is_active: boolean;
  created_at: Date;
  updated_at: Date;

  // Relations
  FoodType?: FoodType;
  Subcategories?: Subcategory[];
}

export class Subcategory {
  id: number;
  category_id: number;
  name: string;
  description: string | null;
  is_active: boolean;
  created_at: Date;
  updated_at: Date;

  // Relations
  Category?: Category;
  Menus?: Menu[];
}

export class Menu {
  id: number;
  subcategory_id: number;
  protein_type_id: number | null;
  name: string;
  description: string | null;
  image_url: string | null;
  contains: any; // Json type
  meal_time: 'BREAKFAST' | 'LUNCH' | 'DINNER' | 'SNACK';
  is_active: boolean;
  created_at: Date;
  updated_at: Date;

  // Relations
  Subcategory?: Subcategory;
  ProteinType?: ProteinType;
}

export class ProteinType {
  id: number;
  name: string;
  is_active: boolean;
  created_at: Date;
  updated_at: Date;

  // Relations
  Menus?: Menu[];
}
