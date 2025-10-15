import { Injectable, OnModuleInit, Logger, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(PrismaService.name);
  private isConnected = false;

  constructor() {
    super({
      datasources: {
        db: {
          url: process.env.DATABASE_URL,
        },
      },
      log: [
        { level: 'query', emit: 'event' },
        { level: 'error', emit: 'stdout' },
        { level: 'warn', emit: 'stdout' },
        { level: 'info', emit: 'stdout' },
      ],
    });

    // Log query events for debugging
    this.$on('query' as never, (e: any) => {
      if (process.env.LOG_LEVEL === 'debug') {
        this.logger.debug(`Query: ${e.query}`);
        this.logger.debug(`Duration: ${e.duration}ms`);
      }
    });

    this.logger.log('PrismaService constructor called');
    this.logger.log(`DATABASE_URL configured: ${process.env.DATABASE_URL ? 'Yes' : 'No'}`);

    if (process.env.DATABASE_URL) {
      // Log connection string (masked password)
      const maskedUrl = process.env.DATABASE_URL.replace(/:([^:@]+)@/, ':****@');
      this.logger.log(`Connection string: ${maskedUrl}`);
    }
  }

  async onModuleInit() {
    const startTime = Date.now();

    try {
      this.logger.log('=== Starting database connection ===');
      this.logger.log(`Environment: ${process.env.NODE_ENV || 'development'}`);

      await this.$connect();

      const duration = Date.now() - startTime;
      this.isConnected = true;

      this.logger.log('=== Database connected successfully ===');
      this.logger.log(`Connection time: ${duration}ms`);

      // Test query to verify connection
      try {
        await this.$queryRaw`SELECT 1 as test`;
        this.logger.log('Database test query successful');
      } catch (testError) {
        this.logger.warn('Database test query failed', testError);
      }

    } catch (error) {
      const duration = Date.now() - startTime;
      this.isConnected = false;

      this.logger.error('=== Database connection failed ===');
      this.logger.error(`Failed after: ${duration}ms`);
      this.logger.error(`Error type: ${error.constructor.name}`);
      this.logger.error(`Error message: ${error.message}`);

      if (error.code) {
        this.logger.error(`Error code: ${error.code}`);
      }

      throw error;
    }
  }

  async onModuleDestroy() {
    if (this.isConnected) {
      this.logger.log('Disconnecting from database...');
      await this.$disconnect();
      this.logger.log('Database disconnected');
    }
  }

  getConnectionStatus(): { connected: boolean; database?: string } {
    return {
      connected: this.isConnected,
      database: process.env.DATABASE_URL ? 'configured' : 'not configured',
    };
  }
}
