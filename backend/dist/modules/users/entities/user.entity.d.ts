import { Role } from './role.entity';
export declare class User {
    id: string;
    email: string;
    passwordHash: string;
    username: string;
    firstName: string;
    lastName: string;
    isActive: boolean;
    failedLoginAttempts: number;
    lockedUntil?: Date;
    lastLogin?: Date;
    createdAt: Date;
    updatedAt: Date;
    get fullName(): string;
    roles?: Role[];
}
