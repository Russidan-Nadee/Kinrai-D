import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const subcategorySeedData = [
  // Subcategories for rice_dishes (ข้าวราด)
  {
    category_key: 'rice_dishes',
    key: 'pad_kaprao',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Pad Kaprao',
        description: 'Thai basil stir-fry with rice',
      },
      {
        language: 'th',
        name: 'ผัดกะเพรา',
        description: 'ข้าวผัดกะเพราไก่ หมู เนื้อ',
      },
      {
        language: 'jp',
        name: 'パッカパオ',
        description: 'タイバジル炒めご飯',
      },
      {
        language: 'zh',
        name: '打抛叶炒饭',
        description: '泰式罗勒叶炒饭',
      },
    ],
  },
  {
    category_key: 'rice_dishes',
    key: 'pad_prik_gaeng',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Pad Prik Gaeng',
        description: 'Curry paste stir-fry with rice',
      },
      {
        language: 'th',
        name: 'ผัดพริกแกง',
        description: 'ข้าวผัดพริกแกงหมู ไก่ กุ้ง',
      },
      {
        language: 'jp',
        name: 'パッピックゲーン',
        description: 'カレーペースト炒めご飯',
      },
      {
        language: 'zh',
        name: '咖喱酱炒饭',
        description: '咖喱酱炒饭配肉类',
      },
    ],
  },
  {
    category_key: 'rice_dishes',
    key: 'khao_pad',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Khao Pad',
        description: 'Thai fried rice',
      },
      {
        language: 'th',
        name: 'ข้าวผัด',
        description: 'ข้าวผัดปู ข้าวผัดกุ้ง ข้าวผัดสับปะรด',
      },
      {
        language: 'jp',
        name: 'カオパッド',
        description: 'タイ風チャーハン',
      },
      {
        language: 'zh',
        name: '泰式炒饭',
        description: '蟹肉炒饭、虾仁炒饭、菠萝炒饭',
      },
    ],
  },
  {
    category_key: 'rice_dishes',
    key: 'khao_gaeng',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Khao Gaeng',
        description: 'Rice with curry',
      },
      {
        language: 'th',
        name: 'ข้าวแกง',
        description: 'ข้าวราดแกง ข้าวกับแกงต่างๆ',
      },
      {
        language: 'jp',
        name: 'カオゲーン',
        description: 'カレーかけご飯',
      },
      {
        language: 'zh',
        name: '咖喱拌饭',
        description: '各种咖喱拌饭',
      },
    ],
  },
  {
    category_key: 'rice_dishes',
    key: 'khao_mun_gai',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Khao Mun Gai',
        description: 'Thai-style chicken rice',
      },
      {
        language: 'th',
        name: 'ข้าวมันไก่',
        description: 'ข้าวมันไก่ต้ม ข้าวมันไก่ย่าง',
      },
      {
        language: 'jp',
        name: 'カオマンガイ',
        description: 'タイ風チキンライス',
      },
      {
        language: 'zh',
        name: '海南鸡饭',
        description: '泰式海南鸡饭',
      },
    ],
  },
  // Subcategories for noodles (เส้น)
  {
    category_key: 'noodles',
    key: 'kuay_teow',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Kuay Teow',
        description: 'Thai rice noodle soup',
      },
      {
        language: 'th',
        name: 'ก๋วยเตี๋ยว',
        description: 'ก๋วยเตี๋ยวน้ำใส น้ำตก เส้นใหญ่ เส้นเล็ก',
      },
      {
        language: 'jp',
        name: 'クイッティアオ',
        description: 'タイ風米麺スープ',
      },
      {
        language: 'zh',
        name: '粿条',
        description: '泰式米粉汤',
      },
    ],
  },
  {
    category_key: 'noodles',
    key: 'pad_thai',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Pad Thai',
        description: 'Thai-style stir-fried noodles',
      },
      {
        language: 'th',
        name: 'ผัดไทย',
        description: 'ผัดไทยกุ้ง ไก่ หมู เต้าหู้',
      },
      {
        language: 'jp',
        name: 'パッタイ',
        description: 'タイ風焼きそば',
      },
      {
        language: 'zh',
        name: '泰式炒河粉',
        description: '泰式炒粿条',
      },
    ],
  },
  {
    category_key: 'noodles',
    key: 'pad_see_ew',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Pad See Ew',
        description: 'Stir-fried noodles with dark soy sauce',
      },
      {
        language: 'th',
        name: 'ผัดซีอิ๊ว',
        description: 'ผัดซีอิ๊วเส้นใหญ่ ใส่หมู ไก่ กุ้ง',
      },
      {
        language: 'jp',
        name: 'パッシーユー',
        description: '醤油炒め麺',
      },
      {
        language: 'zh',
        name: '炒河粉',
        description: '老抽炒河粉',
      },
    ],
  },
  {
    category_key: 'noodles',
    key: 'pad_kee_mao',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Pad Kee Mao',
        description: 'Drunken noodles - spicy stir-fried noodles',
      },
      {
        language: 'th',
        name: 'ผัดขี้เมา',
        description: 'เส้นใหญ่ผัดเผ็ด ใส่กะเพรา พริก',
      },
      {
        language: 'jp',
        name: 'パッキーマオ',
        description: 'スパイシー炒め麺',
      },
      {
        language: 'zh',
        name: '醉面',
        description: '泰式辣炒河粉',
      },
    ],
  },
  {
    category_key: 'noodles',
    key: 'ba_mee',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Ba Mee',
        description: 'Thai egg noodles',
      },
      {
        language: 'th',
        name: 'บะหมี่',
        description: 'บะหมี่น้ำ บะหมี่แห้ง วันตัน',
      },
      {
        language: 'jp',
        name: 'バミー',
        description: 'タイ風卵麺',
      },
      {
        language: 'zh',
        name: '面条',
        description: '泰式蛋面',
      },
    ],
  },
  // Subcategories for curry (แกง)
  {
    category_key: 'curry',
    key: 'gaeng_keow_wan',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Green Curry',
        description: 'Thai green curry',
      },
      {
        language: 'th',
        name: 'แกงเขียวหวาน',
        description: 'แกงเขียวหวานไก่ หมู เนื้อ',
      },
      {
        language: 'jp',
        name: 'グリーンカレー',
        description: 'タイグリーンカレー',
      },
      {
        language: 'zh',
        name: '绿咖喱',
        description: '泰式绿咖喱',
      },
    ],
  },
  {
    category_key: 'curry',
    key: 'gaeng_phed',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Red Curry',
        description: 'Thai red curry',
      },
      {
        language: 'th',
        name: 'แกงเผ็ด',
        description: 'แกงเผ็ดไก่ หมู เป็ด',
      },
      {
        language: 'jp',
        name: 'レッドカレー',
        description: 'タイレッドカレー',
      },
      {
        language: 'zh',
        name: '红咖喱',
        description: '泰式红咖喱',
      },
    ],
  },
  {
    category_key: 'curry',
    key: 'gaeng_massaman',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Massaman Curry',
        description: 'Thai massaman curry',
      },
      {
        language: 'th',
        name: 'แกงมัสมั่น',
        description: 'แกงมัสมั่นไก่ เนื้อ',
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
  // Subcategories for salad (ยำ)
  {
    category_key: 'salad',
    key: 'som_tam',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Som Tam',
        description: 'Thai green papaya salad',
      },
      {
        language: 'th',
        name: 'ส้มตำ',
        description: 'ส้มตำไทย ส้มตำปู ส้มตำปลาร้า',
      },
      {
        language: 'jp',
        name: 'ソムタム',
        description: 'タイ風青パパイヤサラダ',
      },
      {
        language: 'zh',
        name: '青木瓜沙拉',
        description: '泰式青木瓜沙拉',
      },
    ],
  },
  {
    category_key: 'salad',
    key: 'yam_wun_sen',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Yam Wun Sen',
        description: 'Glass noodle salad',
      },
      {
        language: 'th',
        name: 'ยำวุ้นเส้น',
        description: 'ยำวุ้นเส้นกุ้ง หมูยอ',
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
];

