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
        language: 'jp',
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
        language: 'jp',
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
        language: 'jp',
        name: '牛肉',
      },
      {
        language: 'zh',
        name: '牛肉',
      },
    ],
  },
  {
    key: 'seafood',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Seafood',
      },
      {
        language: 'th',
        name: 'อาหารทะเล',
      },
      {
        language: 'jp',
        name: 'シーフード',
      },
      {
        language: 'zh',
        name: '海鲜',
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
        language: 'jp',
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
        language: 'jp',
        name: 'ヴィーガン',
      },
      {
        language: 'zh',
        name: '纯素',
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
        language: 'jp',
        name: '鴨肉',
      },
      {
        language: 'zh',
        name: '鸭肉',
      },
    ],
  },
  {
    key: 'mixed_protein',
    is_active: true,
    translations: [
      {
        language: 'en',
        name: 'Mixed Protein',
      },
      {
        language: 'th',
        name: 'โปรตีนรวม',
      },
      {
        language: 'jp',
        name: 'ミックスプロテイン',
      },
      {
        language: 'zh',
        name: '混合蛋白',
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
        language: 'jp',
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