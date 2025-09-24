export interface SubcategoryTranslation {
  id: number;
  subcategory_id: number;
  language: string;
  name: string;
  description?: string;
}

export interface Subcategory {
  id: number;
  category_id: number;
  key: string;
  is_active: boolean;
  created_at: Date;
  updated_at: Date;
  Translations?: SubcategoryTranslation[];
  Category?: any; // จะ reference ไปยัง Category entity
  Menus?: any[]; // จะ reference ไปยัง Menu entity
}
