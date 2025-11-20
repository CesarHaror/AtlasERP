import {
  IsString,
  IsNotEmpty,
  MinLength,
  IsOptional,
  IsEmail,
  Validate,
  ValidatorConstraint,
  ValidatorConstraintInterface,
  ValidationArguments,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

@ValidatorConstraint({ name: 'UsernameOrEmail', async: false })
export class UsernameOrEmailConstraint implements ValidatorConstraintInterface {
  validate(_: any, args: ValidationArguments) {
    const obj = args.object as any;
    return !!(obj.username || obj.email);
  }
  defaultMessage(args: ValidationArguments) {
    return 'Debe proporcionar nombre de usuario o email.';
  }
}

export class LoginDto {
  @ApiProperty({
    example: 'admin',
    description: 'Nombre de usuario',
    required: false,
  })
  @IsString()
  @IsOptional()
  username?: string;

  @ApiProperty({
    example: 'devadmin@example.com',
    description: 'Email del usuario',
    required: false,
  })
  @IsEmail()
  @IsOptional()
  email?: string;

  @ApiProperty({
    example: 'Password123!',
    description: 'Contraseña del usuario',
  })
  @IsString()
  @IsNotEmpty({ message: 'La contraseña es requerida' })
  @MinLength(8, { message: 'La contraseña debe tener al menos 8 caracteres' })
  password: string;
}
