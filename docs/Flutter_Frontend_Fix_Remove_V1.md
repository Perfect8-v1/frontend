# Flutter Frontend Fix - Ta Bort /v1 Från API Calls

**Datum:** 2025-12-29  
**Problem:** Frontend använder `/api/v1/` men backend har nu `/api/` (utan v1)  
**Lösning:** Uppdatera alla API calls för att använda Gateway utan /v1

---

## Steg 1: Hitta Alla /v1 Användningar

**Windows:**
```bash
cd C:\_Perfect8\flutter_training
grep -rn "/v1/" lib/ --include="*.dart"
```

**Detta hittar alla filer som använder /v1 i paths.**

---

## Steg 2: Ersätt api_config.dart

**Fil:** `api_config.dart`  
**Plats:** `lib/config/api_config.dart`

**Ersätt hela filen med:**
- Uppladdad fil från outputs: `api_config.dart`

**Ändringar:**
```dart
// FÖRE:
static const String baseUrl = 'http://p8.rantila.com';
static String get shopUrl => '$baseUrl:$shopPort';  // :8085

// EFTER:
static const String baseUrl = 'http://p8.rantila.com:8080';  // Gateway!
static String get shopUrl => gatewayUrl;  // Samma för alla services
```

---

## Steg 3: Ta Bort /v1 Från Service Calls

**Sök & ersätt i ALLA .dart filer:**

### Pattern 1: Cart Service
```dart
// FÖRE:
'/api/v1/cart/'
'/api/v1/cart/add/'
'/api/v1/cart/remove/'
'/api/v1/cart/count/'

// EFTER:
'/api/cart/'
'/api/cart/add/'
'/api/cart/remove/'
'/api/cart/count/'
```

### Pattern 2: Products
```dart
// FÖRE:
'/api/v1/products'
'/api/v1/products/'

// EFTER:
'/api/products'
'/api/products/'
```

### Pattern 3: Categories
```dart
// FÖRE:
'/api/v1/categories'

// EFTER:
'/api/categories'
```

### Pattern 4: Orders
```dart
// FÖRE:
'/api/v1/orders'
'/api/v1/orders/'

// EFTER:
'/api/orders'
'/api/orders/'
```

### Pattern 5: Customers
```dart
// FÖRE:
'/api/v1/customers'

// EFTER:
'/api/customers'
```

### Pattern 6: Auth
```dart
// FÖRE:
'/api/v1/auth/login'
'/api/v1/auth/register'
'/api/v1/auth/salt'

// EFTER:
'/api/auth/login'
'/api/auth/register'
'/api/auth/salt'
```

### Pattern 7: Posts (Blog)
```dart
// FÖRE:
'/api/v1/posts'

// EFTER:
'/api/posts'
```

### Pattern 8: Images
```dart
// FÖRE:
'/api/v1/images'

// EFTER:
'/api/images'
```

### Pattern 9: Email
```dart
// FÖRE:
'/api/v1/email'

// EFTER:
'/api/email'
```

---

## Steg 4: Global Search & Replace (Snabbast)

**Använd VSCode Find & Replace:**

1. **Öppna:** VSCode
2. **Tryck:** `Ctrl+Shift+H` (Find & Replace in Files)
3. **Find:** `/api/v1/`
4. **Replace:** `/api/`
5. **Files to include:** `lib/**/*.dart`
6. **Tryck:** "Replace All"

**VARNING:** Kontrollera att inga andra paths använder /v1 som inte ska ändras!

---

## Steg 5: Verifiera Ändringar

**Windows:**
```bash
# Kolla att inga /v1 finns kvar
grep -rn "/v1/" lib/ --include="*.dart"

# Resultat ska vara TOM eller bara kommentarer
```

---

## Steg 6: Testa Appen

**1. Kör appen:**
```bash
flutter run
```

**2. Testa funktionalitet:**
- ✅ Login fungerar
- ✅ Products visas
- ✅ Cart fungerar
- ✅ Ingen login-dialog vid navigation!

