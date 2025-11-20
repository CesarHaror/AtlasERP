export declare class AuthResponse {
    accessToken: string;
    refreshToken?: string;
    user: {
        id: string;
        username: string;
        email: string;
        firstName: string;
        lastName: string;
        roles: Array<{
            id: string;
            name: string;
        }>;
    };
}
