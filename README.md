# Perfect8 Flutter Frontend

E-handelsapp byggd med Flutter, ansluten till Java Spring Boot mikrotjänster.

**Live:** https://p8.rantila.com

---

## Snabbstart

```bash
# Installera dependencies
flutter pub get

# Kör lokalt (Chrome)
flutter run -d chrome

# Bygg för produktion
flutter build web --release
```

---

## Projektstruktur

```
lib/
├── main.dart                 # App entry point
├── models/                   # Datamodeller (matchar backend DTOs)
│   ├── cart_models.dart
│   ├── customer_models.dart
│   ├── order_models.dart
│   └── product_models.dart
├── screens/                  # UI-skärmar
│   ├── home_screen.dart      # Produktlista + navigation
│   ├── login_screen.dart     # Inloggning
│   ├── cart_screen.dart      # Kundvagn
│   ├── checkout_screen.dart  # Kassa + orderbekräftelse
│   ├── profile_screen.dart   # Användarprofil
│   ├── addresses_screen.dart # Adresshantering
│   └── admin_*.dart          # Admin-skärmar
├── services/                 # API-anrop
│   ├── api_config.dart       # Backend URLs
│   ├── api_exception.dart    # Felhantering
│   ├── auth_service.dart     # JWT-autentisering
│   ├── cart_service.dart     # Kundvagn API
│   ├── customer_service.dart # Kundprofil API
│   ├── order_service.dart    # Order API
│   └── product_service.dart  # Produkt API
└── widgets/                  # Återanvändbara komponenter
```

---

## Backend-anslutning

Appen ansluter till 5 mikrotjänster via Nginx reverse proxy:

| Tjänst | Port | Endpoint prefix |
|--------|------|-----------------|
| admin-service | 8081 | `/api/v1/auth/`, `/api/v1/admin/` |
| blog-service | 8082 | `/api/v1/blog/`, `/api/v1/posts/` |
| email-service | 8083 | `/api/v1/email/` |
| image-service | 8084 | `/api/v1/images/` |
| shop-service | 8085 | `/api/v1/products/`, `/api/v1/cart/`, `/api/v1/orders/` |

**Base URL:** `https://p8.rantila.com`

---

## Funktioner

### Kund
- Inloggning/utloggning (JWT)
- Bläddra produkter med bilder
- Kundvagn med antal-badge
- Checkout med adress och betalningsval
- Profilhantering (namn, telefon)
- Adressbok (lägg till, ta bort)

### Admin
- Produktbildhantering (ladda upp, thumbnail, galleri)
- Koppla bilder till produkter

---

## Konfiguration

Backend-URL konfigureras i `lib/services/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'https://p8.rantila.com';
  static const String adminUrl = '$baseUrl:8081';
  static const String shopUrl = '$baseUrl:8085';
  static const String imageUrl = '$baseUrl:8084';
}
```

---

## Deploy

```bash
# 1. Bygg
flutter build web --release

# 2. Kopiera till server
scp -r build/web/* root@p8.rantila.com:/var/www/perfect8/
```

Nginx servar statiska filer från `/var/www/perfect8/` med SPA-stöd:
```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

---

## Teknisk stack

- **Flutter 3.24.5** (Dart 3.5.4)
- **http** - REST API-anrop
- **shared_preferences** - Lokal lagring (JWT token)
- **Material 3** - UI-design

---

## Testanvändare

| Typ | E-post | Lösenord |
|-----|--------|----------|
| Admin | admin@perfect8.com | Admin123! |
| Kund | test@example.com | Test123! |

---

## Utveckling

```bash
# Hot reload: tryck 'r' i terminalen
# Hot restart: tryck 'R' i terminalen
# Analysera kod
flutter analyze
```

---

*Utvecklad december 2024*
