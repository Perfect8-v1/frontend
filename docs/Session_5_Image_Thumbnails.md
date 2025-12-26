# Session 5 - Image Thumbnails & Produkt-Bildkoppling

**Datum:** 2025-12-20 - 2025-12-21
**Status:** Pågående

---

## Sammanfattning

Fixade thumbnails-visning i Flutter och byggde admin-UI för att koppla bilder till produkter. Löste flera autentiseringsproblem med Spring Security roller.

---

## Problem & Lösningar

### 1. Thumbnails genererades inte (löst)
**Symptom:** Uppladdning lyckades men inga thumbnails skapades
**Orsak:** Mapparna (thumbnail, small, medium, large) fanns inte i Docker-volymen
**Lösning:** Skapade manuellt på servern:
```bash
docker compose exec -u root image-service mkdir -p /app/uploads/products /app/uploads/original /app/uploads/thumbnail /app/uploads/small /app/uploads/medium /app/uploads/large
docker compose exec -u root image-service chmod -R 777 /app/uploads
```

### 2. Thumbnails visas inte - fel URL (löst)
**Symptom:** Ikoner visas istället för bilder i Flutter-appen
**Orsak:** URL:er i databasen pekar på `localhost:8084` istället för `p8.rantila.com:8084`
**Lösning:**

**application.properties:**
```properties
app.base-url=${APP_BASE_URL:http://localhost:8084}
```

**docker-compose.yml:**
```yaml
- APP_BASE_URL=http://p8.rantila.com:8084
```

### 3. 403 Forbidden vid produktuppdatering (löst)
**Symptom:** Admin får 403 när de försöker koppla bild till produkt
**Orsak:** Spring Security `hasRole("ADMIN")` kräver `ROLE_ADMIN` authority, men JWT hade bara `ADMIN`
**Lösning:** Lade till ROLE_-prefix i JwtUtil.extractAuthorities() i **alla 4 services**:

```java
for (String role : roles) {
    // Add ROLE_ prefix if not present (required for hasRole() checks)
    String authority = role.startsWith("ROLE_") ? role : "ROLE_" + role;
    authorities.add(new SimpleGrantedAuthority(authority));
}
```

**Påverkade filer:**
- `shop-service/src/main/java/com/perfect8/shop/util/JwtUtil.java`
- `image-service/src/main/java/com/perfect8/image/util/JwtUtil.java`
- `email-service/src/main/java/com/perfect8/email/util/JwtUtil.java`
- `blog-service/src/main/java/com/perfect8/blog/security/JwtTokenProvider.java`

### 4. JSON Recursion Error (löst)
**Symptom:** `FormatException: Unexpected character` vid API-anrop
**Orsak:** `getProductionSafe()` metod i GlobalExceptionHandler returnerade ErrorResponse som serialiserades rekursivt
**Lösning:** Lade till `@JsonIgnore` annotation:
```java
@JsonIgnore
public ErrorResponse getProductionSafe() { ... }
```

### 5. 400 Bad Request vid produktuppdatering (pågående)
**Symptom:** Efter ROLE_-fix, nu 400-fel istället för 403
**Möjlig orsak:**
- `price` validering kräver värde > 0
- Saknade fält i request body
**Lösning:** Uppdaterade `_attachImage()` i Flutter:
- Lade till fler fält (description, categoryId, weight, tags)
- Säkerställer price > 0
- Bättre debug-logging
- Parsning av felmeddelanden

---

## Nya filer skapade

### Flutter: Admin Product Images Screen
**Fil:** `lib/screens/admin_product_images_screen.dart`

Admin-UI för att koppla bilder till produkter:
- Produktlista till vänster (visar befintlig bild eller "Ingen bild")
- Bildgrid till höger (thumbnails från image-service)
- Välj en produkt + en bild, tryck "Koppla bild"
- PUT-anrop till shop-service för att uppdatera produktens imageUrl

---

## Deploy-process

### Windows (lokalt):
```bash
cd C:\_Perfect8\backend
git add .
git commit -m "Fix ROLE_ prefix in JWT auth for all services"
git push
```

### Server (SSH):
```bash
cd ~/backend
git pull

# Bygg om alla services med ändrad JwtUtil
docker compose build shop-service image-service email-service blog-service
docker compose up -d
```

---

## 6 Image Endpoints

| Endpoint | Beskrivning |
|----------|-------------|
| `/images/products/{filename}` | Produktbilder |
| `/images/original/{filename}` | Originalbilder |
| `/images/thumbnail/{filename}` | Thumbnails (150x150) |
| `/images/small/{filename}` | Small (400x400) |
| `/images/medium/{filename}` | Medium (800x800) |
| `/images/large/{filename}` | Large (1600x1600) |

---

## Testbilder uppladdade
- Cube-S.jpg (240KB)
- perfect8-cube-s.jpg (464KB)
- the-cube-t-full.jpg (152KB)
- the-cube-t-detail.jpg (119KB)

---

## Kvar att göra

1. Verifiera att 400-felet är löst efter senaste Flutter-fix
2. Testa att koppla bild till produkt
3. Verifiera att bilderna visas i produktlistan

---

## Teknisk insikt: Spring Security hasRole()

```
hasRole("ADMIN")     -> Kräver ROLE_ADMIN authority
hasAuthority("ADMIN") -> Kräver ADMIN authority (utan prefix)
```

JWT-token från admin-service innehåller: `"roles": ["ADMIN"]`

Därför måste alla services som använder `hasRole()` lägga till ROLE_-prefix vid token-parsning.

---
