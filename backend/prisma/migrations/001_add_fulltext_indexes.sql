-- Add full-text search indexes for better search performance

-- Create indexes on menu translations
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_menu_translations_name_fulltext 
ON menu_translations USING GIN (to_tsvector('english', name));

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_menu_translations_description_fulltext 
ON menu_translations USING GIN (to_tsvector('english', description));

-- Create composite index for name and description search
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_menu_translations_search_composite 
ON menu_translations USING GIN ((to_tsvector('english', COALESCE(name, '') || ' ' || COALESCE(description, ''))));

-- Create indexes on other translation tables for consistency
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_category_translations_name_fulltext 
ON category_translations USING GIN (to_tsvector('english', name));

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_subcategory_translations_name_fulltext 
ON subcategory_translations USING GIN (to_tsvector('english', name));

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_food_type_translations_name_fulltext 
ON food_type_translations USING GIN (to_tsvector('english', name));

-- Add regular indexes for common queries
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_menu_translations_language_name 
ON menu_translations (language, name);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_menu_translations_language_id 
ON menu_translations (language, menu_id);

-- Add trigram indexes for fuzzy search (requires pg_trgm extension)
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_menu_translations_name_trgm 
ON menu_translations USING GIN (name gin_trgm_ops);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_menu_translations_description_trgm 
ON menu_translations USING GIN (description gin_trgm_ops);

-- Add indexes on menu table for performance
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_menu_meal_time_active 
ON menus (meal_time, is_active) WHERE is_active = true;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_menu_subcategory_active 
ON menus (subcategory_id, is_active) WHERE is_active = true;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_menu_protein_type_active 
ON menus (protein_type_id, is_active) WHERE is_active = true AND protein_type_id IS NOT NULL;

-- Add indexes on related tables for joins
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_subcategories_category_active 
ON subcategories (category_id, is_active) WHERE is_active = true;

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_categories_food_type_active 
ON categories (food_type_id, is_active) WHERE is_active = true;

-- Add indexes for rating aggregation
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_menu_ratings_menu_rating 
ON menu_ratings (menu_id, rating);

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_favorite_menus_menu_created 
ON favorite_menus (menu_id, created_at);