import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import express, { json, urlencoded } from 'express';
import serverlessExpress from '@vendia/serverless-express';
import { Callback, Context, Handler } from 'aws-lambda';
import { ExpressAdapter, NestExpressApplication } from '@nestjs/platform-express';
import helmet from 'helmet';
import { requestLogger } from './middlewares/logger/request-logger';
import { setupSwagger } from './core/helpers/swagger';
import { HttpExceptionFilter } from './filters/http-exception.filter';
import logger from './core/logger';

import dotenv from 'dotenv';
import { SSMClient, GetParameterCommand } from '@aws-sdk/client-ssm';

let server: Handler;
let ssmLoaded = false;

async function loadEnvFromSSM() {
  if (ssmLoaded) return;

  const paramName = process.env.APP_DOTENV;
  if (!paramName) return; // if not set, skip

  const region =
    process.env.AWS_REGION ||
    process.env.AWS_DEFAULT_REGION ||
    'us-east-1';

  const ssm = new SSMClient({ region });
  const res = await ssm.send(
    new GetParameterCommand({
      Name: paramName,
      WithDecryption: true,
    })
  );

  const raw = res.Parameter?.Value || '';
  const parsed = dotenv.parse(raw);

  // do NOT overwrite already-set env vars
  for (const [k, v] of Object.entries(parsed)) {
    if (process.env[k] === undefined) process.env[k] = v;
  }

  ssmLoaded = true;
}

async function bootstrap() {
  // ✅ load SSM env BEFORE NestFactory.create()
  await loadEnvFromSSM();

  const expressApp = express();
  //^ create app and enable cors
  const app = await NestFactory.create<NestExpressApplication>(
    AppModule,
    new ExpressAdapter(expressApp),
    {
      cors: {
        origin: '*',
        methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
        preflightContinue: false,
        optionsSuccessStatus: 204,
      },
      logger: ['error', 'warn'],
    },
  );
  // use helmet for security
  app.use(
    helmet({
      contentSecurityPolicy: false, // disable content security policy
      hsts: {
        maxAge: 31536000, // 1 year
        includeSubDomains: true,
        preload: true,
      },
    }),
  );

  //^ enable app to use validation pip
  app.useGlobalPipes(new ValidationPipe());
  app.useGlobalFilters(new HttpExceptionFilter());

  // increase the request size limit
  app.use(json({ limit: '50mb' }));
  app.use(urlencoded({ extended: true, limit: '50mb' }));
  app.use(requestLogger({ log: logger.log }));
  // Setup swagger
  setupSwagger(app);
  await app.init();
  return serverlessExpress({ app: expressApp });
}

export const handler: Handler = async (event: any, context: Context, callback: Callback) => {
  if (event.path === '/api-docs') {
    event.path = '/api-docs/';
  }
  server = server ?? (await bootstrap());
  return server(event, context, callback);
};
