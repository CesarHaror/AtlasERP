import { IsString, IsNotEmpty, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class ChangePasswordDto {
  @ApiProperty({
    example: 'CurrentPassword123!',
    description: 'Contraseña actual',
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(8)
  currentPassword: string;

  @ApiProperty({
    example: 'NewPassword123!',
    description: 'Nueva contraseña',
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(8)
  newPassword: string;
}
