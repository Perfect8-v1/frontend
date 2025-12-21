# Session 5 - Image Thumbnails Fix

**Datum:** 2025-12-20
**Status:** Pågående - väntar på deploy

---

## Sammanfattning

Fortsatte felsökning av bilduppladdning från Session 4. Thumbnails genererades men visades inte i Flutter-appen.

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

### 2. Thumbnails visas inte i appen (delvis löst)
**Symptom:** Ikoner visas istället för bilder i Flutter-appen
**Orsak:** URL:er i databasen pekar på `localhost:8084` istället för `p8.rantila.com:8084`
**Lösning:** Lade till `app.base-url` konfiguration:

**application.properties:**
```properties
app.base-url=${APP_BASE_URL:http://localhost:8084}
```

**docker-compose.yml:**
```yaml
- APP_BASE_URL=http://p8.rantila.com:8084
```

---

## Ändringar gjorda (ej pushade)

### Backend-filer:

1. **image-service/src/main/resources/application.properties**
   - Lade till: `app.base-url=${APP_BASE_URL:http://localhost:8084}`

2. **image-service/src/main/java/.../ImageProcessingService.java**
   - Uppdaterade `ensureDirectoriesExist()` att inkludera "products"

3. **image-service/src/main/java/.../ImageService.java**
   - Uppdaterade `ensureDirectoriesExist()` att inkludera "products"

4. **docker-compose.yml**
   - Lade till: `APP_BASE_URL=http://p8.rantila.com:8084`

---

## Att göra imorgon

### 1. Pusha och deploya
```bash
cd C:\_Perfect8\backend
git add .
git commit -m "Fix image URL base path and add products directory"
git push

# På servern (SSH):
cd ~/backend
git pull
docker compose build image-service
docker compose up -d image-service
```

### 2. Fixa befintliga bilder i databasen
Kör SQL mot imageDB:
```sql
UPDATE images
SET thumbnail_url = REPLACE(thumbnail_url, 'localhost:8084', 'p8.rantila.com:8084'),
    small_url = REPLACE(small_url, 'localhost:8084', 'p8.rantila.com:8084'),
    medium_url = REPLACE(medium_url, 'localhost:8084', 'p8.rantila.com:8084'),
    large_url = REPLACE(large_url, 'localhost:8084', 'p8.rantila.com:8084'),
    original_url = REPLACE(original_url, 'localhost:8084', 'p8.rantila.com:8084');
```

### 3. Testa i Flutter-appen
- Logga in som admin
- Gå till Admin-fliken
- Verifiera att uppladdade bilder visar thumbnails korrekt

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

Alla finns på servern i `/app/uploads/` med alla storlekar genererade.

---

## Nästa steg efter thumbnails fungerar

1. Visa bilder i produktlistan (Flutter)
2. Koppla bilder till produkter via referenceType/referenceId
3. Bildgalleri i produktdetaljer

---

*God natt!*
