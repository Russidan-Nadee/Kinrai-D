import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import compression from 'compression';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Enable compression (supports both Brotli and Gzip)
  app.use(
    compression({
      // Only compress responses larger than 1KB
      threshold: 1024,
      // Compression level (0-9): 6 is balanced between speed and compression ratio
      level: 6,
      // Filter: compress all compressible content types
      filter: (req, res) => {
        // Allow clients to opt-out of compression
        if (req.headers['x-no-compression']) {
          return false;
        }
        // Use default compression filter for content-type checking
        const contentType = res.getHeader('Content-Type');
        if (!contentType) {
          return true;
        }
        // Compress text-based content types
        return /json|text|javascript|xml|css|html/.test(
          contentType.toString(),
        );
      },
    }),
  );

  // CORS Configuration
  const corsOrigins = (
    process.env.CORS_ORIGINS?.split(',') || [
      // Production frontend
      'https://kinrai-d.netlify.app',
      // Development
      'http://localhost:3000',
      'http://localhost:5000',
      'http://localhost:8080',
      'http://localhost:8081',
      'http://localhost:3001',
      'http://localhost:4000',
    ]
  ).map((origin) => origin.trim().replace(/\/$/, '')); // Trim whitespace and trailing slash

  app.enableCors({
    origin: (origin, callback) => {
      // Allow requests with no origin (mobile apps, Postman, curl)
      if (!origin) {
        return callback(null, true);
      }

      // Check if origin is in allowed list
      if (corsOrigins.includes(origin)) {
        return callback(null, true);
      }

      // In production, reject unknown origins
      if (process.env.NODE_ENV === 'production') {
        console.warn(`❌ CORS: Rejected origin: ${origin}`);
        return callback(new Error('Not allowed by CORS policy'), false);
      }

      // In development, allow all with warning
      console.warn(`⚠️  CORS: Allowing untrusted origin in dev: ${origin}`);
      return callback(null, true);
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  });

  // Global validation pipe for DTOs
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // Remove unknown properties
      forbidNonWhitelisted: true, // Throw error for unknown properties
      transform: true, // Transform payloads to DTO instances
      transformOptions: {
        enableImplicitConversion: true, // Auto convert string to number, etc.
      },
    }),
  );

  // Global prefix for all routes
  app.setGlobalPrefix('api/v1');

  const port = process.env.PORT || 8000;
  await app.listen(port);

  console.log(`Application is running on: http://localhost:${port}/api/v1`);
  console.log(`CORS enabled for: ${corsOrigins.join(', ')}`);
  console.log(
    `Database: ${process.env.DATABASE_URL ? 'Connected' : 'Not configured'}`,
  );
}

bootstrap();
