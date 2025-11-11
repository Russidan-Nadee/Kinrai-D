import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const proteinTypeSeedData = [
  {
    key: 'chicken',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Chicken',
      },
      {
        language: 'th',
        name: 'ไก่',
      },
      {
        language: 'ja',
        name: '鶏肉',
      },
      {
        language: 'zh',
        name: '鸡肉',
      },
    ],
  },
  {
    key: 'pork',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Pork',
      },
      {
        language: 'th',
        name: 'หมู',
      },
      {
        language: 'ja',
        name: '豚肉',
      },
      {
        language: 'zh',
        name: '猪肉',
      },
    ],
  },
  {
    key: 'beef',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Beef',
      },
      {
        language: 'th',
        name: 'เนื้อวัว',
      },
      {
        language: 'ja',
        name: '牛肉',
      },
      {
        language: 'zh',
        name: '牛肉',
      },
    ],
  },
  {
    key: 'fish',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Fish',
      },
      {
        language: 'th',
        name: 'ปลา',
      },
      {
        language: 'ja',
        name: '魚',
      },
      {
        language: 'zh',
        name: '鱼',
      },
    ],
  },
  {
    key: 'squid',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Squid',
      },
      {
        language: 'th',
        name: 'หมึก',
      },
      {
        language: 'ja',
        name: 'イカ',
      },
      {
        language: 'zh',
        name: '鱿鱼',
      },
    ],
  },
  {
    key: 'shellfish',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Shellfish',
      },
      {
        language: 'th',
        name: 'หอย',
      },
      {
        language: 'ja',
        name: '貝',
      },
      {
        language: 'zh',
        name: '贝类',
      },
    ],
  },
  {
    key: 'crab',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Crab',
      },
      {
        language: 'th',
        name: 'ปู',
      },
      {
        language: 'ja',
        name: 'カニ',
      },
      {
        language: 'zh',
        name: '螃蟹',
      },
    ],
  },
  {
    key: 'duck',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Duck',
      },
      {
        language: 'th',
        name: 'เป็ด',
      },
      {
        language: 'ja',
        name: '鴨肉',
      },
      {
        language: 'zh',
        name: '鸭肉',
      },
    ],
  },
  {
    key: 'vegetarian',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Vegetarian',
      },
      {
        language: 'th',
        name: 'มังสวิรัติ',
      },
      {
        language: 'ja',
        name: 'ベジタリアン',
      },
      {
        language: 'zh',
        name: '素食',
      },
    ],
  },
  {
    key: 'vegan',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Vegan',
      },
      {
        language: 'th',
        name: 'เจ',
      },
      {
        language: 'ja',
        name: 'ヴィーガン',
      },
      {
        language: 'zh',
        name: '纯素',
      },
    ],
  },
  {
    key: 'shrimp',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Shrimp',
      },
      {
        language: 'th',
        name: 'กุ้ง',
      },
      {
        language: 'ja',
        name: 'エビ',
      },
      {
        language: 'zh',
        name: '虾',
      },
    ],
  },
];

export async function seedProteinTypes() {
  console.log('🥩 Seeding protein types...');
  
  for (const proteinType of proteinTypeSeedData) {
    const existingProteinType = await prisma.proteinType.findUnique({
      where: { key: proteinType.key },
    });

    if (existingProteinType) {
      console.log(`⚠️  Protein type already exists: ${proteinType.key}`);
      continue;
    }

    const createdProteinType = await prisma.proteinType.create({
      data: {
        key: proteinType.key,
        is_active: proteinType.is_active,
        Translations: {
          create: proteinType.translations,
        },
      },
      include: {
        Translations: true,
      },
    });
    
    console.log(`✅ Created protein type: ${createdProteinType.key}`);
  }
  
  console.log('🎉 Protein types seeding completed!');
}

// Run if this file is executed directly
if (require.main === module) {
  seedProteinTypes()
    .then(async () => {
      await prisma.$disconnect();
    })
    .catch(async (e) => {
      console.error('❌ Error seeding protein types:', e);
      await prisma.$disconnect();
      process.exit(1);
    });
}