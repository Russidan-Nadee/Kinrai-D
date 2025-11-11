import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const categorySeedData = [
  // Categories for savory_food (ของคาว)
  {
    food_type_key: 'savory_food',
    key: 'rice_dishes',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Rice Dishes',
        description: 'Rice with toppings and rice-based meals',
      },
      {
        language: 'th',
        name: 'ข้าวราด',
        description: 'ข้าวราดแกง ข้าวผัด และอาหารจานเดียว',
      },
      {
        language: 'ja',
        name: 'ライス料理',
        description: 'ご飯もの料理とライスベースの食事',
      },
      {
        language: 'zh',
        name: '米饭类',
        description: '盖饭和米饭类菜肴',
      },
    ],
  },
  {
    food_type_key: 'savory_food',
    key: 'noodles',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Noodles',
        description: 'Various types of noodle dishes',
      },
      {
        language: 'th',
        name: 'เส้น',
        description: 'ก๋วยเตี๋ยว บะหมี่ เส้นใหญ่ เส้นเล็ก',
      },
      {
        language: 'ja',
        name: '麺類',
        description: '様々な麺料理',
      },
      {
        language: 'zh',
        name: '面条类',
        description: '各种面条菜肴',
      },
    ],
  },
  {
    food_type_key: 'savory_food',
    key: 'curry',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Curry',
        description: 'Thai curries and curry-based dishes',
      },
      {
        language: 'th',
        name: 'แกง',
        description: 'แกงเผ็ด แกงเขียวหวาน แกงมัสมั่น',
      },
      {
        language: 'ja',
        name: 'カレー',
        description: 'タイカレーとカレーベースの料理',
      },
      {
        language: 'zh',
        name: '咖喱类',
        description: '泰式咖喱和咖喱菜肴',
      },
    ],
  },
  {
    food_type_key: 'savory_food',
    key: 'stir_fry',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Stir Fry',
        description: 'Stir-fried dishes and wok cooking',
      },
      {
        language: 'th',
        name: 'ผัด',
        description: 'ผัดไทย ผัดซีอิ๊ว ผัดกะเพรา',
      },
      {
        language: 'ja',
        name: '炒め物',
        description: '炒め料理と中華鍋料理',
      },
      {
        language: 'zh',
        name: '炒菜类',
        description: '炒菜和炒河粉等',
      },
    ],
  },
  {
    food_type_key: 'savory_food',
    key: 'soup',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Soup',
        description: 'Thai soups and broths',
      },
      {
        language: 'th',
        name: 'ต้ม',
        description: 'ต้มยำ ต้มข่า ต้มจืด',
      },
      {
        language: 'ja',
        name: 'スープ',
        description: 'タイのスープ類',
      },
      {
        language: 'zh',
        name: '汤类',
        description: '泰式汤品',
      },
    ],
  },
  {
    food_type_key: 'savory_food',
    key: 'salad',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Salad',
        description: 'Thai salads and fresh dishes',
      },
      {
        language: 'th',
        name: 'ยำ',
        description: 'ส้มตำ ยำวุ้นเส้น ลาบ',
      },
      {
        language: 'ja',
        name: 'サラダ',
        description: 'タイ風サラダと生野菜料理',
      },
      {
        language: 'zh',
        name: '沙拉类',
        description: '泰式沙拉和凉菜',
      },
    ],
  },
  {
    food_type_key: 'savory_food',
    key: 'grilled',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Grilled',
        description: 'Grilled and barbecued dishes',
      },
      {
        language: 'th',
        name: 'ย่าง/เผา',
        description: 'ไก่ย่าง หมูเผา ปลาเผา',
      },
      {
        language: 'ja',
        name: '焼き物',
        description: 'グリル料理とバーベキュー',
      },
      {
        language: 'zh',
        name: '烧烤类',
        description: '烧烤和烤制菜肴',
      },
    ],
  },
];

export async function seedCategories() {
  console.log('🏷️ Seeding categories...');
  
  for (const category of categorySeedData) {
    // Find the food type first
    const foodType = await prisma.foodType.findUnique({
      where: { key: category.food_type_key },
    });

    if (!foodType) {
      console.log(`❌ Food type not found: ${category.food_type_key}`);
      continue;
    }

    const existingCategory = await prisma.category.findUnique({
      where: { key: category.key },
    });

    if (existingCategory) {
      console.log(`⚠️  Category already exists: ${category.key}`);
      continue;
    }

    const createdCategory = await prisma.category.create({
      data: {
        key: category.key,
        food_type_id: foodType.id,
        is_active: category.is_active,
        Translations: {
          create: category.translations,
        },
      },
      include: {
        Translations: true,
      },
    });
    
    console.log(`✅ Created category: ${createdCategory.key}`);
  }
  
  console.log('🎉 Categories seeding completed!');
}

// Run if this file is executed directly
if (require.main === module) {
  void (async () => {
    try {
      await seedCategories();
      await prisma.$disconnect();
    } catch (e) {
      console.error('❌ Error seeding categories:', e);
      await prisma.$disconnect();
      process.exit(1);
    }
  })();
}