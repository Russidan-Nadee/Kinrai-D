import { Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bull';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { CommonModule } from '../common/common.module';
import { AdminModule } from '../admin/admin.module';
import { MenusModule } from '../menus/menus.module';
import {
  AnalyticsProcessor,
  ANALYTICS_QUEUE,
} from './processors/analytics.processor';
import {
  BatchOperationsProcessor,
  BATCH_OPERATIONS_QUEUE,
} from './processors/batch-operations.processor';
import { JobsController } from './jobs.controller';

@Module({
  imports: [
    BullModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => ({
        redis: {
          host: configService.get('REDIS_HOST', 'localhost'),
          port: configService.get('REDIS_PORT', 6379),
          password: configService.get('REDIS_PASSWORD'),
          db: configService.get('REDIS_DB', 0),
          maxRetriesPerRequest: null, // Required for Bull
          enableReadyCheck: false,
        },
        defaultJobOptions: {
          attempts: 3,
          backoff: {
            type: 'exponential',
            delay: 1000,
          },
          removeOnComplete: 100, // Keep last 100 completed jobs
          removeOnFail: 500, // Keep last 500 failed jobs
        },
      }),
      inject: [ConfigService],
    }),
    BullModule.registerQueue(
      {
        name: ANALYTICS_QUEUE,
      },
      {
        name: BATCH_OPERATIONS_QUEUE,
      },
    ),
    CommonModule,
    AdminModule,
    MenusModule,
  ],
  controllers: [JobsController],
  providers: [AnalyticsProcessor, BatchOperationsProcessor],
  exports: [BullModule],
})
export class QueuesModule {}
