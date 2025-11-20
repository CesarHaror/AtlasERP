import { IsString, IsNotEmpty, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class ResetPasswordDto {
  @ApiProperty({
    example: 'token123',
    description: 'Token de reset',
  })
  @IsString()
  @IsNotEmpty()
  token: string;

  @ApiProperty({
    example: 'NewPassword123!',
    description: 'Nueva contraseña',
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(8)
  newPassword: string;
}
