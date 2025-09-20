import { Injectable } from '@nestjs/common';
import { PinoLogger, InjectPinoLogger } from 'nestjs-pino';
@Injectable()
export class AppService {
  constructor(
    @InjectPinoLogger(AppService.name)
    private readonly logger: PinoLogger,
  ) {}

  getHello(): string {
    return 'Hello World!';
  }

  getHealth(): string {
    this.logger.info('Health check');
    return 'OK';
  }

  throwError(): void {
    this.logger.error('Error thrown');
    throw new Error('This is a test error');
  }
}