**3. Kolla logs:**
```bash
flutter logs
```

**Förväntat:**
```
🛒 CartService.getCart() - URL: http://p8.rantila.com:8080/api/cart/
🛒 CartService.getCart() - Status: 200
✅ Cart loaded successfully
```

**INTE:**
```
🛒 CartService.getCart() - Status: 404  ❌
```

---

## Exempel: cart_service.dart Före/Efter

### FÖRE
```dart
Future<Cart> getCart() async {
  final url = '${ApiConfig.shopUrl}/api/v1/cart/';  // Direct to :8085
  final headers = _authService.authHeaders;
  
  final response = await http.get(
    Uri.parse(url),
    headers: headers,
  );
  
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final data = json['data'] ?? json;
    return Cart.fromJson(data);
  } else {
    throw ApiException.fromResponse(response);
  }
}
```

### EFTER
```dart
Future<Cart> getCart() async {
  final url = '${ApiConfig.shopUrl}/api/cart/';  // Via Gateway :8080, no /v1
  final headers = _authService.authHeaders;
  
  final response = await http.get(
    Uri.parse(url),
    headers: headers,
  );
  
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final data = json['data'] ?? json;
    return Cart.fromJson(data);
  } else {
    throw ApiException.fromResponse(response);
  }
}
```

**Ändringar:**
1. `shopUrl` pekar nu på Gateway (:8080) istället för shop-service (:8085)
2. `/api/v1/cart/` → `/api/cart/` (ingen /v1)

---

## Förväntat Resultat

**FÖRE fix:**
```
Request: http://p8.rantila.com:8085/api/v1/cart/
Status: 404 Not Found (service har /api/cart utan /v1)
→ ApiException
→ Login dialog visas! ❌
```

**EFTER fix:**
```
Request: http://p8.rantila.com:8080/api/cart/
→ Gateway routar till shop-service:8085/api/cart/
Status: 200 OK
→ Cart laddar korrekt! ✅
→ Ingen login dialog! ✅
```

---

## Felsökning

### Problem 1: Fortfarande 404
**Lösning:** Kolla att backend verkligen tog bort /v1
```bash
# Server
curl http://localhost:8080/api/products
# Ska returnera produkter ✅
```

### Problem 2: Fortfarande login-dialog
**Lösning:** Kolla att ALLA /v1 togs bort
```bash
# Windows
grep -rn "/v1/" lib/ --include="*.dart"
# Ska vara tom ✅
```

### Problem 3: CORS errors
**Lösning:** Gateway CORS ska tillåta requests
```yaml
# Gateway application.yml
globalcors:
  corsConfigurations:
    '[/**]':
      allowedOrigins:
        - "http://localhost:3000"
        - "https://p8.rantila.com"
```

---

## Checklist

- [ ] Hitta alla /v1 användningar: `grep -rn "/v1/" lib/`
- [ ] Ersätt api_config.dart med ny version
- [ ] VSCode Find & Replace: `/api/v1/` → `/api/`
- [ ] Verifiera: `grep -rn "/v1/" lib/` (ska vara tom)
- [ ] Kör appen: `flutter run`
- [ ] Testa login
- [ ] Testa products
- [ ] Testa cart (viktigt!)
- [ ] Navigera mellan sidor - INGEN login dialog! ✅
- [ ] Commit & push till GitHub

---

## Git Commit Message

```bash
git add lib/config/api_config.dart lib/services/*.dart
git commit -m "Fix: Use API Gateway and remove /v1 from all API calls

- ApiConfig now points to Gateway (port 8080) instead of direct services
- Removed /v1 from all API paths to match backend
- All requests now route through Gateway
- Fixes login dialog appearing on every navigation (404 errors resolved)

Backend removed /v1 versioning for portfolio pragmatism.
Frontend now aligned with backend API structure."

git push origin cmb
```

---

**Author:** Claude & Magnus  
**Date:** 2025-12-29  
**Status:** Ready to apply
