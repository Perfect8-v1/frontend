# Session 3: Auth & Produktlista

**Datum:** 2025-12-19
**Branch:** `cmb` (pushat till GitHub)

---

## Vad vi gjorde

### 1. Fixade Auth-flödet
- **Problem:** Flutter-modellen förväntade sig `token`, backend skickade `accessToken`
- **Lösning:** Uppdaterade `auth_models.dart` att matcha backend `AuthResponse`
- Fält som ändrades: `accessToken`, `tokenType`, `userId`, `roles`

### 2. Produktlista
- Skapade `product_models.dart` som matchar backend `ProductResponse`
- Uppdaterade `product_service.dart` med korrekta endpoints (`/api/products`)
- Byggde `product_list_screen.dart` med:
  - Grid-layout (2 kolumner)
  - Pris med rabattvisning
  - Lagerstatus
  - Pull-to-refresh
  - Paginering

### 3. Produktdetalj
- Skapade `product_detail_screen.dart` med:
  - Stor produktbild
  - Pris och rabatt
  - Lagerstatus
  - Beskrivning
  - Detaljer (SKU, kategori, vikt)
  - "Lägg i kundvagn"-knapp (placeholder)

### 4. Git & GitHub
- Initierade git i flutter_training
- Pushade till `Perfect8-v1/frontend` branch `cmb`

---

## Filer som ändrades/skapades

| Fil | Status |
|-----|--------|
| `lib/models/auth_models.dart` | Uppdaterad |
| `lib/models/product_models.dart` | Uppdaterad |
| `lib/services/auth_service.dart` | Städad (debug borta) |
| `lib/services/product_service.dart` | Uppdaterad |
| `lib/screens/login_screen.dart` | Navigerar till produktlista |
| `lib/screens/product_list_screen.dart` | Skapad |
| `lib/screens/product_detail_screen.dart` | Skapad |

---

## Nästa session

### Prioritet 1: Kundvagn
- [ ] Skapa `cart_models.dart` (matcha backend)
- [ ] Skapa `cart_service.dart`
- [ ] Skapa `cart_screen.dart`
- [ ] Lägg till "Lägg i kundvagn" funktionalitet

### Prioritet 2: Navigation
- [ ] Bottom navigation bar (Produkter, Kundvagn, Profil)
- [ ] Logout-funktion

### Att fixa (minor)
- [ ] Uppdatera admin@perfect8.com med password_salt i databasen
- [ ] Kör AdminJwtAuthTest efter admin-fix

---

## Teststrategi (diskuterad)

| Lager | Verktyg | När |
|-------|---------|-----|
| Backend API | REST Assured | Efter backend-ändringar |
| Flutter Unit | `flutter test` | Efter modell/service-ändringar |
| Integration | Manuellt | Kontinuerligt |

---

## Kommandon att komma ihåg

```bash
# Starta Flutter
cd c:\_Perfect8\flutter_training
flutter run -d windows

# Git workflow
git add .
git commit -m "beskrivning"
git push

# Byt branch
git checkout branch-namn
git checkout -b ny-branch
```

---

*Bra jobbat idag!*