export async function seedSubcategories() {
  console.log('🏪 Seeding subcategories...');
  
  for (const subcategory of subcategorySeedData) {
    // Find the category first
    const category = await prisma.category.findUnique({
      where: { key: subcategory.category_key },
    });

    if (!category) {
      console.log(`❌ Category not found: ${subcategory.category_key}`);
      continue;
    }

    const existingSubcategory = await prisma.subcategory.findUnique({
      where: { key: subcategory.key },
    });

    if (existingSubcategory) {
      console.log(`⚠️  Subcategory already exists: ${subcategory.key}`);
      continue;
    }

    const createdSubcategory = await prisma.subcategory.create({
      data: {
        key: subcategory.key,
        category_id: category.id,
        is_active: subcategory.is_active,
        Translations: {
          create: subcategory.translations,
        },
      },
      include: {
        Translations: true,
      },
    });
    
    console.log(`✅ Created subcategory: ${createdSubcategory.key}`);
  }
  
  console.log('🎉 Subcategories seeding completed!');
}

// Run if this file is executed directly
if (require.main === module) {
  seedSubcategories()
    .then(async () => {
      await prisma.$disconnect();
    })
    .catch(async (e) => {
      console.error('❌ Error seeding subcategories:', e);
      await prisma.$disconnect();
      process.exit(1);
    });
}