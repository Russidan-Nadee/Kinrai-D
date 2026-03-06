# Kinrai-D

A comprehensive food menu management and recommendation system for university canteens. This project provides a modern mobile interface and robust API backend to manage menus, user preferences, and personalized recommendations.

## 🎯 Project Overview

**Kinrai-D** (Kinrai - Diet) is a fullstack application designed to:
- Display university canteen menus with multi-language support
- Allow users to manage dietary preferences and protein type restrictions
- Track favorite menus and meal ratings
- Provide personalized menu recommendations based on user preferences
- Generate analytics on menu popularity and eating patterns
- Provide admin dashboard for menu management

## 📚 Tech Stack

### Backend
- **Framework**: NestJS 11 (Node.js)
- **Language**: TypeScript 5.7
- **Database**: PostgreSQL with Prisma ORM
- **Authentication**: Supabase
- **Queue System**: Bull (Redis-based job queue)
- **Deployment**: Docker, Railway

### Frontend
- **Framework**: Flutter 3.8+
- **Package Management**: Pub
- **State Management**: Provider
- **Backend Integration**: Supabase, REST API
- **Local Storage**: Hive, SharedPreferences
- **Internationalization**: Intl, Flutter Localizations

## 📁 Project Structure

```
kinrai-d/
├── backend/              # NestJS REST API
│  ├── src/
│  │  ├── auth/          # Authentication & authorization
│  │  ├── food-management/ # Food types, categories
│  │  ├── menus/         # Menu management
│  │  ├── user-profiles/ # User profile management
│  │  ├── favorites/     # Favorite menus
│  │  ├── ratings/       # Menu ratings
│  │  ├── protein-preferences/ # Dietary preferences
│  │  ├── analytics/     # Analytics & recommendations
│  │  ├── admin/         # Admin dashboard
│  │  ├── common/        # Shared utilities
│  │  └── health/        # Health checks
│  ├── prisma/           # Database schema & migrations
│  └── test/             # E2E tests
├── frontend/            # Flutter mobile app
│  ├── lib/
│  │  ├── core/          # Config, DI, API, cache
│  │  └── features/      # Feature modules
│  ├── assets/           # Images, animations
│  └── build/            # Generated files
├── Dockerfile           # Backend containerization
├── railway.toml         # Railway deployment config
└── README.md           # This file
```

## 🚀 Getting Started

### Prerequisites
- Node.js 22+
- Flutter 3.8+
- PostgreSQL 13+
- Docker (optional, for containerized deployment)
- Git

### Backend Setup

```bash
# Clone and navigate to backend
cd backend

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your database credentials and Supabase config

# Generate Prisma client
npm run prisma:generate

# Run database migrations
npm run prisma:migrate

# Seed initial data
npm run db:seed

# Start development server
npm run start:dev
```

Backend runs on `http://localhost:3000/api/v1` by default.

### Frontend Setup

```bash
# Navigate to frontend
cd frontend

# Get Flutter dependencies
flutter pub get

# Generate code from build runners
flutter pub run build_runner build

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios

# Run on Web
flutter run -d web
```

## 📦 Available Scripts

### Backend

```bash
# Development
npm run start:dev          # Run with watch mode
npm run start:debug        # Run with debugger

# Production
npm run build              # Compile TypeScript
npm run start:prod         # Run compiled code
npm run lint               # Run ESLint

# Database
npm run db:reset           # Reset database & reseed
npm run db:seed            # Seed sample data
npm run prisma:migrate     # Create new migration
npm run prisma:deploy      # Apply migrations to production

# Testing
npm run test               # Run unit tests
npm run test:watch         # Run tests in watch mode
npm run test:cov           # Generate coverage report
npm run test:e2e           # Run end-to-end tests

# Code Quality
npm run format             # Format code with Prettier
npm run lint               # Fix ESLint issues
```

### Frontend

```bash
# Development
flutter run                # Run app
flutter run -d web         # Run on web

# Build
flutter build apk          # Build Android APK
flutter build aab          # Build Android App Bundle
flutter build ios          # Build iOS IPA
flutter build web          # Build web version

# Code Generation
flutter pub run build_runner build      # Generate files
flutter pub run build_runner clean      # Clean generated files

# Analytics
flutter analyze            # Analyze code

# Testing
flutter test               # Run unit tests
```

## 🔐 Environment Variables

### Backend (.env)

```env
# Database
DATABASE_URL=postgresql://user:password@host:5432/kinrai_db?schema=public

# Supabase
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here

# Application
NODE_ENV=development
PORT=3000
LOG_LEVEL=debug

# CORS
CORS_ORIGINS=http://localhost:3000,http://localhost:5173,https://kinrai-d.netlify.app

# Frontend URL
FRONTEND_URL=http://localhost:3000
```

