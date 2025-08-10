import { PrismaClient, MealTime } from '@prisma/client';

const prisma = new PrismaClient();

export const menuSeedData = [
  // Rice Dishes - Pad Kaprao
  {
    subcategory_key: 'pad_kaprao',
    protein_type_key: 'chicken',
    key: 'pad_kaprao_gai',
    image_url: 'https://images.unsplash.com/photo-1562565652-a0d8f0c59eb4',
    contains: ['basil', 'chilies', 'garlic', 'soy_sauce', 'oyster_sauce'],
    meal_time: MealTime.LUNCH,
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Pad Kaprao Chicken',
        description: 'Stir-fried chicken with Thai basil over rice',
      },
      {
        language: 'th',
        name: 'ผัดกะเพราไก่',
        description: 'ข้าวผัดกะเพราไก่ใส่ไข่ดาว',
      },
      {
        language: 'jp',
        name: 'パッカパオガイ',
        description: 'タイバジル炒めチキンライス',
      },
      {
        language: 'zh',
        name: '打抛鸡肉饭',
        description: '泰式罗勒炒鸡肉盖饭',
      },
    ],
  },
  {
    subcategory_key: 'pad_kaprao',
    protein_type_key: 'pork',
    key: 'pad_kaprao_moo',
    image_url: 'https://images.unsplash.com/photo-1559847844-d5b96ee3b117',
    contains: ['basil', 'chilies', 'garlic', 'soy_sauce', 'oyster_sauce'],
    meal_time: MealTime.LUNCH,
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Pad Kaprao Pork',
        description: 'Stir-fried pork with Thai basil over rice',
      },
      {
        language: 'th',
        name: 'ผัดกะเพราหมู',
        description: 'ข้าวผัดกะเพราหมูใส่ไข่ดาว',
      },
      {
        language: 'jp',
        name: 'パッカパオムー',
        description: 'タイバジル炒め豚肉ライス',
      },
      {
        language: 'zh',
        name: '打抛猪肉饭',
        description: '泰式罗勒炒猪肉盖饭',
      },
    ],
  },
  // Noodles - Pad Thai
  {
    subcategory_key: 'pad_thai',
    protein_type_key: 'seafood',
    key: 'pad_thai_goong',
    image_url: 'https://images.unsplash.com/photo-1559314809-0f31657def5e',
    contains: ['rice_noodles', 'shrimp', 'bean_sprouts', 'peanuts', 'lime'],
    meal_time: MealTime.LUNCH,
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Pad Thai Shrimp',
        description: 'Classic Thai stir-fried noodles with shrimp',
      },
      {
        language: 'th',
        name: 'ผัดไทยกุ้ง',
        description: 'ผัดไทยกุ้งสดใส่ถั่วงอก',
      },
      {
        language: 'jp',
        name: 'パッタイクン',
        description: 'エビ入りタイ風焼きそば',
      },
      {
        language: 'zh',
        name: '泰式炒河粉虾',
        description: '经典泰式虾仁炒河粉',
      },
    ],
  },
  {
    subcategory_key: 'pad_thai',
    protein_type_key: 'chicken',
    key: 'pad_thai_gai',
    image_url: 'https://images.unsplash.com/photo-1559314809-0f31657def5e',
    contains: ['rice_noodles', 'chicken', 'bean_sprouts', 'peanuts', 'lime'],
    meal_time: MealTime.LUNCH,
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Pad Thai Chicken',
        description: 'Classic Thai stir-fried noodles with chicken',
      },
      {
        language: 'th',
        name: 'ผัดไทยไก่',
        description: 'ผัดไทยไก่ใส่ถั่วงอกและถั่วลิสง',
      },
      {
        language: 'jp',
        name: 'パッタイガイ',
        description: 'チキン入りタイ風焼きそば',
      },
      {
        language: 'zh',
        name: '泰式炒河粉鸡肉',
        description: '经典泰式鸡肉炒河粉',
      },
    ],
  },
  // Curry - Green Curry
  {
    subcategory_key: 'gaeng_keow_wan',
    protein_type_key: 'chicken',
    key: 'gaeng_keow_wan_gai',
    image_url: 'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd',
    contains: ['green_curry_paste', 'coconut_milk', 'chicken', 'eggplant', 'basil'],
    meal_time: MealTime.DINNER,
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Green Curry Chicken',
        description: 'Traditional Thai green curry with chicken',
      },
      {
        language: 'th',
        name: 'แกงเขียวหวานไก่',
        description: 'แกงเขียวหวานไก่ใส่มะเขือ',
      },
      {
        language: 'jp',
        name: 'グリーンカレーチキン',
        description: '伝統的なタイグリーンカレー',
      },
      {
        language: 'zh',
        name: '绿咖喱鸡',
        description: '传统泰式绿咖喱鸡肉',
      },
    ],
  },
  // Soup - Tom Yum
  {
    subcategory_key: 'kuay_teow',
    protein_type_key: 'pork',
    key: 'kuay_teow_nam_moo',
    image_url: 'https://images.unsplash.com/photo-1555126634-323283e090fa',
    contains: ['rice_noodles', 'pork', 'pork_broth', 'fish_balls', 'vegetables'],
    meal_time: MealTime.BREAKFAST,
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Pork Noodle Soup',
        description: 'Thai rice noodle soup with pork',
      },
      {
        language: 'th',
        name: 'ก๋วยเตี๋ยวน้ำหมู',
        description: 'ก๋วยเตี๋ยวน้ำใสหมูใส่ลูกชิน',
      },
      {
        language: 'jp',
        name: 'クイッティアオナムムー',
        description: 'タイ風豚肉入り米麺スープ',
      },
      {
        language: 'zh',
        name: '猪肉粿条汤',
        description: '泰式猪肉米粉汤',
      },
    ],
  },
  // Salad - Som Tam
  {
    subcategory_key: 'som_tam',
    protein_type_key: 'vegetarian',
    key: 'som_tam_thai',
    image_url: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d',
    contains: ['green_papaya', 'tomatoes', 'carrots', 'peanuts', 'lime', 'chilies'],
    meal_time: MealTime.LUNCH,
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Som Tam Thai',
        description: 'Thai green papaya salad',
      },
      {
        language: 'th',
        name: 'ส้มตำไทย',
        description: 'ส้มตำไทยใส่ถั่วลิสงและมะเขือเทศ',
      },
      {
        language: 'jp',
        name: 'ソムタムタイ',
        description: 'タイ風青パパイヤサラダ',
      },
      {
        language: 'zh',
        name: '泰式青木瓜沙拉',
        description: '经典泰式青木瓜沙拉',
      },
    ],
  },
  // Fried Rice
  {
    subcategory_key: 'khao_pad',
    protein_type_key: 'seafood',
    key: 'khao_pad_goong',
    image_url: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398',
    contains: ['jasmine_rice', 'shrimp', 'eggs', 'onions', 'soy_sauce'],
    meal_time: MealTime.DINNER,
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Shrimp Fried Rice',
        description: 'Thai-style fried rice with shrimp',
      },
      {
        language: 'th',
        name: 'ข้าวผัดกุ้ง',
        description: 'ข้าวผัดกุ้งสดใส่ไข่',
      },
      {
        language: 'jp',
        name: 'カオパッドクン',
        description: 'エビ入りタイ風チャーハン',
      },
      {
        language: 'zh',
        name: '虾仁炒饭',
        description: '泰式虾仁炒饭',
      },
    ],
  },
  // Chicken Rice
  {
    subcategory_key: 'khao_mun_gai',
    protein_type_key: 'chicken',
    key: 'khao_mun_gai_tom',
    image_url: 'https://images.unsplash.com/photo-1606491956689-2ea866880c84',
    contains: ['jasmine_rice', 'chicken', 'ginger', 'garlic', 'soy_sauce'],
    meal_time: MealTime.LUNCH,
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Hainanese Chicken Rice',
        description: 'Thai-style chicken rice with ginger sauce',
      },
      {
        language: 'th',
        name: 'ข้าวมันไก่ต้ม',
        description: 'ข้าวมันไก่ต้มเสิร์ฟพร้อมน้ำจิ้ม',
      },
      {
        language: 'jp',
        name: 'カオマンガイトム',
        description: 'タイ風海南チキンライス',
      },
      {
        language: 'zh',
        name: '白切鸡饭',
        description: '泰式海南白切鸡饭',
      },
    ],
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

    const existingMenu = await prisma.menu.findUnique({
      where: { key: menu.key },
    });

    if (existingMenu) {
      console.log(`⚠️  Menu already exists: ${menu.key}`);
      continue;
    }

    const createdMenu = await prisma.menu.create({
      data: {
        key: menu.key,
        subcategory_id: subcategory.id,
        protein_type_id: proteinType?.id,
        image_url: menu.image_url,
        contains: menu.contains,
        meal_time: menu.meal_time,
        is_active: menu.is_active,
        Translations: {
          create: menu.translations,
        },
      },
      include: {
        Translations: true,
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
    
    console.log(`✅ Created menu: ${createdMenu.key}`);
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