-- CreateEnum
CREATE TYPE "public"."MealTime" AS ENUM ('BREAKFAST', 'LUNCH', 'DINNER', 'SNACK');

-- CreateEnum
CREATE TYPE "public"."UserRole" AS ENUM ('ADMIN', 'USER', 'MODERATOR');

-- CreateTable
CREATE TABLE "public"."food_types" (
    "id" SERIAL NOT NULL,
    "key" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "food_types_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."food_type_translations" (
    "id" SERIAL NOT NULL,
    "food_type_id" INTEGER NOT NULL,
    "language" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,

    CONSTRAINT "food_type_translations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."categories" (
    "id" SERIAL NOT NULL,
    "food_type_id" INTEGER NOT NULL,
    "key" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "categories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."category_translations" (
    "id" SERIAL NOT NULL,
    "category_id" INTEGER NOT NULL,
    "language" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,

    CONSTRAINT "category_translations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."subcategories" (
    "id" SERIAL NOT NULL,
    "category_id" INTEGER NOT NULL,
    "key" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "subcategories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."subcategory_translations" (
    "id" SERIAL NOT NULL,
    "subcategory_id" INTEGER NOT NULL,
    "language" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,

    CONSTRAINT "subcategory_translations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."protein_types" (
    "id" SERIAL NOT NULL,
    "key" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "protein_types_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."protein_type_translations" (
    "id" SERIAL NOT NULL,
    "protein_type_id" INTEGER NOT NULL,
    "language" TEXT NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "protein_type_translations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."menus" (
    "id" SERIAL NOT NULL,
    "subcategory_id" INTEGER NOT NULL,
    "protein_type_id" INTEGER,
    "key" TEXT NOT NULL,
    "image_url" TEXT,
    "contains" JSONB NOT NULL,
    "meal_time" "public"."MealTime" NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "menus_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."menu_translations" (
    "id" SERIAL NOT NULL,
    "menu_id" INTEGER NOT NULL,
    "language" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,

    CONSTRAINT "menu_translations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."dietary_restrictions" (
    "id" SERIAL NOT NULL,
    "key" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "dietary_restrictions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."dietary_restriction_translations" (
    "id" SERIAL NOT NULL,
    "dietary_restriction_id" INTEGER NOT NULL,
    "language" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,

    CONSTRAINT "dietary_restriction_translations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."user_dietary_restrictions" (
    "id" SERIAL NOT NULL,
    "user_profile_id" UUID NOT NULL,
    "dietary_restriction_id" INTEGER NOT NULL,

    CONSTRAINT "user_dietary_restrictions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."user_profiles" (
    "id" UUID NOT NULL,
    "email" TEXT NOT NULL,
    "name" TEXT,
    "phone" TEXT,
    "role" "public"."UserRole" NOT NULL DEFAULT 'USER',
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "user_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."user_dislikes" (
    "id" SERIAL NOT NULL,
    "user_profile_id" UUID NOT NULL,
    "menu_id" INTEGER NOT NULL,
    "reason" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_dislikes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."favorite_menus" (
    "id" SERIAL NOT NULL,
    "user_profile_id" UUID NOT NULL,
    "menu_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "favorite_menus_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."menu_ratings" (
    "id" SERIAL NOT NULL,
    "user_profile_id" UUID NOT NULL,
    "menu_id" INTEGER NOT NULL,
    "rating" INTEGER NOT NULL,
    "review" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "menu_ratings_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "food_types_key_key" ON "public"."food_types"("key");

-- CreateIndex
CREATE INDEX "food_type_translations_language_idx" ON "public"."food_type_translations"("language");

-- CreateIndex
CREATE UNIQUE INDEX "food_type_translations_food_type_id_language_key" ON "public"."food_type_translations"("food_type_id", "language");

-- CreateIndex
CREATE UNIQUE INDEX "categories_key_key" ON "public"."categories"("key");

-- CreateIndex
CREATE INDEX "categories_food_type_id_idx" ON "public"."categories"("food_type_id");

-- CreateIndex
CREATE INDEX "category_translations_language_idx" ON "public"."category_translations"("language");

-- CreateIndex
CREATE UNIQUE INDEX "category_translations_category_id_language_key" ON "public"."category_translations"("category_id", "language");

-- CreateIndex
CREATE UNIQUE INDEX "subcategories_key_key" ON "public"."subcategories"("key");

-- CreateIndex
CREATE INDEX "subcategories_category_id_idx" ON "public"."subcategories"("category_id");

-- CreateIndex
CREATE INDEX "subcategory_translations_language_idx" ON "public"."subcategory_translations"("language");

-- CreateIndex
CREATE UNIQUE INDEX "subcategory_translations_subcategory_id_language_key" ON "public"."subcategory_translations"("subcategory_id", "language");

-- CreateIndex
CREATE UNIQUE INDEX "protein_types_key_key" ON "public"."protein_types"("key");

-- CreateIndex
CREATE INDEX "protein_type_translations_language_idx" ON "public"."protein_type_translations"("language");

-- CreateIndex
CREATE UNIQUE INDEX "protein_type_translations_protein_type_id_language_key" ON "public"."protein_type_translations"("protein_type_id", "language");

-- CreateIndex
CREATE UNIQUE INDEX "menus_key_key" ON "public"."menus"("key");

-- CreateIndex
CREATE INDEX "menus_subcategory_id_idx" ON "public"."menus"("subcategory_id");

-- CreateIndex
CREATE INDEX "menus_protein_type_id_idx" ON "public"."menus"("protein_type_id");

-- CreateIndex
CREATE INDEX "menus_meal_time_idx" ON "public"."menus"("meal_time");

-- CreateIndex
CREATE INDEX "menu_translations_language_idx" ON "public"."menu_translations"("language");

-- CreateIndex
CREATE UNIQUE INDEX "menu_translations_menu_id_language_key" ON "public"."menu_translations"("menu_id", "language");

-- CreateIndex
CREATE UNIQUE INDEX "dietary_restrictions_key_key" ON "public"."dietary_restrictions"("key");

-- CreateIndex
CREATE INDEX "dietary_restriction_translations_language_idx" ON "public"."dietary_restriction_translations"("language");

-- CreateIndex
CREATE UNIQUE INDEX "dietary_restriction_translations_dietary_restriction_id_lan_key" ON "public"."dietary_restriction_translations"("dietary_restriction_id", "language");

-- CreateIndex
CREATE INDEX "user_dietary_restrictions_user_profile_id_idx" ON "public"."user_dietary_restrictions"("user_profile_id");

-- CreateIndex
CREATE INDEX "user_dietary_restrictions_dietary_restriction_id_idx" ON "public"."user_dietary_restrictions"("dietary_restriction_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_dietary_restrictions_user_profile_id_dietary_restricti_key" ON "public"."user_dietary_restrictions"("user_profile_id", "dietary_restriction_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_profiles_email_key" ON "public"."user_profiles"("email");

-- CreateIndex
CREATE INDEX "user_profiles_email_idx" ON "public"."user_profiles"("email");

-- CreateIndex
CREATE INDEX "user_profiles_role_idx" ON "public"."user_profiles"("role");

-- CreateIndex
CREATE INDEX "user_dislikes_user_profile_id_idx" ON "public"."user_dislikes"("user_profile_id");

-- CreateIndex
CREATE INDEX "user_dislikes_menu_id_idx" ON "public"."user_dislikes"("menu_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_dislikes_user_profile_id_menu_id_key" ON "public"."user_dislikes"("user_profile_id", "menu_id");

-- CreateIndex
CREATE INDEX "favorite_menus_user_profile_id_idx" ON "public"."favorite_menus"("user_profile_id");

-- CreateIndex
CREATE INDEX "favorite_menus_menu_id_idx" ON "public"."favorite_menus"("menu_id");

-- CreateIndex
CREATE UNIQUE INDEX "favorite_menus_user_profile_id_menu_id_key" ON "public"."favorite_menus"("user_profile_id", "menu_id");

-- CreateIndex
CREATE INDEX "menu_ratings_user_profile_id_idx" ON "public"."menu_ratings"("user_profile_id");

-- CreateIndex
CREATE INDEX "menu_ratings_menu_id_idx" ON "public"."menu_ratings"("menu_id");

-- CreateIndex
CREATE UNIQUE INDEX "menu_ratings_user_profile_id_menu_id_key" ON "public"."menu_ratings"("user_profile_id", "menu_id");

-- AddForeignKey
ALTER TABLE "public"."food_type_translations" ADD CONSTRAINT "food_type_translations_food_type_id_fkey" FOREIGN KEY ("food_type_id") REFERENCES "public"."food_types"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."categories" ADD CONSTRAINT "categories_food_type_id_fkey" FOREIGN KEY ("food_type_id") REFERENCES "public"."food_types"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."category_translations" ADD CONSTRAINT "category_translations_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."categories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."subcategories" ADD CONSTRAINT "subcategories_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."categories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."subcategory_translations" ADD CONSTRAINT "subcategory_translations_subcategory_id_fkey" FOREIGN KEY ("subcategory_id") REFERENCES "public"."subcategories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."protein_type_translations" ADD CONSTRAINT "protein_type_translations_protein_type_id_fkey" FOREIGN KEY ("protein_type_id") REFERENCES "public"."protein_types"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."menus" ADD CONSTRAINT "menus_subcategory_id_fkey" FOREIGN KEY ("subcategory_id") REFERENCES "public"."subcategories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."menus" ADD CONSTRAINT "menus_protein_type_id_fkey" FOREIGN KEY ("protein_type_id") REFERENCES "public"."protein_types"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."menu_translations" ADD CONSTRAINT "menu_translations_menu_id_fkey" FOREIGN KEY ("menu_id") REFERENCES "public"."menus"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."dietary_restriction_translations" ADD CONSTRAINT "dietary_restriction_translations_dietary_restriction_id_fkey" FOREIGN KEY ("dietary_restriction_id") REFERENCES "public"."dietary_restrictions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."user_dietary_restrictions" ADD CONSTRAINT "user_dietary_restrictions_user_profile_id_fkey" FOREIGN KEY ("user_profile_id") REFERENCES "public"."user_profiles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."user_dietary_restrictions" ADD CONSTRAINT "user_dietary_restrictions_dietary_restriction_id_fkey" FOREIGN KEY ("dietary_restriction_id") REFERENCES "public"."dietary_restrictions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."user_dislikes" ADD CONSTRAINT "user_dislikes_user_profile_id_fkey" FOREIGN KEY ("user_profile_id") REFERENCES "public"."user_profiles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."user_dislikes" ADD CONSTRAINT "user_dislikes_menu_id_fkey" FOREIGN KEY ("menu_id") REFERENCES "public"."menus"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."favorite_menus" ADD CONSTRAINT "favorite_menus_user_profile_id_fkey" FOREIGN KEY ("user_profile_id") REFERENCES "public"."user_profiles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."favorite_menus" ADD CONSTRAINT "favorite_menus_menu_id_fkey" FOREIGN KEY ("menu_id") REFERENCES "public"."menus"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."menu_ratings" ADD CONSTRAINT "menu_ratings_user_profile_id_fkey" FOREIGN KEY ("user_profile_id") REFERENCES "public"."user_profiles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."menu_ratings" ADD CONSTRAINT "menu_ratings_menu_id_fkey" FOREIGN KEY ("menu_id") REFERENCES "public"."menus"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
