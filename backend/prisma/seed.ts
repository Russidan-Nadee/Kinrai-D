import { PrismaClient } from '@prisma/client';
import { seedFoodTypes } from './seeds/food-types.seed';
import { seedCategories } from './seeds/categories.seed';
import { seedSubcategories } from './seeds/subcategories.seed';
import { seedProteinTypes } from './seeds/protein-types.seed';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting database seeding...');

  // Seed Food Types
  await seedFoodTypes();

  // Seed Categories
  await seedCategories();

  // Seed Subcategories
  await seedSubcategories();

  // Seed Protein Types
  await seedProteinTypes();

  // Menus will be created manually through admin interface
  console.log('🍽️ Skipping menu seeding - menus will be created manually');

  console.log('🎉 Database seeding completed successfully!');
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error('❌ Error during seeding:', e);
    await prisma.$disconnect();
    process.exit(1);
  });