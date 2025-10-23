-- CreateIndex
CREATE INDEX "menus_is_active_idx" ON "menus"("is_active");

-- CreateIndex
CREATE INDEX "menus_is_active_meal_time_idx" ON "menus"("is_active", "meal_time");

-- CreateIndex
CREATE INDEX "menus_created_at_idx" ON "menus"("created_at");

-- CreateIndex
CREATE INDEX "user_dislikes_created_at_idx" ON "user_dislikes"("created_at");

-- CreateIndex
CREATE INDEX "user_dislikes_user_profile_id_created_at_idx" ON "user_dislikes"("user_profile_id", "created_at");

-- CreateIndex
CREATE INDEX "favorite_menus_created_at_idx" ON "favorite_menus"("created_at");

-- CreateIndex
CREATE INDEX "favorite_menus_user_profile_id_created_at_idx" ON "favorite_menus"("user_profile_id", "created_at");

-- CreateIndex
CREATE INDEX "menu_ratings_created_at_idx" ON "menu_ratings"("created_at");

-- CreateIndex
CREATE INDEX "menu_ratings_user_profile_id_created_at_idx" ON "menu_ratings"("user_profile_id", "created_at");

-- CreateIndex
CREATE INDEX "menu_ratings_rating_idx" ON "menu_ratings"("rating");
