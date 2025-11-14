import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import RedisProvider from './redis.provider';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST || 'localhost',
      port: Number(process.env.DB_PORT || 5432),
      username: process.env.DB_USERNAME || 'erp_user',
      password: process.env.DB_PASSWORD || 'tu_password',
      database: process.env.DB_DATABASE || 'erp_carniceria',
      entities: [__dirname + '/**/*.entity{.ts,.js}'],
      synchronize: false,
    }),
    // UsersModule
    (require('./modules/users/users.module').UsersModule),
  ],
  controllers: [AppController],
  providers: [AppService, RedisProvider],
})
export class AppModule {}
