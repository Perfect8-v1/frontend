# Session 4: Kundvagn

**Datum:** 2025-12-20
**Branch:** `cmb`

---

## Vad vi gjorde

### 1. Kundvagn-implementation
- Uppdaterade `cart_models.dart` att matcha backend `CartResponse`
- Uppdaterade `cart_service.dart` med korrekta endpoints (`/api/cart/`)
- Skapade `cart_screen.dart` med:
  - Lista med produkter
  - Ändra antal (+/-)
  - Ta bort produkt
  - Töm kundvagn
  - Totalsumma
- Uppdaterade `product_detail_screen.dart` med riktig "Lägg i kundvagn"

### 2. AuthService Singleton
- **Problem:** Varje skärm skapade ny AuthService med `_token = null`
- **Lösning:** Gjorde AuthService till singleton så token delas

### 3. Image-service (tillfälligt avstängt)
- Backend returnerar 403 Forbidden på bilderna
- Stängde av bildladdning tillfälligt för att rensa loggen

---

## BACKEND-BUGGAR ATT FIXA

### BUG 1: Registration skapar inte Customer i shop_db
**Symptom:** "Customer not found with email: xxx" när man lägger i kundvagn
**Orsak:** Registration i admin-service skapar bara user, inte Customer i shop-service
**Workaround:** Manuell SQL:
```sql
-- Kör mot shop_db
INSERT INTO customers (email, first_name, last_name, created_date, updated_date)
VALUES ('user@email.com', 'First', 'Last', NOW(), NOW());
```
**Riktig fix:** Backend registration bör skapa Customer i shop_db också (eller synka)

### BUG 2: CartService skapar duplicerade carts
**Symptom:** "More than one row with the given identifier was found"
**Orsak:** Backend skapar ny cart vid varje addToCart istället för att återanvända
**Workaround:** Rensa carts manuellt:
```sql
DELETE FROM cart_items;
DELETE FROM carts;
```
**Riktig fix:** `CartService.getOrCreateCart()` måste kolla om cart redan finns

### BUG 3: Image-service returnerar 403
**Symptom:** `HTTP 403 Forbidden` på `/images/products/*.jpg`
**Trolig orsak:** SecurityConfig blockerar eller CORS-problem
**TODO:** Kolla `image-service/SecurityConfig.java`

---

## Filer som ändrades

| Fil | Status |
|-----|--------|
| `lib/models/cart_models.dart` | Uppdaterad |
| `lib/models/product_models.dart` | Bilder avstängda |
| `lib/services/cart_service.dart` | Uppdaterad + debug |
| `lib/services/auth_service.dart` | Singleton pattern |
| `lib/screens/cart_screen.dart` | Skapad |
| `lib/screens/product_detail_screen.dart` | Kundvagn fungerar |
| `lib/screens/product_list_screen.dart` | Kundvagn-ikon |

---

## Status

- [x] Cart models
- [x] Cart service
- [x] Cart screen
- [x] Add to cart från produktdetalj
- [ ] Ta bort debug-prints efter test
- [ ] Aktivera bilder när backend fixad

---

## Nästa steg

1. **Testa kundvagn** - Lägg till, ändra antal, ta bort
2. **Fixa backend** - Customer-synk vid registration
3. **Fixa image-service** - 403-problemet
4. **Navigation** - Bottom nav bar

---

*Session pågår...*
