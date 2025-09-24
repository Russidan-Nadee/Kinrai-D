import { PrismaClient, MealTime } from '@prisma/client';

const prisma = new PrismaClient();

export const menuSeedData = [
  // Rice Dishes - Pad Kaprao with all protein types
  {
    subcategory_key: 'pad_kaprao',
    protein_type_key: 'chicken',
    image_url: null,
    contains: ['basil', 'chilies', 'garlic', 'soy_sauce', 'oyster_sauce', 'chicken'],
    meal_time: MealTime.LUNCH,
    is_active: true,
  },
  {
    subcategory_key: 'pad_kaprao',
    protein_type_key: 'pork',
    image_url: null,
    contains: ['basil', 'chilies', 'garlic', 'soy_sauce', 'oyster_sauce', 'pork'],
    meal_time: MealTime.LUNCH,
    is_active: true,
  },
  {
    subcategory_key: 'pad_kaprao',
    protein_type_key: 'beef',
    image_url: null,
    contains: ['basil', 'chilies', 'garlic', 'soy_sauce', 'oyster_sauce', 'beef'],
    meal_time: MealTime.LUNCH,
    is_active: true,
  },
  {
    subcategory_key: 'pad_kaprao',
    protein_type_key: 'seafood',
    image_url: null,
    contains: ['basil', 'chilies', 'garlic', 'soy_sauce', 'oyster_sauce', 'seafood'],
    meal_time: MealTime.LUNCH,
    is_active: true,
  },
  {
    subcategory_key: 'pad_kaprao',
    protein_type_key: 'shrimp',
    image_url: null,
    contains: ['basil', 'chilies', 'garlic', 'soy_sauce', 'oyster_sauce', 'shrimp'],
    meal_time: MealTime.LUNCH,
    is_active: true,
  },
  {
    subcategory_key: 'pad_kaprao',
    protein_type_key: 'duck',
    image_url: null,
    contains: ['basil', 'chilies', 'garlic', 'soy_sauce', 'oyster_sauce', 'duck'],
    meal_time: MealTime.LUNCH,
    is_active: true,
  },
  {
    subcategory_key: 'pad_kaprao',
    protein_type_key: 'mixed_protein',
    image_url: null,
    contains: ['basil', 'chilies', 'garlic', 'soy_sauce', 'oyster_sauce', 'mixed_protein'],
    meal_time: MealTime.LUNCH,
    is_active: true,
  },
  {
    subcategory_key: 'pad_kaprao',
    protein_type_key: 'vegetarian',
    image_url: null,
    contains: ['basil', 'chilies', 'garlic', 'soy_sauce', 'vegetarian_protein'],
    meal_time: MealTime.LUNCH,
    is_active: true,
  },
  {
    subcategory_key: 'pad_kaprao',
    protein_type_key: 'vegan',
    image_url: null,
    contains: ['basil', 'chilies', 'garlic', 'soy_sauce', 'vegan_protein'],
    meal_time: MealTime.LUNCH,
    is_active: true,
  },
  // Noodles - Pad Thai
  {
    subcategory_key: 'pad_thai',
    protein_type_key: 'chicken',
    image_url: null,
    contains: ['rice_noodles', 'chicken', 'bean_sprouts', 'peanuts', 'lime'],
    meal_time: MealTime.LUNCH,
    is_active: true,
  },
  // Curry - Green Curry
  {
    subcategory_key: 'gaeng_keow_wan',
    protein_type_key: 'chicken',
    image_url: null,
    contains: ['green_curry_paste', 'coconut_milk', 'chicken', 'eggplant', 'basil'],
    meal_time: MealTime.DINNER,
    is_active: true,
  },
  // Soup - Tom Yum
  {
    subcategory_key: 'kuay_teow',
    protein_type_key: 'pork',
    image_url: null,
    contains: ['rice_noodles', 'pork', 'pork_broth', 'fish_balls', 'vegetables'],
    meal_time: MealTime.BREAKFAST,
    is_active: true,
  },
  // Salad - Som Tam
  {
    subcategory_key: 'som_tam',
    protein_type_key: null,
    image_url: null,
    contains: ['green_papaya', 'tomatoes', 'carrots', 'peanuts', 'lime', 'chilies'],
    meal_time: MealTime.LUNCH,
    is_active: true,
  },
  // Fried Rice
  {
    subcategory_key: 'khao_pad',
    protein_type_key: 'shrimp',
    image_url: null,
    contains: ['jasmine_rice', 'shrimp', 'eggs', 'onions', 'soy_sauce'],
    meal_time: MealTime.DINNER,
    is_active: true,
  },
  // More Rice Dishes - Pad Prik Gaeng
  {
    subcategory_key: 'pad_prik_gaeng',
    protein_type_key: 'pork',
    image_url: null,
    contains: ['curry_paste', 'pork', 'vegetables', 'soy_sauce'],
    meal_time: MealTime.LUNCH,
    is_active: true,
  },

  // Pad Kee Mao - Drunken Noodles
  {
    subcategory_key: 'pad_kee_mao',
    protein_type_key: 'chicken',
    image_url: null,
    contains: ['wide_noodles', 'chicken', 'basil', 'chilies', 'vegetables'],
    meal_time: MealTime.DINNER,
    is_active: true,
  },


  // Yam Wun Sen - Glass Noodle Salad
  {
    subcategory_key: 'yam_wun_sen',
    protein_type_key: null,
    image_url: null,
    contains: ['glass_noodles', 'lime', 'chilies'],
    meal_time: MealTime.LUNCH,
    is_active: true,
  },
  // Khao Na - Rice with Topping
  {
    subcategory_key: 'khao_na',
    protein_type_key: null,
    image_url: null,
    contains: ['jasmine_rice', 'vegetables', 'soy_sauce'],
    meal_time: MealTime.LUNCH,
    is_active: true,
  },
  // Khao Soi - Northern Thai Curry Noodles
  {
    subcategory_key: 'khao_soi',
    protein_type_key: null,
    image_url: null,
    contains: ['egg_noodles', 'coconut_milk', 'curry_paste', 'crispy_noodles'],
    meal_time: MealTime.LUNCH,
    is_active: true,
  },
  // Tom Yum - Spicy Soup
  {
    subcategory_key: 'tom_yum',
    protein_type_key: null,
    image_url: null,
    contains: ['lemongrass', 'kaffir_lime_leaves', 'galangal', 'chilies', 'lime', 'mushrooms'],
    meal_time: MealTime.DINNER,
    is_active: true,
  },
];

