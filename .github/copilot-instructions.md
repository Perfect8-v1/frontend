# Flutter Training App - AI Coding Guidelines

## Project Overview
This is a Flutter training application for Perfect8 e-commerce platform. Currently implements health checks for backend microservices (Admin, Blog, Email, Image, Shop). Models are prepared for authentication, cart, and products.

## Architecture
- **Screens**: UI components in `lib/screens/` (e.g., `health_check_screen.dart`)
- **Services**: API logic in `lib/services/` (e.g., `api_service.dart` with HTTP calls)
- **Models**: Data structures in `lib/models/` (e.g., `health_response.dart` with `fromJson`/`toJson`)
- **Config**: API endpoints in `lib/config/api_config.dart` (switch between local/production)

## Key Patterns
- **API Calls**: Use `http` package with 5-second timeout, try/catch blocks, and JSON parsing
  ```dart
  final response = await http.get(Uri.parse(url), headers: {'Content-Type': 'application/json'})
      .timeout(const Duration(seconds: 5));
  return HealthResponse.fromJson(json.decode(response.body));
  ```
- **State Management**: `setState` in `StatefulWidget` for UI updates; `Provider` available for complex state
- **Error Handling**: Catch exceptions, display user-friendly messages in red containers
- **UI Components**: Material 3 with custom colors, status indicators (green/red/gray), loading spinners

## Workflows
- **Run App**: `flutter run -d chrome` (or `edge`) after starting backend with `docker compose up -d`
- **Backend Health**: Services run on ports 8081-8085, health endpoints at `/actuator/health`
- **Debugging**: Check backend logs with `docker compose logs <service>`, test endpoints with `curl`

## Conventions
- **Naming**: snake_case for variables/methods, PascalCase for classes, UPPER_SNAKE for constants
- **Imports**: Relative imports within lib (e.g., `../models/health_response.dart`)
- **Comments**: English for code, Swedish in docs; describe purpose and parameters
- **Dependencies**: `http` for requests, `provider` for state; keep minimal and pinned
- **File Structure**: Group by feature (screens, services, models), config separate

## Examples
- **New API Method**: Add to `ApiService` class, call `checkHealth` with specific URL from `ApiConfig`
- **New Screen**: Create `StatefulWidget` in `lib/screens/`, use `Scaffold` with `AppBar` and `Padding`
- **New Model**: Implement `fromJson` factory and `toJson` method for JSON serialization

Reference: `docs/FLUTTER_GUIDE.md` for detailed flow, `pubspec.yaml` for dependencies.</content>
<parameter name="filePath">c:\_Perfect8\flutter_training\.github\copilot-instructions.md