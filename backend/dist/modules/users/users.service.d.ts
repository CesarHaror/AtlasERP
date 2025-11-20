import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { Role } from './entities/role.entity';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { UpdatePasswordDto } from './dto/update-password.dto';
export declare class UsersService {
    private userRepository;
    private roleRepository;
    constructor(userRepository: Repository<User>, roleRepository: Repository<Role>);
    create(createUserDto: CreateUserDto): Promise<User>;
    findAll(page?: number, limit?: number, search?: string): Promise<{
        data: User[];
        total: number;
        page: number;
        totalPages: number;
    }>;
    findOne(id: string): Promise<User>;
    findByUsername(username: string): Promise<User | null>;
    findByEmail(email: string): Promise<User | null>;
    update(id: string, updateUserDto: UpdateUserDto): Promise<User>;
    updatePassword(id: string, updatePasswordDto: UpdatePasswordDto): Promise<void>;
    remove(id: string): Promise<void>;
    toggleActive(id: string): Promise<User>;
    getProfile(id: string): Promise<User>;
}
