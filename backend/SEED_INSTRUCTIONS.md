# Database Seeding Instructions

## 🌱 Food Types Seed Data

This seed script populates your database with comprehensive food management data including:

### 📊 **Data Structure**
- **3 Food Types**: Asian Food, Western Food, Desserts
- **6 Categories**: Thai, Japanese, Chinese, Italian, American, Cakes, Ice Cream
- **15+ Subcategories**: Noodles, Curry, Sushi, Pasta, Pizza, etc.
- **6 Protein Types**: Chicken, Beef, Pork, Seafood, Vegetarian, Vegan
- **4 Languages**: English, Thai, Japanese, Chinese translations

### 🗃️ **Included Data**

#### **Asian Food**
- **Thai Cuisine**
  - Thai Noodles (ก๋วยเตี๋ยว)
  - Thai Curry (แกง)  
  - Thai Soup (ต้มยำ)
  - Thai Salad (ยำ)

- **Japanese Cuisine**
  - Sushi (寿司)
  - Ramen (ラーメン)
  - Tempura (天ぷら)

- **Chinese Cuisine** 
  - Dim Sum (点心)
  - Stir Fry (炒菜)

#### **Western Food**
- **Italian Cuisine**
  - Pasta (意面)
  - Pizza (披萨)
  - Risotto (意式炖饭)

- **American Cuisine**
  - Burgers (汉堡)
  - Steaks (牛排)

#### **Desserts**
- **Cakes**
  - Chocolate Cakes
  - Fruit Cakes

- **Ice Cream**
  - Gelato

#### **Protein Types**
- Chicken (ไก่ / 鶏肉 / 鸡肉)
- Beef (เนื้อวัว / 牛肉)
- Pork (หมู / 豚肉 / 猪肉) 
- Seafood (อาหารทะเล / シーフード / 海鲜)
- Vegetarian (มังสวิรัติ / ベジタリアン / 素食)
- Vegan (เจ / ヴィーガン / 纯素)

## 🚀 **How to Run**

### **Prerequisites**
```bash
# Install dependencies
npm install

# Make sure Prisma is set up
npm run prisma:generate
```

### **Run Seeding**
```bash
# Seed database with food types data
npm run db:seed

# Or run directly
npm run prisma:seed

# Reset database and reseed (CAUTION: This will delete all data!)
npm run db:reset
```

### **Available Commands**
- `npm run db:seed` - Run seed script only
- `npm run db:reset` - Reset database and reseed (deletes all data)
- `npm run prisma:seed` - Direct seed command
- `npm run prisma:migrate` - Run migrations
- `npm run prisma:generate` - Generate Prisma client

## ✅ **What You'll Get**

After running the seed:
1. **Complete food taxonomy** ready for menu creation
2. **Multi-language support** for international apps  
3. **Protein type classification** for dietary preferences
4. **Hierarchical structure** (Food Types → Categories → Subcategories)
5. **Admin panel data** ready to use immediately

## 🔍 **Verify Seeding**

Check your database tables:
- `food_types` - 3 entries
- `categories` - 6+ entries  
- `subcategories` - 15+ entries
- `protein_types` - 6 entries
- `*_translations` - Multiple language entries

Your admin panel will now show real data instead of empty states!

## 🛠️ **Customization**

To customize the seed data:
1. Edit `prisma/seed.ts`
2. Modify the `seedData` object
3. Add/remove food types, categories, or translations
4. Run `npm run db:seed` again

## 🔧 **Troubleshooting**

**Error: "Table doesn't exist"**
```bash
npm run prisma:migrate
npm run prisma:generate
npm run db:seed
```

**Error: "tsx not found"**
```bash
npm install tsx --save-dev
```

**Want to start fresh?**
```bash
npm run db:reset  # CAUTION: Deletes all data!
```