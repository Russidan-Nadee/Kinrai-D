import { Controller, Get } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Controller('health')
export class HealthController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  async check() {
    const status = this.prisma.getConnectionStatus();

    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      database: status,
      environment: {
        nodeEnv: process.env.NODE_ENV || 'development',
        port: process.env.PORT || 8000,
      },
    };
  }

  @Get('db')
  async checkDatabase() {
    try {
      const result = await this.prisma.$queryRaw`SELECT
        current_database() as database,
        current_user as user,
        version() as version,
        NOW() as server_time`;

      return {
        status: 'connected',
        timestamp: new Date().toISOString(),
        database: result,
      };
    } catch (error) {
      return {
        status: 'error',
        timestamp: new Date().toISOString(),
        error: {
          message: error.message,
          code: error.code,
          type: error.constructor.name,
        },
      };
    }
  }

  @Get('env')
  async checkEnvironment() {
    // Only show in non-production or when debug is enabled
    const isDebug = process.env.LOG_LEVEL === 'debug';
    const isProduction = process.env.NODE_ENV === 'production';

    if (isProduction && !isDebug) {
      return {
        status: 'forbidden',
        message: 'Environment info not available in production without debug mode',
      };
    }

    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      environment: {
        nodeEnv: process.env.NODE_ENV,
        port: process.env.PORT,
        logLevel: process.env.LOG_LEVEL,
        databaseConfigured: !!process.env.DATABASE_URL,
        databaseHost: process.env.DATABASE_URL
          ? new URL(process.env.DATABASE_URL).host
          : 'not configured',
        supabaseConfigured: !!process.env.SUPABASE_URL,
      },
      system: {
        platform: process.platform,
        nodeVersion: process.version,
        uptime: Math.round(process.uptime()) + 's',
        memory: {
          rss: Math.round(process.memoryUsage().rss / 1024 / 1024) + 'MB',
          heapUsed: Math.round(process.memoryUsage().heapUsed / 1024 / 1024) + 'MB',
          heapTotal: Math.round(process.memoryUsage().heapTotal / 1024 / 1024) + 'MB',
        },
      },
    };
  }

  @Get('connection-test')
  async testConnection() {
    const startTime = Date.now();

    try {
      // Test simple query
      await this.prisma.$queryRaw`SELECT 1 as test`;
      const simpleQueryTime = Date.now() - startTime;

      // Test count query
      const countStart = Date.now();
      const userCount = await this.prisma.userProfile.count();
      const countQueryTime = Date.now() - countStart;

      // Test connection pool
      const poolStart = Date.now();
      await Promise.all([
        this.prisma.$queryRaw`SELECT 1`,
        this.prisma.$queryRaw`SELECT 2`,
        this.prisma.$queryRaw`SELECT 3`,
      ]);
      const poolQueryTime = Date.now() - poolStart;

      return {
        status: 'ok',
        timestamp: new Date().toISOString(),
        tests: {
          simpleQuery: { success: true, duration: simpleQueryTime + 'ms' },
          countQuery: {
            success: true,
            duration: countQueryTime + 'ms',
            count: userCount,
          },
          poolQuery: {
            success: true,
            duration: poolQueryTime + 'ms',
            parallel: 3,
          },
        },
        totalTime: Date.now() - startTime + 'ms',
      };
    } catch (error) {
      return {
        status: 'error',
        timestamp: new Date().toISOString(),
        error: {
          message: error.message,
          code: error.code,
          type: error.constructor.name,
        },
        duration: Date.now() - startTime + 'ms',
      };
    }
  }
}
