import { PrismaClient, MealTime } from '@prisma/client';

const prisma = new PrismaClient();

export const menuSeedData = [
  // Rice Dishes - Pad Kaprao
  {
    subcategory_key: 'pad_kaprao',
    protein_type_key: 'chicken',
    key: 'pad_kaprao_gai',
    image_url: 'https://images.unsplash.com/photo-1627308595186-e6bb36712645?q=80&w=735&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
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
    image_url: 'https://images.unsplash.com/photo-1627308595186-e6bb36712645?q=80&w=735&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
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
    image_url: 'https://images.unsplash.com/photo-1655091273851-7bdc2e578a88?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
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
    image_url: 'https://cdn.pixabay.com/photo/2014/11/05/16/00/thai-food-518035_1280.jpg',
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
    image_url: 'https://images.pexels.com/photos/15797972/pexels-photo-15797972.jpeg',
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
    image_url: 'https://images.pexels.com/photos/12210730/pexels-photo-12210730.jpeg',
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
    image_url: 'https://images.unsplash.com/photo-1648421331147-9fcfab29536e?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
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
    image_url: 'https://images.unsplash.com/photo-1512058564366-18510be2db19',
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
    image_url: 'https://img.freepik.com/free-photo/steamed-chicken-with-rice_1248162.jpg',
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
    image_url: 'https://images.pexels.com/photos/12824401/pexels-photo-12824401.jpeg',
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

  // Khao Gaeng - Rice with Curry
  {
    subcategory_key: 'khao_gaeng',
    protein_type_key: 'pork',
    key: 'khao_gaeng_moo',
    image_url: 'https://images.pexels.com/photos/15797959/pexels-photo-15797959.jpeg',
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
    image_url: 'https://img.freepik.com/free-photo/steamed-chicken-with-rice_1248162.jpg',
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
    image_url: 'https://img.freepik.com/free-photo/fried-noodle-with-pork-soy-sauce-vegetable_10726356.jpg',
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
    image_url: 'https://img.freepik.com/free-photo/stir-fried-noodle-pork-basil_1248106.jpg',
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


  // More Curry - Red Curry
  {
    subcategory_key: 'gaeng_phed',
    protein_type_key: 'chicken',
    key: 'gaeng_phed_gai',
    image_url: 'https://images.pexels.com/photos/15797959/pexels-photo-15797959.jpeg',
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
    protein_type_key: null,
    key: 'gaeng_massaman',
    image_url: 'https://images.pexels.com/photos/15797933/pexels-photo-15797933.jpeg',
    contains: ['massaman_paste', 'coconut_milk', 'potatoes', 'peanuts'],
    meal_time: MealTime.DINNER,
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Massaman Curry',
        description: 'Rich Thai massaman curry with potatoes',
      },
      {
        language: 'th',
        name: 'แกงมัสมั่น',
        description: 'แกงมัสมั่นใส่มันฝรั่งและถั่วลิสง',
      },
      {
        language: 'jp',
        name: 'マッサマンカレー',
        description: 'タイマッサマンカレー',
      },
      {
        language: 'zh',
        name: '马沙文咖喱',
        description: '泰式马沙文咖喱',
      },
    ],
  },

  // Yam Wun Sen - Glass Noodle Salad
  {
    subcategory_key: 'yam_wun_sen',
    protein_type_key: null,
    key: 'yam_wun_sen',
    image_url: 'https://images.pexels.com/photos/15797948/pexels-photo-15797948.jpeg',
    contains: ['glass_noodles', 'lime', 'chilies'],
    meal_time: MealTime.LUNCH,
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Glass Noodle Salad',
        description: 'Spicy Thai glass noodle salad',
      },
      {
        language: 'th',
        name: 'ยำวุ้นเส้น',
        description: 'ยำวุ้นเส้นเปรี้ยวเผ็ด',
      },
      {
        language: 'jp',
        name: 'ヤムウンセン',
        description: '春雨サラダ',
      },
      {
        language: 'zh',
        name: '粉丝沙拉',
        description: '泰式粉丝沙拉',
      },
    ],
  },
  // Khao Na - Rice with Topping
  {
    subcategory_key: 'khao_na',
    protein_type_key: 'beef',
    key: 'khao_na',
    image_url: 'https://images.unsplash.com/photo-1711112830426-9f8a36df9a14?q=80&w=1374&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    contains: ['jasmine_rice', 'vegetables', 'soy_sauce'],
    meal_time: MealTime.LUNCH,
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Rice with Topping',
        description: 'Thai rice topped with protein and vegetables',
      },
      {
        language: 'th',
        name: 'ข้าวหน้า',
        description: 'ข้าวราดหน้าและผักรวม',
      },
      {
        language: 'jp',
        name: 'カオナー',
        description: 'のせご飯',
      },
      {
        language: 'zh',
        name: '盖饭',
        description: '泰式盖饭',
      },
    ],
  },
  // Khao Soi - Northern Thai Curry Noodles
  {
    subcategory_key: 'khao_soi',
    protein_type_key: null,
    key: 'khao_soi',
    image_url: 'https://images.unsplash.com/photo-1565791955315-def31c729d58?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1yZWxhdGVkfDE3fHx8ZW58MHx8fHx8',
    contains: ['egg_noodles', 'coconut_milk', 'curry_paste', 'crispy_noodles'],
    meal_time: MealTime.LUNCH,
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Khao Soi',
        description: 'Northern Thai curry noodle soup',
      },
      {
        language: 'th',
        name: 'ข้าวซอย',
        description: 'ข้าวซอยเส้นนิ่มและกรอบ',
      },
      {
        language: 'jp',
        name: 'カオソイ',
        description: '北タイ風カレー麺',
      },
      {
        language: 'zh',
        name: '咖喱面',
        description: '泰北咖喱面',
      },
    ],
  },
  // Tom Yum - Spicy Soup
  {
    subcategory_key: 'tom_yum',
    protein_type_key: null,
    key: 'tom_yum',
    image_url: 'https://images.unsplash.com/photo-1571809839227-b2ac3d261257?q=80&w=880&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    contains: ['lemongrass', 'kaffir_lime_leaves', 'galangal', 'chilies', 'lime', 'mushrooms'],
    meal_time: MealTime.DINNER,
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Tom Yum',
        description: 'Spicy Thai soup with herbs and vegetables',
      },
      {
        language: 'th',
        name: 'ต้มยำ',
        description: 'ต้มยำน้ำใสเปรี้ยวเผ็ด',
      },
      {
        language: 'jp',
        name: 'トムヤム',
        description: 'タイ風酸辣スープ',
      },
      {
        language: 'zh',
        name: '冬阴功汤',
        description: '泰式酸辣汤',
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