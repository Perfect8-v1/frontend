# Perfect8 Flutter Frontend - Claude Bootstrap

**Flutter-frontend för Perfect8 E-commerce**

**Version:** 1.0
**Uppdaterad:** 2025-12-19

---

## ADHD-ANPASSADE ARBETSREGLER

### Grundprinciper

1. **EN Dart-fil per steg** - Spara och verifiera innan nästa fil
2. **Kompletta filer** - Inga "ändra rad 47", alltid hela filen
3. **Max 2 alternativ** - För många val skapar beslutsvånda
4. **Vänta på svar** - En fråga åt gången
5. **Kort och konkret** - Inga långa förklaringar
6. **Hot reload** - Testa visuellt efter varje ändring

### Kommunikationsregler

- Ge EN fil åt gången
- Ställ max EN fråga per output
- Vänta på bekräftelse innan nästa steg
- Högst två alternativ att fortsätta

---

## PROJEKTÖVERSIKT

### Backend-referens

Backend ligger i `C:\_Perfect8\backend` (375 filer, 56781 rader kod).
Strukturöversikt finns i `docs/struktur.txt`.

**5 Mikrotjänster:**
| Service | Port | Beskrivning |
|---------|------|-------------|
| admin-service | 8081 | Admin, autentisering, dashboard |
| blog-service | 8082 | Blogginlägg, CMS |
| email-service | 8083 | E-post, notifikationer |
| image-service | 8084 | Bildhantering, thumbnails |
| shop-service | 8085 | Produkter, ordrar, kundvagn |

**Base URL:** `http://p8.rantila.com`
**Health check:** `/actuator/health` på varje service

---

## FLUTTER PROJEKTSTRUKTUR

```
lib/
├── main.dart              # App entry point
├── config/
│   └── api_config.dart    # API URLs & timeouts
├── models/                # Datamodeller (matchar backend DTOs)
│   ├── auth_models.dart
│   ├── cart_models.dart
│   ├── product_models.dart
│   └── ...
├── services/              # API-anrop & affärslogik
│   ├── auth_service.dart
│   ├── cart_service.dart
│   ├── product_service.dart
│   └── ...
├── screens/               # UI-skärmar (StatefulWidget)
│   └── ...
├── widgets/               # Återanvändbara komponenter
│   └── ...
└── providers/             # State management (Provider)
    └── ...
```

---

## BYGGORDNING (Ny funktionalitet)

1. **models/** - Datamodell som matchar backend DTO
2. **services/** - API-anrop med error handling
3. **providers/** - State management (om behövs)
4. **widgets/** - Återanvändbara UI-komponenter
5. **screens/** - Fullständig skärm

---

## KODPRINCIPER

### Namnkonventioner

- **Fältnamn:** SAMMA som backend (`customerId`, inte `id`)
- **Modeller:** Matchar backend DTOs exakt
- **Filer:** snake_case (`auth_service.dart`)
- **Klasser:** PascalCase (`AuthService`)
- **Variabler:** camelCase (`isLoading`)

### Dart-specifikt

```dart
// Factory constructor för JSON
factory Customer.fromJson(Map<String, dynamic> json) {
  return Customer(
    customerId: json['customerId'],
    email: json['email'],
  );
}

// Null safety
final String? optionalField;
final String requiredField;

// Async/await
Future<Customer> getCustomer() async {
  final response = await http.get(...);
  return Customer.fromJson(jsonDecode(response.body));
}
```

### Undvik

- Inga hårdkodade strängar (använd constants)
- Inga naked `print()` (använd debugPrint i dev)
- Ingen affärslogik i widgets
- Inga API-anrop direkt i UI

---

## TEKNISK STACK

### Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0           # API-anrop
  provider: ^6.1.1       # State management
  shared_preferences: ^2.2.2  # Lokal lagring (tokens)
```

### Verktyg

- **VS Code** med Flutter extension
- **Flutter DevTools** för debugging
- **Hot reload** (r) / Hot restart (R)

---

## API-MÖNSTER

### Service-struktur

```dart
class ProductService {
  static const String _baseUrl = ApiConfig.shopServiceUrl;

  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/products'),
        headers: await AuthService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        // Parse response
      } else {
        throw ApiException.fromResponse(response);
      }
    } catch (e) {
      throw ApiException(message: 'Kunde inte hämta produkter');
    }
  }
}
```

### Error handling

```dart
class ApiException implements Exception {
  final int? statusCode;
  final String message;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
}
```

---

## AUTENTISERING

### Token-flöde

1. **Login** → Backend returnerar JWT token
2. **Spara** → `SharedPreferences` lagrar token
3. **Använd** → `Authorization: Bearer <token>` i headers
4. **Refresh** → Hantera 401 med token refresh eller logout

### Auth endpoints

- **Admin login:** `POST /api/admin/auth/login` (port 8081)
- **Customer login:** `POST /api/customers/auth/login` (port 8085)
- **Register:** `POST /api/customers/auth/register` (port 8085)

---

## NUVARANDE STATUS

### Implementerat
- [x] Health check för alla 5 services
- [x] Auth models & service
- [x] Cart models & service
- [x] Product service (saknar models)
- [x] API exception handling
- [x] Paginated response wrapper

### Saknas
- [ ] Product models (tom fil)
- [ ] Login/Register UI
- [ ] Produkt-lista UI
- [ ] Kundvagn UI
- [ ] State management med Provider

---

## FELSÖKNINGSORDNING

1. **Network** - Når vi backend? (health check)
2. **Auth** - Rätt token? Rätt headers?
3. **JSON** - Matchar model backend response?
4. **State** - Uppdateras UI korrekt?
5. **Widget** - Renderas komponenten?

---

## VANLIGA KOMMANDON

```bash
# Kör appen
flutter run

# Kör på specifik enhet
flutter run -d chrome
flutter run -d windows

# Hot reload: tryck 'r' i terminalen
# Hot restart: tryck 'R' i terminalen

# Analysera kod
flutter analyze

# Hämta dependencies
flutter pub get
```

---

## REFERENSDOKUMENTATION

| Fil | Beskrivning |
|-----|-------------|
| `docs/FLUTTER_GUIDE.md` | Pedagogisk guide (svenska) |
| `docs/struktur.txt` | Backend filstruktur |
| `.github/copilot-instructions.md` | Kodningsprinciper |

**Backend-dokument i `C:\_Perfect8\`:**
- `Magnum_Opus_v1.4.md` - Huvudbootstrap
- `Perfect8_API_Guide_v1.2_final.md` - API-dokumentation
- `Bootstrap_Addendum_*.md` - Sessionsloggar

---

*Skapad för ADHD-vänlig Flutter-utveckling*
*Baserad på Magnum Opus v1.4*
