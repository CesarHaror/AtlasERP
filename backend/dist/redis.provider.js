"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.RedisProvider = void 0;
const ioredis_1 = __importDefault(require("ioredis"));
exports.RedisProvider = {
    provide: 'REDIS',
    useFactory: () => {
        const host = process.env.REDIS_HOST || 'localhost';
        const port = parseInt(process.env.REDIS_PORT || '6379', 10);
        return new ioredis_1.default({ host, port });
    },
};
exports.default = exports.RedisProvider;
//# sourceMappingURL=redis.provider.js.map