export async function seedMenus() {
  console.log('🍽️ Seeding menus...');

  for (const menu of menuSeedData) {
    // Find the subcategory
    const subcategory = await prisma.subcategory.findUnique({
      where: { key: menu.subcategory_key },
    });

    if (!subcategory) {
      console.log(`❌ Subcategory not found: ${menu.subcategory_key}`);
      continue;
    }

    // Find the protein type
    let proteinType: { id: number } | null = null;
    if (menu.protein_type_key) {
      const foundProteinType = await prisma.proteinType.findUnique({
        where: { key: menu.protein_type_key },
      });

      if (!foundProteinType) {
        console.log(`❌ Protein type not found: ${menu.protein_type_key}`);
        continue;
      }
      proteinType = foundProteinType;
    }

    const existingMenu = await prisma.menu.findFirst({
      where: {
        subcategory_id: subcategory.id,
        protein_type_id: proteinType?.id,
      },
    });

    if (existingMenu) {
      console.log(`⚠️  Menu already exists for subcategory: ${menu.subcategory_key} with protein: ${menu.protein_type_key || 'none'}`);
      continue;
    }

    const createdMenu = await prisma.menu.create({
      data: {
        subcategory_id: subcategory.id,
        protein_type_id: proteinType?.id,
        image_url: menu.image_url,
        contains: menu.contains,
        meal_time: menu.meal_time,
        is_active: menu.is_active,
      },
      include: {
        Subcategory: {
          include: {
            Translations: true,
          },
        },
        ProteinType: {
          include: {
            Translations: true,
          },
        },
      },
    });

    console.log(`✅ Created menu for subcategory: ${menu.subcategory_key} with protein: ${menu.protein_type_key || 'none'}`);
  }

  console.log('🎉 Menus seeding completed!');
}

// Run if this file is executed directly
if (require.main === module) {
  seedMenus()
    .then(async () => {
      await prisma.$disconnect();
    })
    .catch(async (e) => {
      console.error('❌ Error seeding menus:', e);
      await prisma.$disconnect();
      process.exit(1);
    });
}