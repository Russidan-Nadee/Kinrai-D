import { Controller, Get, Param, HttpStatus, HttpException } from '@nestjs/common';
import { InjectQueue } from '@nestjs/bull';
import type { Queue } from 'bull';
import { ANALYTICS_QUEUE } from './processors/analytics.processor';
import { BATCH_OPERATIONS_QUEUE } from './processors/batch-operations.processor';

@Controller('jobs')
export class JobsController {
  constructor(
    @InjectQueue(ANALYTICS_QUEUE) private readonly analyticsQueue: Queue,
    @InjectQueue(BATCH_OPERATIONS_QUEUE)
    private readonly batchOperationsQueue: Queue,
  ) {}

  @Get(':jobId')
  async getJobStatus(@Param('jobId') jobId: string) {
    // Try to find job in analytics queue, if not found try batch operations queue
    let job =
      (await this.analyticsQueue.getJob(jobId)) ??
      (await this.batchOperationsQueue.getJob(jobId));

    if (!job) {
      throw new HttpException('Job not found', HttpStatus.NOT_FOUND);
    }

    const state = await job.getState();
    const progress = job.progress();
    const result = job.returnvalue;
    const failedReason = job.failedReason;

    return {
      id: job.id,
      state,
      progress,
      result: state === 'completed' ? result : null,
      error: state === 'failed' ? failedReason : null,
      attempts: job.attemptsMade,
      timestamp: job.timestamp,
      processedOn: job.processedOn,
      finishedOn: job.finishedOn,
    };
  }

  @Get('analytics/stats')
  async getAnalyticsQueueStats() {
    const waiting = await this.analyticsQueue.getWaitingCount();
    const active = await this.analyticsQueue.getActiveCount();
    const completed = await this.analyticsQueue.getCompletedCount();
    const failed = await this.analyticsQueue.getFailedCount();
    const delayed = await this.analyticsQueue.getDelayedCount();

    return {
      queue: ANALYTICS_QUEUE,
      waiting,
      active,
      completed,
      failed,
      delayed,
      total: waiting + active + completed + failed + delayed,
    };
  }

  @Get('batch-operations/stats')
  async getBatchOperationsQueueStats() {
    const waiting = await this.batchOperationsQueue.getWaitingCount();
    const active = await this.batchOperationsQueue.getActiveCount();
    const completed = await this.batchOperationsQueue.getCompletedCount();
    const failed = await this.batchOperationsQueue.getFailedCount();
    const delayed = await this.batchOperationsQueue.getDelayedCount();

    return {
      queue: BATCH_OPERATIONS_QUEUE,
      waiting,
      active,
      completed,
      failed,
      delayed,
      total: waiting + active + completed + failed + delayed,
    };
  }
}
