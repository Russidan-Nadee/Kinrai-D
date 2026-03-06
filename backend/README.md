# Kinrai-D Backend API

NestJS-based REST API for Kinrai-D food menu management system. Provides comprehensive endpoints for menu management, user preferences, recommendations, and admin operations.

## 🚀 Quick Start

### Prerequisites
- Node.js 22+
- PostgreSQL 13+
- npm or yarn

### Installation

```bash
# Install dependencies
npm install

# Setup environment variables
cp .env.example .env

# Generate Prisma client
npm run prisma:generate

# Create and seed database
npm run db:reset
```

### Running the Server

```bash
# Development (watch mode)
npm run start:dev

# Debug mode
npm run start:debug

# Production
npm run build && npm run start:prod
```

Server will be available at `http://localhost:3000/api/v1`

## 📚 API Documentation

### Swagger UI
Interactive API documentation available at:
```
http://localhost:3000/api/docs
```

### Health Endpoints

```bash
# Basic health check
GET /api/v1/health

# Database connection test
GET /api/v1/health/db

# Environment configuration (dev only)
GET /api/v1/health/env

# Connection pool benchmark
GET /api/v1/health/connection-test
```

## 🔑 Core Features

### Menu Management
- Create, read, update, delete menus
- Support for multiple languages
- Categorization by food type, category, subcategory
- Protein type filtering
- Meal time classification (Breakfast, Lunch, Dinner, Snack)

### User Management
- User profile creation and updates
- Role-based access (USER, ADMIN)
- Supabase authentication integration
- User profile statistics

### Recommendations Engine
- Random menu suggestions
- Personalized recommendations based on:
  - Favorite history
  - Disliked menus
  - Protein preferences
  - Rating patterns
- Search with full-text support

### Analytics
- Popular menu tracking
- Meal time distribution analysis
- Protein preference analytics
- Rating trends
- User engagement metrics

### Admin Dashboard
- User management and activation/deactivation
- Menu management interface
- Category and protein type management
- Dashboard statistics and recent activity
- Batch operations support

## 🏗️ Project Structure

```
src/
├── auth/
│  ├── decorators/        # Custom decorators (@CurrentUser, @UserId, etc.)
│  ├── guards/            # JWT & permission guards
│  └── dto/               # Auth DTOs
├── admin/
│  ├── controllers/       # Admin endpoints
│  ├── services/          # Admin business logic
│  └── dto/               # Admin DTOs
├── food-management/
│  ├── services/          # Food type & category services
│  ├── controllers/       # Food management endpoints
│  └── dto/               # Food management DTOs
├── menus/
│  ├── menus.service.ts   # Core menu service
│  ├── menus.controller.ts # Menu endpoints
│  └── dto/               # Menu DTOs
├── user-profiles/
│  ├── services/          # User profile logic
│  ├── controllers/       # User endpoints
│  └── dto/               # User DTOs
├── favorites/
│  ├── favorites.service.ts # Favorite management
│  └── favorites.controller.ts # Favorite endpoints
├── ratings/
│  └── Rating system      # Menu ratings & reviews
├── protein-preferences/
│  └── User dietary restrictions
├── analytics/
│  ├── analytics.service.ts # Analytics calculations
│  └── analytics.controller.ts # Analytics endpoints
├── queues/
│  ├── processors/        # Job processors
│  └── jobs.controller.ts # Queue management
├── common/
│  ├── interceptors/      # Global interceptors
│  ├── services/          # Shared services (Cache, Search)
│  ├── decorators/        # Shared decorators
│  └── types/             # Type definitions
├── health/
│  └── Health check endpoints
├── prisma/
│  └── Prisma ORM service
└── app.module.ts         # Root module
```

## 📦 Key Dependencies

```json
{
  "@nestjs/core": "^11.1.5",
  "@nestjs/common": "^11.0.1",
  "@nestjs/config": "^4.0.2",
  "@prisma/client": "^6.13.0",
  "bull": "^4.16.5",
  "ioredis": "^5.7.0",
  "@supabase/supabase-js": "^2.75.0",
  "class-validator": "^0.14.2",
  "class-transformer": "^0.5.1"
}
```

## 🔌 API Endpoints

### Menus
```
GET    /api/v1/menus                    # Get all menus
POST   /api/v1/menus                    # Create menu
GET    /api/v1/menus/:id                # Get menu details
PATCH  /api/v1/menus/:id                # Update menu
DELETE /api/v1/menus/:id                # Delete menu
GET    /api/v1/menus/popular            # Get popular menus
GET    /api/v1/menus/random             # Get random menu
GET    /api/v1/menus/random/personalized # Get recommendation
GET    /api/v1/menus/search             # Full-text search
```

### User Profiles
```
POST   /api/v1/user-profiles            # Create profile
GET    /api/v1/user-profiles/me         # Get current user
PATCH  /api/v1/user-profiles/me         # Update profile
GET    /api/v1/user-profiles/me/stats   # User statistics
```

### Favorites
```
POST   /api/v1/favorites                # Add to favorites
DELETE /api/v1/favorites/:id            # Remove favorite
GET    /api/v1/favorites                # Get user favorites
GET    /api/v1/favorites/check/:menuId  # Check if favorite
```

### Admin
```
GET    /api/v1/admin/dashboard/stats    # Dashboard stats
GET    /api/v1/admin/users              # List users
POST   /api/v1/admin/users              # Create user
GET    /api/v1/admin/analytics/*        # Analytics endpoints
```

## 🧪 Testing

### Unit Tests
```bash
npm run test              # Run all tests
npm run test:watch       # Watch mode
npm run test:cov         # Coverage report
npm run test:debug       # Debug mode
```

### E2E Tests
```bash
npm run test:e2e         # Run end-to-end tests
```

## 🔧 Configuration

### Environment Variables

```env
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/kinrai_db

# Supabase Authentication
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Server
NODE_ENV=development|production
PORT=3000
LOG_LEVEL=debug|log|error

# CORS
CORS_ORIGINS=http://localhost:3000,https://example.com

# Frontend
FRONTEND_URL=http://localhost:3000
```

## 🚀 Production Deployment

### Docker

```bash
# Build
docker build -t kinrai-d-api:latest .

# Run
docker run -p 3000:3000 \
  -e DATABASE_URL="postgresql://..." \
  -e NODE_ENV=production \
  kinrai-d-api:latest
```

### Railway

```bash
# Deploy via Railway CLI
railway up
```

## 🔐 Security

- ✅ Environment variables for all secrets
- ✅ Supabase authentication
- ✅ CORS protection
- ✅ Input validation (class-validator)
- ✅ SQL injection protection (Prisma)
- ✅ Credentials removed from logs
- ✅ Role-based access control (RBAC)
- ✅ Global error handling

## 📖 Documentation

- [Root README](../README.md)
- [Frontend Documentation](../frontend/README.md)
- [Database Schema](prisma/schema.prisma)
- [Prisma Docs](https://www.prisma.io/docs/)
- [NestJS Docs](https://docs.nestjs.com/)

## 📄 License

UNLICENSED - Private Project

---

**Version**: 1.0.0  
**Last Updated**: March 6, 2026