### Frontend

Configure Supabase credentials in:
- `lib/core/config/supabase_config.dart`

API base URL configuration:
- `lib/core/api/api_endpoints.dart`

## 📊 Database Schema

Key models:
- **UserProfile**: User accounts with roles (USER, ADMIN)
- **Menu**: Detailed menu items with categories and protein types
- **Category**: Food categories (Breakfast, Lunch, Dinner)
- **Subcategory**: Menu subcategories
- **ProteinType**: Protein source types (Chicken, Beef, Pork, Fish, Vegetarian)
- **FavoriteMenu**: User favorite menus
- **MenuRating**: User ratings and reviews
- **UserDislike**: Disliked menus with reasons
- **UserProteinPreference**: User dietary restrictions

See [prisma/schema.prisma](backend/prisma/schema.prisma) for complete schema.

## 🔌 API Endpoints

### Health Check
```
GET /api/v1/health          # Basic health status
GET /api/v1/health/db       # Database connection status
GET /api/v1/health/env      # Environment configuration
GET /api/v1/health/connection-test  # Connection benchmark
```

### Menus
```
GET    /api/v1/menus                    # List all menus
POST   /api/v1/menus                    # Create menu
GET    /api/v1/menus/:id                # Get menu details
PATCH  /api/v1/menus/:id                # Update menu
DELETE /api/v1/menus/:id                # Delete menu
GET    /api/v1/menus/random             # Get random menu
GET    /api/v1/menus/random/personalized # Get personalized recommendation
GET    /api/v1/menus/popular            # Get popular menus
GET    /api/v1/menus/search             # Search menus
```

### User Preferences
```
GET    /api/v1/user-profiles/me         # Get current user profile
POST   /api/v1/user-profiles            # Create user profile
PATCH  /api/v1/user-profiles/me         # Update profile
POST   /api/v1/user-profiles/me/dislikes        # Add disliked menu
DELETE /api/v1/user-profiles/me/dislikes/:menuId # Remove dislike
```

### Admin APIs
```
GET    /api/v1/admin/dashboard/stats    # Dashboard statistics
GET    /api/v1/admin/analytics/*        # Analytics endpoints
GET    /api/v1/admin/users              # List users
POST   /api/v1/admin/users              # Create new user
```

Full API documentation available via Swagger: `http://localhost:3000/api/docs`

## 🧪 Testing

### Backend Unit Tests
```bash
npm run test               # Run all tests
npm run test:watch        # Watch mode
npm run test:cov          # Coverage report
npm run test:debug        # Debug mode
```

### Backend E2E Tests
```bash
npm run test:e2e          # Run end-to-end tests
```

### Frontend Tests
```bash
flutter test              # Run all tests
flutter test -v           # Verbose output
```

## 🐳 Docker Deployment

### Build Image
```bash
docker build -t kinrai-d:latest .
```

### Run Container
```bash
docker run -p 3000:3000 \
  -e DATABASE_URL="postgresql://..." \
  -e SUPABASE_URL="https://..." \
  -e SUPABASE_ANON_KEY="..." \
  kinrai-d:latest
```

## 📤 Deployment

### Railway Deployment
This project is configured for [Railway](https://railway.app/) deployment.

Configuration: [railway.toml](railway.toml)

Deployment command:
```bash
railway up
```

Health check endpoint: `/api/v1/health`

### Frontend Deployment
Frontend is deployed on Netlify:
- URL: https://kinrai-d.netlify.app
- Configuration: [vercel.json](frontend/vercel.json)

## 📝 Release Notes

### v1.0.0 (Current)
- ✅ Core menu management system
- ✅ User authentication & profiles
- ✅ Favorite menus & ratings
- ✅ Personalized recommendations
- ✅ Admin dashboard
- ✅ Multi-language support

## 🔒 Security

- Sensitive credentials removed from logs
- Environment variables required for all secrets
- Supabase for secure authentication
- CORS protection enabled
- Input validation via class-validator
- Database connection encryption

## 📖 Documentation

- [Backend API Docs](backend/README.md)
- [Frontend Documentation](frontend/README.md)
- [Database Schema](backend/prisma/schema.prisma)
- [Environment Setup Guide](backend/.env.example)

## 🤝 Contributing

1. Create feature branch: `git checkout -b feature/your-feature`
2. Commit changes: `git commit -am 'Add feature description'`
3. Push to branch: `git push origin feature/your-feature`
4. Submit pull request

## 📄 License

UNLICENSED - Private Project

## 📧 Support

For issues, questions, or suggestions, please contact the development team.

---

**Last Updated**: March 6, 2026
