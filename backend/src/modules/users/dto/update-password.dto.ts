import { IsString, IsNotEmpty, MinLength, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdatePasswordDto {
  @ApiProperty({
    example: 'OldP@ssw0rd',
    description: 'Contraseña actual del usuario',
  })
  @IsString()
  @IsNotEmpty({ message: 'La contraseña actual es requerida' })
  currentPassword: string;

  @ApiProperty({
    example: 'NewP@ssw0rd123',
    description: 'Nueva contraseña',
  })
  @IsString()
  @IsNotEmpty({ message: 'La nueva contraseña es requerida' })
  @MinLength(8, {
    message: 'La nueva contraseña debe tener al menos 8 caracteres',
  })
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/, {
    message:
      'La contraseña debe tener al menos una mayúscula, una minúscula, un número y un caracter especial',
  })
  newPassword: string;

  @ApiProperty({
    example: 'NewP@ssw0rd123',
    description: 'Confirmación de la nueva contraseña',
  })
  @IsString()
  @IsNotEmpty({ message: 'La confirmación de contraseña es requerida' })
  confirmPassword: string;
}
