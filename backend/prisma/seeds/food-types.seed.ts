import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const foodTypeSeedData = [
  {
    key: 'savory_food',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Savory Food',
        description: 'Main dishes and savory meals',
      },
      {
        language: 'th',
        name: 'ของคาว',
        description: 'อาหารคาว อาหารจานหลัก',
      },
      {
        language: 'ja',
        name: '主食',
        description: 'メイン料理と塩味の食事',
      },
      {
        language: 'zh',
        name: '主食',
        description: '主菜和咸味食物',
      },
    ],
  },
];

export async function seedFoodTypes() {
  console.log('🍽️ Seeding food types...');
  
  for (const foodType of foodTypeSeedData) {
    const existingFoodType = await prisma.foodType.findUnique({
      where: { key: foodType.key },
    });

    if (existingFoodType) {
      console.log(`⚠️  Food type already exists: ${foodType.key}`);
      continue;
    }

    const createdFoodType = await prisma.foodType.create({
      data: {
        key: foodType.key,
        is_active: foodType.is_active,
        Translations: {
          create: foodType.translations,
        },
      },
      include: {
        Translations: true,
      },
    });
    
    console.log(`✅ Created food type: ${createdFoodType.key}`);
  }
  
  console.log('🎉 Food types seeding completed!');
}

// Run if this file is executed directly
if (require.main === module) {
  void (async () => {
    try {
      await seedFoodTypes();
      await prisma.$disconnect();
    } catch (e) {
      console.error('❌ Error seeding food types:', e);
      await prisma.$disconnect();
      process.exit(1);
    }
  })();
}