import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';
import tracer from 'dd-trace';
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger(AllExceptionsFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    // console.log('--- Exception Caught by AllExceptionsFilter ---');
    // console.log(exception.constructor.name);
    // console.log(request.method, request.url);

    const status =
      exception instanceof HttpException ? exception.getStatus() : 500;

    const message =
      exception instanceof HttpException ? exception.getResponse() : exception;

    this.logger.error(`Exception: ${JSON.stringify(message)}`);

    // Datadog trace enhancement
    const span = tracer.scope().active();
    if (span) {
      span.setTag('error', true);

      if (exception instanceof Error) {
        span.setTag('error.message', exception.message);
        span.setTag('error.stack', exception.stack);
        span.setTag('error.type', exception.name);
      } else {
        span.setTag('error.message', JSON.stringify(message));
      }
    }

    response.status(status).json({
      statusCode: status,
      timestamp: new Date().toISOString(),
      path: request.url,
      error: message,
    });
  }
}
