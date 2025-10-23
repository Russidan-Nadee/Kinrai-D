import { Processor, Process } from '@nestjs/bull';
import { Logger } from '@nestjs/common';
import type { Job } from 'bull';
import { MenusService } from '../../menus/menus.service';
import { CreateMenuDto } from '../../menus/dto/create-menu.dto';

export const BATCH_OPERATIONS_QUEUE = 'batch-operations';

export interface BatchCreateJobData {
  menus: CreateMenuDto[];
  userId: string;
}

export interface BatchDeleteJobData {
  ids: number[];
  userId: string;
}

@Processor(BATCH_OPERATIONS_QUEUE)
export class BatchOperationsProcessor {
  private readonly logger = new Logger(BatchOperationsProcessor.name);

  constructor(private readonly menusService: MenusService) {}

  @Process('batch-create-menus')
  async handleBatchCreateMenus(job: Job<BatchCreateJobData>) {
    this.logger.log(
      `Processing batch create menus job ${job.id} with ${job.data.menus.length} menus`,
    );

    try {
      // Update progress
      await job.progress(10);

      const result = await this.menusService.createBatch(job.data.menus);

      // Update progress
      await job.progress(100);

      this.logger.log(
        `Completed batch create menus job ${job.id}: ${result.created} created, ${result.failed} failed`,
      );
      return result;
    } catch (error) {
      this.logger.error(
        `Failed to process batch create menus job ${job.id}:`,
        error,
      );
      throw error;
    }
  }

  @Process('batch-delete-menus')
  async handleBatchDeleteMenus(job: Job<BatchDeleteJobData>) {
    this.logger.log(
      `Processing batch delete menus job ${job.id} with ${job.data.ids.length} menus`,
    );

    try {
      // Update progress
      await job.progress(10);

      const result = await this.menusService.deleteBatch(job.data.ids);

      // Update progress
      await job.progress(100);

      this.logger.log(
        `Completed batch delete menus job ${job.id}: ${result.deleted} deleted, ${result.failed} failed`,
      );
      return result;
    } catch (error) {
      this.logger.error(
        `Failed to process batch delete menus job ${job.id}:`,
        error,
      );
      throw error;
    }
  }
}
