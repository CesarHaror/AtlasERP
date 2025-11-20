import { ValidatorConstraintInterface, ValidationArguments } from 'class-validator';
export declare class UsernameOrEmailConstraint implements ValidatorConstraintInterface {
    validate(_: any, args: ValidationArguments): boolean;
    defaultMessage(args: ValidationArguments): string;
}
export declare class LoginDto {
    username?: string;
    email?: string;
    password: string;
}
