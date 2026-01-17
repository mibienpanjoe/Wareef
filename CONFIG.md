# Configuration Notes

## Google Client ID Setup

To enable Google Sign-In, you need to update the `GOOGLE_CLIENT_ID` in the auth service:

1. **Get your Google Client ID** from your backend's `.env` file or Google Cloud Console
2. **Update** `lib/services/auth_service.dart` line 9:
   ```dart
   clientId: 'YOUR_ACTUAL_GOOGLE_CLIENT_ID.apps.googleusercontent.com',
   ```

## Backend Configuration

- **Backend URL**: `http://localhost:3000/api`
- **Running on**: Port 3000 (Docker)
- **Endpoints**:
  - POST `/auth/register` - Register with email/password
  - POST `/auth/login` - Login with email/password
  - POST `/auth/google` - Google Sign-In
  - GET `/auth/me` - Get current user

## Running the App

To run the Flutter Web app on port 8080:

```bash
flutter run -d chrome --web-port 8080
```

## Google Cloud Console Setup

Make sure you've added these to **Authorized JavaScript Origins**:

- `http://localhost:8080`
- `http://127.0.0.1:8080`
