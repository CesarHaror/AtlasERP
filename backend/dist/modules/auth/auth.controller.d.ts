import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import { User } from '../users/entities/user.entity';
export declare class AuthController {
    private readonly authService;
    constructor(authService: AuthService);
    register(registerDto: RegisterDto): Promise<import("./dto/auth-response.dto").AuthResponse>;
    login(loginDto: LoginDto): Promise<import("./dto/auth-response.dto").AuthResponse>;
    refreshToken(refreshToken: string): Promise<import("./dto/auth-response.dto").AuthResponse>;
    getProfile(user: User): {
        id: string;
        email: string;
        username: string;
        firstName: string;
        lastName: string;
        isActive: boolean;
        lastLogin?: Date;
        createdAt: Date;
        updatedAt: Date;
        roles?: import("../users/entities/role.entity").Role[];
    };
    changePassword(userId: string, changePasswordDto: ChangePasswordDto): Promise<{
        message: string;
    }>;
    logout(userId: string): Promise<{
        message: string;
    }>;
    me(user: User): {
        user: {
            id: string;
            email: string;
            username: string;
            firstName: string;
            lastName: string;
            isActive: boolean;
            lastLogin?: Date;
            createdAt: Date;
            updatedAt: Date;
            roles?: import("../users/entities/role.entity").Role[];
        };
    };
}
