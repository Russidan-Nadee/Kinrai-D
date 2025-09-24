import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { LanguageService } from './services/language.service';
import { SearchService } from './services/search.service';
import { CacheService } from './services/cache.service';
import { LoggingService } from './services/logging.service';
import { CacheInterceptor } from './interceptors/cache.interceptor';
import { LoggingInterceptor } from './interceptors/logging.interceptor';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule, ConfigModule],
  providers: [
    LanguageService,
    SearchService,
    CacheService,
    LoggingService,
    CacheInterceptor,
    LoggingInterceptor,
  ],
  exports: [
    LanguageService,
    SearchService,
    CacheService,
    LoggingService,
    CacheInterceptor,
    LoggingInterceptor,
  ],
})
export class CommonModule {}
