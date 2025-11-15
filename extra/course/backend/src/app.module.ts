import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { LoggerModule } from 'nestjs-pino';
import { AppController } from './app.controller';
import { AppService } from './app.service';

const isTest = process.env.NODE_ENV === 'test' || process.env.DD_ENV === 'test';
@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    LoggerModule.forRoot({
      pinoHttp: {
        transport: isTest
          ? undefined
          : {
              targets: [
                {
                  target: 'pino-pretty',
                  options: { colorize: true },
                },
                {
                  target: 'pino-datadog-transport',
                  options: {
                    ddClientConf: {
                      authMethods: {
                        apiKeyAuth: process.env.DD_API_KEY,
                      },
                    },
                  },
                  level: 'trace',
                },
              ],
            },
      },
    }),
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
