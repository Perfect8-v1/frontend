# Perfect8 Shop Flutter (MVP)

A simple Flutter frontend for the Perfect8 shop/blog project with:
- Bottom navigation between pages
- Views: Home (products), Categories, Cart, Login, Checkout, Product details
- Mock API with local JSON (easily switch to real Spring Boot endpoints)
- Provider-based state management

## Quick start
```bash
cd perfect8_shop_flutter
flutter pub get
flutter run -d chrome
# or
flutter run
```
Login is mocked: use any email + password.

## Switch to real backend
Edit `lib/config/app_config.dart`:
- Set `useMock = false`
- Set `baseUrl = "http://localhost:8082"` (or your deployed URL)

API paths are defined in `lib/config/endpoints.dart` (aligned with your Shop Service).
