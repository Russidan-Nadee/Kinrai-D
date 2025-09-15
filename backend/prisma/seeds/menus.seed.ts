import { PrismaClient, MealTime } from '@prisma/client';

const prisma = new PrismaClient();

export const menuSeedData = [
  // Rice Dishes - Pad Kaprao
  {
    subcategory_key: 'pad_kaprao',
    protein_type_key: 'chicken',
    key: 'pad_kaprao_gai',
    image_url: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624',
    contains: ['basil', 'chilies', 'garlic', 'soy_sauce', 'oyster_sauce'],
    meal_time: MealTime.LUNCH,
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Pad Kaprao',
        description: 'Stir-fried with Thai basil over rice',
      },
      {
        language: 'th',
        name: 'ผัดกะเพรา',
        description: 'ข้าวผัดกะเพราใส่ไข่ดาว',
      },
      {
        language: 'jp',
        name: 'パッカパオ',
        description: 'タイバジル炒めライス',
      },
      {
        language: 'zh',
        name: '打抛叶炒饭',
        description: '泰式罗勒叶炒饭',
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

  // More Rice Dishes - Pad Prik Gaeng
  {
    subcategory_key: 'pad_prik_gaeng',
    protein_type_key: 'pork',
    key: 'pad_prik_gaeng_moo',
    image_url: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624',
    contains: ['curry_paste', 'pork', 'vegetables', 'soy_sauce'],
    meal_time: MealTime.LUNCH,
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Pad Prik Gaeng Pork',
        description: 'Stir-fried pork with curry paste over rice',
      },
      {
        language: 'th',
        name: 'ผัดพริกแกงหมู',
        description: 'ข้าวผัดพริกแกงหมูใส่ผักรวม',
      },
      {
        language: 'jp',
        name: 'パッピックゲーンムー',
        description: 'カレーペースト炒め豚肉ライス',
      },
      {
        language: 'zh',
        name: '咖喱酱炒猪肉饭',
        description: '咖喱酱炒猪肉盖饭',
      },
    ],
  },

  // Khao Pad - Fried Rice
  {
    subcategory_key: 'khao_pad',
    protein_type_key: 'shrimp',
    key: 'khao_pad_goong',
    image_url: 'https://images.unsplash.com/photo-1512058564366-18510be2db19',
    contains: ['rice', 'shrimp', 'egg', 'vegetables', 'soy_sauce'],
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
        description: 'ข้าวผัดกุ้งใส่ไข่และผักรวม',
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

  // Khao Gaeng - Rice with Curry
  {
    subcategory_key: 'khao_gaeng',
    protein_type_key: 'pork',
    key: 'khao_gaeng_moo',
    image_url: 'https://images.unsplash.com/photo-1631515243349-e0cb75fb8d3a',
    contains: ['rice', 'curry', 'pork', 'vegetables'],
    meal_time: MealTime.LUNCH,
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Rice with Pork Curry',
        description: 'Steamed rice with pork curry',
      },
      {
        language: 'th',
        name: 'ข้าวแกงหมู',
        description: 'ข้าวราดแกงหมูใส่ผักรวม',
      },
      {
        language: 'jp',
        name: 'カオゲーンムー',
        description: '豚肉カレーかけご飯',
      },
      {
        language: 'zh',
        name: '猪肉咖喱拌饭',
        description: '猪肉咖喱拌饭',
      },
    ],
  },

  // Khao Mun Gai - Chicken Rice
  {
    subcategory_key: 'khao_mun_gai',
    protein_type_key: 'chicken',
    key: 'khao_mun_gai_tom',
    image_url: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b',
    contains: ['rice', 'chicken', 'ginger', 'garlic', 'soy_sauce'],
    meal_time: MealTime.LUNCH,
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Hainanese Chicken Rice',
        description: 'Thai-style Hainanese chicken rice',
      },
      {
        language: 'th',
        name: 'ข้าวมันไก่ต้ม',
        description: 'ข้าวมันไก่ต้มใส่น้ำจิ้ม',
      },
      {
        language: 'jp',
        name: 'カオマンガイトム',
        description: 'タイ風海南鶏飯',
      },
      {
        language: 'zh',
        name: '海南鸡饭',
        description: '泰式海南鸡饭',
      },
    ],
  },

  // More Noodles - Pad See Ew
  {
    subcategory_key: 'pad_see_ew',
    protein_type_key: 'pork',
    key: 'pad_see_ew_moo',
    image_url: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624',
    contains: ['wide_noodles', 'pork', 'chinese_broccoli', 'dark_soy_sauce', 'egg'],
    meal_time: MealTime.LUNCH,
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Pad See Ew Pork',
        description: 'Stir-fried wide noodles with pork in dark soy sauce',
      },
      {
        language: 'th',
        name: 'ผัดซีอิ๊วหมู',
        description: 'ผัดซีอิ๊วเส้นใหญ่หมูใส่คะน้า',
      },
      {
        language: 'jp',
        name: 'パッシーユームー',
        description: '豚肉入り醤油炒め麺',
      },
      {
        language: 'zh',
        name: '猪肉炒河粉',
        description: '老抽猪肉炒河粉',
      },
    ],
  },

  // Pad Kee Mao - Drunken Noodles
  {
    subcategory_key: 'pad_kee_mao',
    protein_type_key: 'chicken',
    key: 'pad_kee_mao_gai',
    image_url: 'https://images.unsplash.com/photo-1559314809-0f31657def5e',
    contains: ['wide_noodles', 'chicken', 'basil', 'chilies', 'vegetables'],
    meal_time: MealTime.DINNER,
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Drunken Noodles Chicken',
        description: 'Spicy stir-fried noodles with chicken and basil',
      },
      {
        language: 'th',
        name: 'ผัดขี้เมาไก่',
        description: 'เส้นใหญ่ผัดเผ็ดไก่ใส่กะเพรา',
      },
      {
        language: 'jp',
        name: 'パッキーマオガイ',
        description: 'チキン入りスパイシー炒め麺',
      },
      {
        language: 'zh',
        name: '鸡肉醉面',
        description: '泰式辣炒鸡肉河粉',
      },
    ],
  },

  // Ba Mee - Egg Noodles
  {
    subcategory_key: 'ba_mee',
    protein_type_key: 'pork',
    key: 'ba_mee_moo_daeng',
    image_url: 'https://images.unsplash.com/photo-1555126634-323283e090fa',
    contains: ['egg_noodles', 'red_pork', 'wonton', 'vegetables', 'broth'],
    meal_time: MealTime.BREAKFAST,
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Egg Noodles with Red Pork',
        description: 'Thai egg noodle soup with red pork and wonton',
      },
      {
        language: 'th',
        name: 'บะหมี่หมูแดง',
        description: 'บะหมี่น้ำหมูแดงใส่เกี๊ยว',
      },
      {
        language: 'jp',
        name: 'バミームーデーン',
        description: 'チャーシュー入りタイ風卵麺',
      },
      {
        language: 'zh',
        name: '叉烧面条',
        description: '泰式叉烧蛋面',
      },
    ],
  },

  // More Curry - Red Curry
  {
    subcategory_key: 'gaeng_phed',
    protein_type_key: 'chicken',
    key: 'gaeng_phed_gai',
    image_url: 'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd',
    contains: ['red_curry_paste', 'coconut_milk', 'chicken', 'eggplant', 'basil'],
    meal_time: MealTime.DINNER,
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Red Curry Chicken',
        description: 'Traditional Thai red curry with chicken',
      },
      {
        language: 'th',
        name: 'แกงเผ็ดไก่',
        description: 'แกงเผ็ดไก่ใส่มะเขือและใบกะเพรา',
      },
      {
        language: 'jp',
        name: 'レッドカレーチキン',
        description: '伝統的なタイレッドカレー',
      },
      {
        language: 'zh',
        name: '红咖喱鸡',
        description: '传统泰式红咖喱鸡肉',
      },
    ],
  },

  // Massaman Curry
  {
    subcategory_key: 'gaeng_massaman',
    protein_type_key: 'beef',
    key: 'gaeng_massaman_neua',
    image_url: 'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd',
    contains: ['massaman_paste', 'coconut_milk', 'beef', 'potatoes', 'peanuts'],
    meal_time: MealTime.DINNER,
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Massaman Curry Beef',
        description: 'Rich Thai massaman curry with tender beef',
      },
      {
        language: 'th',
        name: 'แกงมัสมั่นเนื้อ',
        description: 'แกงมัสมั่นเนื้อใส่มันฝรั่งและถั่วลิสง',
      },
      {
        language: 'jp',
        name: 'マッサマンカレービーフ',
        description: '牛肉入りタイマッサマンカレー',
      },
      {
        language: 'zh',
        name: '牛肉马沙文咖喱',
        description: '泰式马沙文牛肉咖喱',
      },
    ],
  },

  // Yam Wun Sen - Glass Noodle Salad
  {
    subcategory_key: 'yam_wun_sen',
    protein_type_key: 'shrimp',
    key: 'yam_wun_sen_goong',
    image_url: 'https://images.unsplash.com/photo-1512058564366-18510be2db19',
    contains: ['glass_noodles', 'shrimp', 'pork', 'lime', 'chilies'],
    meal_time: MealTime.LUNCH,
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Glass Noodle Salad with Shrimp',
        description: 'Spicy Thai glass noodle salad with shrimp',
      },
      {
        language: 'th',
        name: 'ยำวุ้นเส้นกุ้ง',
        description: 'ยำวุ้นเส้นกุ้งและหมูยอเปรี้ยวเผ็ด',
      },
      {
        language: 'jp',
        name: 'ヤムウンセンクン',
        description: 'エビ入り春雨サラダ',
      },
      {
        language: 'zh',
        name: '虾仁粉丝沙拉',
        description: '泰式虾仁粉丝沙拉',
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