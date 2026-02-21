# Test Analys Manuell (TAM) - Perfect8 v1.1

**Version:** 1.1  
**Datum:** 2026-01-24  
**Testare:** Magnus  
**Miljö:** https://p8.rantila.com (Production)  
**Ändring v1.1:** Alla curl-kommandon har `-i` för att visa HTTP-headers och statuskod

---

## 📋 INNEHÅLL

1. [Auth Service](#1-auth-service)
2. [Blog Service](#2-blog-service)
3. [Image Service](#3-image-service)
4. [Email Service](#4-email-service)
5. [Shop Service - Products](#5-shop-service---products)
6. [Shop Service - Categories](#6-shop-service---categories)
7. [Shop Service - Customers](#7-shop-service---customers)
8. [Shop Service - Cart](#8-shop-service---cart)
9. [Shop Service - Orders](#9-shop-service---orders)
10. [Shop Service - Payments](#10-shop-service---payments)
11. [Shop Service - Shipments](#11-shop-service---shipments)
12. [Sammanfattning](#12-sammanfattning)

---

## 🔑 TESTDATA

**Admin-användare:**
```
Email: cmb@p8.se
Password: magnus123
```

**Base URL:** `https://p8.rantila.com`

**JWT Token (fyll i efter login):**
```
TOKEN: 

eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJjbWJAcDguc2UiLCJ1c2VySWQiOjEsInJvbGVzIjoiUk9MRV9BRE1JTixST0xFX1NVUEVSX0FETUlOIiwiaWF0IjoxNzY5MzUxMDEyLCJleHAiOjE3NjkzNTQ2MTJ9.RBKxIDT23cYEQYktVJoWSmlXva8Fm55DU0M3KjZtuW8DYcfDIz3DgKwlCjg-3b00Or_9icyw7F8Ee0b4TmUeog

REFRESH TOKEN: 

2b49c026-a37d-492a-9bac-e424436258b7

---

## 1. AUTH SERVICE

**Base:** `https://p8.rantila.com/api/auth`

### 1.1 Login (POST /api/auth/login)

- [ ] **Test:** Login med korrekta credentials

**Request:**
```bash
curl -i -X POST https://p8.rantila.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"cmb@p8.se","password":"magnus123"}'
```

**Förväntat:** 200 OK, accessToken + refreshToken

**Faktiskt resultat:**
```
Status: 200 OK
Headers:
transfer-encoding: chunked
Vary: Origin
Vary: Access-Control-Request-Method
Vary: Access-Control-Request-Headers
Vary: Origin
Vary: Access-Control-Request-Method
Vary: Access-Control-Request-Headers
X-Content-Type-Options: nosniff
X-XSS-Protection: 0
Cache-Control: no-cache, no-store, max-age=0, must-revalidate
Pragma: no-cache
Expires: 0
X-Frame-Options: DENY
Content-Type: application/json
Date: Sun, 25 Jan 2026 14:23:33 GMT
Strict-Transport-Security: max-age=31536000 ; includeSubDomains
Referrer-Policy: no-referrer

Response: 

{"accessToken":"eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJjbWJAcDguc2UiLCJ1c2VySWQiOjEsInJvbGVzIjoiUk9MRV9BRE1JTixST0xFX1NVUEVSX0FETUlOIiwiaWF0IjoxNzY5MzUxMDEyLCJleHAiOjE3NjkzNTQ2MTJ9.RBKxIDT23cYEQYktVJoWSmlXva8Fm55DU0M3KjZtuW8DYcfDIz3DgKwlCjg-3b00Or_9icyw7F8Ee0b4TmUeog","refreshToken":"2b49c026-a37d-492a-9bac-e424436258b7","tokenType":"Bearer","expiresIn":3600,"user":{"roles":["ADMIN","SUPER_ADMIN"],"userId":1,"email":"cmb@p8.se"}}

```

---

- [ ] **Test:** Login med fel lösenord

**Request:**
```bash
curl -i -X POST https://p8.rantila.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"cmb@p8.se","password":"wrongpassword"}'
```

**Förväntat:** 401 Unauthorized

**Faktiskt resultat:**
```
Status: 401 Unauthorize
Headers:
transfer-encoding: chunked
Vary: Origin
Vary: Access-Control-Request-Method
Vary: Access-Control-Request-Headers
Vary: Origin
Vary: Access-Control-Request-Method
Vary: Access-Control-Request-Headers
X-Content-Type-Options: nosniff
X-XSS-Protection: 0
Cache-Control: no-cache, no-store, max-age=0, must-revalidate
Pragma: no-cache
Expires: 0
X-Frame-Options: DENY
Content-Type: application/json
Date: Sun, 25 Jan 2026 14:27:18 GMT
Strict-Transport-Security: max-age=31536000 ; includeSubDomains
Referrer-Policy: no-referrer

Response: 
{"error":"Invalid credentials"}

```

---

- [ ] **Test:** Login med icke-existerande email

**Request:**
```bash
curl -i -X POST https://p8.rantila.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"noexist@test.com","password":"test123"}'
```

**Förväntat:** 401 Unauthorized

**Faktiskt resultat:**
```
Status: 401 Unauthorized
Headers:
transfer-encoding: chunked
Vary: Origin
Vary: Access-Control-Request-Method
Vary: Access-Control-Request-Headers
Vary: Origin
Vary: Access-Control-Request-Method
Vary: Access-Control-Request-Headers
X-Content-Type-Options: nosniff
X-XSS-Protection: 0
Cache-Control: no-cache, no-store, max-age=0, must-revalidate
Pragma: no-cache
Expires: 0
X-Frame-Options: DENY
Content-Type: application/json
Date: Sun, 25 Jan 2026 14:28:58 GMT
Strict-Transport-Security: max-age=31536000 ; includeSubDomains
Referrer-Policy: no-referrer

Response: 
{"error":"Login failed"}

```

---

### 1.2 Register (POST /api/auth/register)

- [ ] **Test:** Registrera ny användare

**Request:**
```bash
curl -i -X POST https://p8.rantila.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"testdude@test.com","password":"test123","firstName":"Test","lastName":"User"}'
```

**Förväntat:** 201 Created

**Faktiskt resultat:**
```
Status: 201 Created
Headers:
transfer-encoding: chunked
Vary: Origin
Vary: Access-Control-Request-Method
Vary: Access-Control-Request-Headers
Vary: Origin
Vary: Access-Control-Request-Method
Vary: Access-Control-Request-Headers
X-Content-Type-Options: nosniff
X-XSS-Protection: 0
Cache-Control: no-cache, no-store, max-age=0, must-revalidate
Pragma: no-cache
Expires: 0
X-Frame-Options: DENY
Content-Type: application/json
Date: Sun, 25 Jan 2026 19:21:25 GMT
Strict-Transport-Security: max-age=31536000 ; includeSubDomains
Referrer-Policy: no-referrer

Response: 
{"message":"User registered successfully"}

```

---

- [ ] **Test:** Registrera med redan existerande email

**Request:**
```bash
curl -i -X POST https://p8.rantila.com/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"cmb@p8.se","password":"test123","firstName":"Test","lastName":"User"}'
```

**Förväntat:** 409 Conflict

**Faktiskt resultat:**
```
Status: 409 Conflict
Headers:

transfer-encoding: chunked
Vary: Origin
Vary: Access-Control-Request-Method
Vary: Access-Control-Request-Headers
Vary: Origin
Vary: Access-Control-Request-Method
Vary: Access-Control-Request-Headers
X-Content-Type-Options: nosniff
X-XSS-Protection: 0
Cache-Control: no-cache, no-store, max-age=0, must-revalidate
Pragma: no-cache
Expires: 0
X-Frame-Options: DENY
Content-Type: application/json
Date: Sun, 25 Jan 2026 19:22:28 GMT
Strict-Transport-Security: max-age=31536000 ; includeSubDomains
Referrer-Policy: no-referrer
Response: 
{"error":"Email already registered"}

```

---

### 1.3 Refresh Token (POST /api/auth/refresh)

- [ ] **Test:** Förnya access token

**Request:**
```bash
curl -i -X POST https://p8.rantila.com/api/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refreshToken":"2b49c026-a37d-492a-9bac-e424436258b7"}'
```

**Förväntat:** 200 OK, nytt accessToken

**Faktiskt resultat:**
```
Status: 403 Forbidden
Headers:
Vary: Origin
Vary: Access-Control-Request-Method
Vary: Access-Control-Request-Headers
Vary: Origin
Vary: Access-Control-Request-Method
Vary: Access-Control-Request-Headers
X-Content-Type-Options: nosniff
X-XSS-Protection: 0
Cache-Control: no-cache, no-store, max-age=0, must-revalidate
Pragma: no-cache
Expires: 0
X-Frame-Options: DENY
Content-Length: 0
Date: Sun, 25 Jan 2026 19:24:24 GMT
Strict-Transport-Security: max-age=31536000 ; includeSubDomains
Referrer-Policy: no-referrer

Response: 


```

---

## 2. BLOG SERVICE

**Base:** `https://p8.rantila.com/blog/api`

### 2.1 List Posts (GET /blog/api/posts) - PUBLIC

- [ ] **Test:** Hämta alla publicerade posts

**Request:**
```bash
curl -i https://p8.rantila.com/blog/api/posts
```

**Förväntat:** 200 OK, lista med posts

**Faktiskt resultat:**
```
Status: 200 OK
Headers:
transfer-encoding: chunked
Vary: Origin
Vary: Access-Control-Request-Method
Vary: Access-Control-Request-Headers
X-Content-Type-Options: nosniff
X-XSS-Protection: 0
Cache-Control: no-cache, no-store, max-age=0, must-revalidate
Pragma: no-cache
Expires: 0
X-Frame-Options: DENY
Content-Type: application/json
Date: Mon, 26 Jan 2026 05:48:01 GMT
Strict-Transport-Security: max-age=31536000 ; includeSubDomains
Referrer-Policy: no-referrer

Antal posts: 5
Response: 
{"content":[{"postId":1,"title":"Updated Title","content":"Updated content","slug":"updated-title","published":true,"createdDate":"2025-01-10T09:00:00","updatedDate":"2026-01-24T12:55:42","publishedDate":"2025-01-15T10:00:00","viewCount":246,"images":[{"imageId":1,"caption":"Perfect8 Logo","displayOrder":0},{"imageId":2,"caption":"Microservices Architecture Diagram","displayOrder":1}]},{"postId":3,"title":"Building Secure APIs with JWT","content":"# JWT Authentication\n\nSecurity is crucial for any web application. In this post, we discuss how we implement JWT authentication.\n\n## What is JWT?\n\nJSON Web Token (JWT) is a compact, URL-safe means of representing claims to be transferred between two parties.\n\n## Implementation\n\n```java\npublic String generateToken(User user) {\n    return Jwts.builder()\n        .setSubject(user.getEmail())\n        .signWith(key)\n        .compact();\n}\n```\n\n## Best Practices\n- Use strong secret keys\n- Set appropriate expiration times\n- Implement refresh tokens","slug":"building-secure-apis-with-jwt","published":true,"createdDate":"2025-03-08T11:00:00","updatedDate":"2025-03-09T16:00:00","publishedDate":"2025-03-10T14:00:00","viewCount":312,"images":[{"imageId":4,"caption":"JWT Flow Diagram","displayOrder":0}]},{"postId":4,"title":"Docker and Microservices Deployment","content":"# Deploying with Docker\n\nDocker makes it easy to deploy microservices. Here is how we do it.\n\n## Docker Compose\n\nWe use Docker Compose to orchestrate our services:\n\n```yaml\nservices:\n  admin-service:\n    build: ./admin-service\n    ports:\n      - \"8081:8081\"\n```\n\n## Benefits\n- Consistent environments\n- Easy scaling\n- Simple deployment","slug":"docker-and-microservices-deployment","published":true,"createdDate":"2025-04-02T09:00:00","updatedDate":"2025-04-04T15:00:00","publishedDate":"2025-04-05T10:00:00","viewCount":178,"images":[{"imageId":5,"caption":"Docker Compose Setup","displayOrder":0},{"imageId":6,"caption":"Container Network Diagram","displayOrder":1}]},{"postId":21,"title":"New start","content":"Får se om detta blir en ny start","slug":"new-start","published":true,"createdDate":"2026-01-16T15:11:37","updatedDate":null,"publishedDate":"2026-01-16T15:11:37","viewCount":0,"images":[]},{"postId":22,"title":"TAM Test Post","content":"This is a test post created during TAM testing","slug":"tam-test-post","published":true,"createdDate":"2026-01-24T12:53:13","updatedDate":null,"publishedDate":"2026-01-24T12:53:13","viewCount":0,"images":[]}],"pageable":{"pageNumber":0,"pageSize":20,"sort":[],"offset":0,"paged":true,"unpaged":false},"last":true,"totalPages":1,"totalElements":5,"first":true,"size":20,"number":0,"sort":[],"numberOfElements":5,"empty":false}

```

---

### 2.2 Get Post by Slug (GET /blog/api/posts/{slug}) - PUBLIC

- [ ] **Test:** Hämta specifik post via slug

**Request:**
```bash
curl -i https://p8.rantila.com/blog/api/posts/updated-by-rest-assured
```

**Förväntat:** 200 OK, post-objekt

**Faktiskt resultat:**
```
Status: 404 Not Found
Headers:
transfer-encoding: chunked
Vary: Origin
Vary: Access-Control-Request-Method
Vary: Access-Control-Request-Headers
X-Content-Type-Options: nosniff
X-XSS-Protection: 0
Cache-Control: no-cache, no-store, max-age=0, must-revalidate
Pragma: no-cache
Expires: 0
X-Frame-Options: DENY
Content-Type: application/json
Date: Mon, 26 Jan 2026 05:50:59 GMT
Strict-Transport-Security: max-age=31536000 ; includeSubDomains
Referrer-Policy: no-referrer

Response: 
{"status":404,"message":"Published post not found with slug: updated-by-rest-assured","timestamp":"2026-01-26T05:50:59.710056848","errors":null}


```

---

- [ ] **Test:** Hämta icke-existerande post

**Request:**
```bash
curl -i https://p8.rantila.com/blog/api/posts/nonexistent-slug
```

**Förväntat:** 404 Not Found

**Faktiskt resultat:**
```
Status: 404 Not Found
Headers:
transfer-encoding: chunked
Vary: Origin
Vary: Access-Control-Request-Method
Vary: Access-Control-Request-Headers
X-Content-Type-Options: nosniff
X-XSS-Protection: 0
Cache-Control: no-cache, no-store, max-age=0, must-revalidate
Pragma: no-cache
Expires: 0
X-Frame-Options: DENY
Content-Type: application/json
Date: Mon, 26 Jan 2026 05:56:08 GMT
Strict-Transport-Security: max-age=31536000 ; includeSubDomains
Referrer-Policy: no-referrer

Response: 
{"status":404,"message":"Published post not found with slug: nonexistent-slug","timestamp":"2026-01-26T05:56:08.161457764","errors":null}

```

---

### 2.3 Create Post (POST /blog/api/posts) - ADMIN

- [ ] **Test:** Skapa ny post (kräver JWT)

**Request:**
```bash
curl -i -X POST https://p8.rantila.com/blog/api/posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJjbWJAcDguc2UiLCJ1c2VySWQiOjEsInJvbGVzIjoiUk9MRV9BRE1JTixST0xFX1NVUEVSX0FETUlOIiwiaWF0IjoxNzY5MzUxMDEyLCJleHAiOjE3NjkzNTQ2MTJ9.RBKxIDT23cYEQYktVJoWSmlXva8Fm55DU0M3KjZtuW8DYcfDIz3DgKwlCjg-3b00Or_9icyw7F8Ee0b4TmUeog" \
  -d '{
    "title": "TAM Test Post",
    "content": "This is a test post created during TAM testing",
    "slug": "tam-test-post",
    "published": true
  }'
```

**Förväntat:** 201 Created

**Faktiskt resultat:**
```
Status: 401 Unauthorized
Headers:
Vary: Origin
Vary: Access-Control-Request-Method
Vary: Access-Control-Request-Headers
Cache-Control: no-cache, no-store, max-age=0, must-revalidate
Pragma: no-cache
Expires: 0
X-Content-Type-Options: nosniff
Strict-Transport-Security: max-age=31536000 ; includeSubDomains
X-Frame-Options: DENY
X-XSS-Protection: 0
Referrer-Policy: no-referrer
content-length: 0

Skapad postId: ______
Response: 


```

---

- [ ] **Test:** Skapa post utan JWT

**Request:**
```bash
curl -i -X POST https://p8.rantila.com/blog/api/posts \
  -H "Content-Type: application/json" \
  -d '{"title":"No Auth Test","content":"Test","slug":"no-auth-test","published":false}'
```

**Förväntat:** 401 eller 403

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

### 2.4 Update Post (PUT /blog/api/posts/{id}) - ADMIN

- [ ] **Test:** Uppdatera befintlig post

**Request:**
```bash
curl -i -X PUT https://p8.rantila.com/blog/api/posts/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer DITT_TOKEN" \
  -d '{
    "title": "Updated Title",
    "content": "Updated content",
    "slug": "updated-title",
    "published": true
  }'
```

**Förväntat:** 200 OK

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

### 2.5 Delete Post (DELETE /blog/api/posts/{id}) - ADMIN

- [ ] **Test:** Ta bort post

**Request:**
```bash
curl -i -X DELETE https://p8.rantila.com/blog/api/posts/ID_HÄR \
  -H "Authorization: Bearer DITT_TOKEN"
```

**Förväntat:** 204 No Content

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

## 3. IMAGE SERVICE

**Base:** `https://p8.rantila.com/image/api`

### 3.1 Get Image (GET /image/api/images/{id}) - PUBLIC

- [ ] **Test:** Hämta bild-metadata

**Request:**
```bash
curl -i https://p8.rantila.com/image/api/images/1
```

**Förväntat:** 200 OK, bild-metadata

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

### 3.2 Get Thumbnail (GET /image/api/images/{id}/thumbnail/{size}) - PUBLIC

- [ ] **Test:** Hämta thumbnail (SMALL)

**Request:**
```bash
curl -i https://p8.rantila.com/image/api/images/1/thumbnail/SMALL
```

**Förväntat:** 200 OK

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

### 3.3 Upload Image (POST /image/api/images/upload) - ADMIN

- [ ] **Test:** Ladda upp bild

**Request:**
```bash
curl -i -X POST https://p8.rantila.com/image/api/images/upload \
  -H "Authorization: Bearer DITT_TOKEN" \
  -F "file=@/path/to/image.jpg" \
  -F "altText=Test image"
```

**Förväntat:** 201 Created

**Faktiskt resultat:**
```
Status: ______
Headers:


imageId: ______
Response: 


```

---

### 3.4 Delete Image (DELETE /image/api/images/{id}) - ADMIN

- [ ] **Test:** Ta bort bild

**Request:**
```bash
curl -i -X DELETE https://p8.rantila.com/image/api/images/ID_HÄR \
  -H "Authorization: Bearer DITT_TOKEN"
```

**Förväntat:** 204 No Content

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

## 4. EMAIL SERVICE

**Base:** `https://p8.rantila.com/email/api`

### 4.1 Send Email (POST /email/api/email/send) - ADMIN

- [ ] **Test:** Skicka email

**Request:**
```bash
curl -i -X POST https://p8.rantila.com/email/api/email/send \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer DITT_TOKEN" \
  -d '{
    "to": "test@example.com",
    "subject": "TAM Test Email",
    "body": "This is a test email from TAM testing"
  }'
```

**Förväntat:** 200 OK

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

### 4.2 Get Email Logs (GET /email/api/email/logs) - ADMIN

- [ ] **Test:** Hämta email-loggar

**Request:**
```bash
curl -i https://p8.rantila.com/email/api/email/logs \
  -H "Authorization: Bearer DITT_TOKEN"
```

**Förväntat:** 200 OK, lista med loggar

**Faktiskt resultat:**
```
Status: ______
Headers:


Antal loggar: ______
Response: 


```

---

## 5. SHOP SERVICE - PRODUCTS

**Base:** `https://p8.rantila.com/shop/api`

### 5.1 List Products (GET /shop/api/products) - PUBLIC

- [ ] **Test:** Hämta alla produkter

**Request:**
```bash
curl -i https://p8.rantila.com/shop/api/products
```

**Förväntat:** 200 OK, lista med produkter

**Faktiskt resultat:**
```
Status: ______
Headers:


Antal produkter: ______
Response: 


```

---

### 5.2 Get Product (GET /shop/api/products/{id}) - PUBLIC

- [ ] **Test:** Hämta specifik produkt

**Request:**
```bash
curl -i https://p8.rantila.com/shop/api/products/1
```

**Förväntat:** 200 OK, produkt-objekt

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

- [ ] **Test:** Hämta icke-existerande produkt

**Request:**
```bash
curl -i https://p8.rantila.com/shop/api/products/99999
```

**Förväntat:** 404 Not Found

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

### 5.3 Search Products (GET /shop/api/products/search) - PUBLIC

- [ ] **Test:** Sök produkter

**Request:**
```bash
curl -i "https://p8.rantila.com/shop/api/products/search?q=test"
```

**Förväntat:** 200 OK

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

### 5.4 Create Product (POST /shop/api/products) - ADMIN

- [ ] **Test:** Skapa ny produkt

**Request:**
```bash
curl -i -X POST https://p8.rantila.com/shop/api/products \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer DITT_TOKEN" \
  -d '{
    "name": "TAM Test Product",
    "description": "Test product created during TAM",
    "price": 199.99,
    "stock": 100,
    "categoryId": 1
  }'
```

**Förväntat:** 201 Created

**Faktiskt resultat:**
```
Status: ______
Headers:


productId: ______
Response: 


```

---

### 5.5 Update Product (PUT /shop/api/products/{id}) - ADMIN

- [ ] **Test:** Uppdatera produkt

**Request:**
```bash
curl -i -X PUT https://p8.rantila.com/shop/api/products/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer DITT_TOKEN" \
  -d '{
    "name": "Updated Product Name",
    "description": "Updated description",
    "price": 299.99,
    "stock": 50
  }'
```

**Förväntat:** 200 OK

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

### 5.6 Delete Product (DELETE /shop/api/products/{id}) - ADMIN

- [ ] **Test:** Ta bort produkt

**Request:**
```bash
curl -i -X DELETE https://p8.rantila.com/shop/api/products/ID_HÄR \
  -H "Authorization: Bearer DITT_TOKEN"
```

**Förväntat:** 204 No Content

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

## 6. SHOP SERVICE - CATEGORIES

**Base:** `https://p8.rantila.com/shop/api`

### 6.1 List Categories (GET /shop/api/categories) - PUBLIC

- [ ] **Test:** Hämta alla kategorier

**Request:**
```bash
curl -i https://p8.rantila.com/shop/api/categories
```

**Förväntat:** 200 OK

**Faktiskt resultat:**
```
Status: ______
Headers:


Antal kategorier: ______
Response: 


```

---

### 6.2 Get Category (GET /shop/api/categories/{id}) - PUBLIC

- [ ] **Test:** Hämta specifik kategori

**Request:**
```bash
curl -i https://p8.rantila.com/shop/api/categories/1
```

**Förväntat:** 200 OK

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

### 6.3 Get Products in Category (GET /shop/api/categories/{id}/products) - PUBLIC

- [ ] **Test:** Hämta produkter i kategori

**Request:**
```bash
curl -i https://p8.rantila.com/shop/api/categories/1/products
```

**Förväntat:** 200 OK

**Faktiskt resultat:**
```
Status: ______
Headers:


Antal produkter: ______
Response: 


```

---

### 6.4 Create Category (POST /shop/api/categories) - ADMIN

- [ ] **Test:** Skapa ny kategori

**Request:**
```bash
curl -i -X POST https://p8.rantila.com/shop/api/categories \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer DITT_TOKEN" \
  -d '{
    "name": "TAM Test Category",
    "description": "Test category"
  }'
```

**Förväntat:** 201 Created

**Faktiskt resultat:**
```
Status: ______
Headers:


categoryId: ______
Response: 


```

---

### 6.5 Update Category (PUT /shop/api/categories/{id}) - ADMIN

- [ ] **Test:** Uppdatera kategori

**Request:**
```bash
curl -i -X PUT https://p8.rantila.com/shop/api/categories/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer DITT_TOKEN" \
  -d '{
    "name": "Updated Category Name",
    "description": "Updated description"
  }'
```

**Förväntat:** 200 OK

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

### 6.6 Delete Category (DELETE /shop/api/categories/{id}) - ADMIN

- [ ] **Test:** Ta bort kategori

**Request:**
```bash
curl -i -X DELETE https://p8.rantila.com/shop/api/categories/ID_HÄR \
  -H "Authorization: Bearer DITT_TOKEN"
```

**Förväntat:** 204 No Content

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

## 7. SHOP SERVICE - CUSTOMERS

**Base:** `https://p8.rantila.com/shop/api`

### 7.1 Get Profile (GET /shop/api/customers/profile) - JWT

- [ ] **Test:** Hämta egen profil

**Request:**
```bash
curl -i https://p8.rantila.com/shop/api/customers/profile \
  -H "Authorization: Bearer DITT_TOKEN"
```

**Förväntat:** 200 OK

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

### 7.2 Update Profile (PUT /shop/api/customers/profile) - JWT

- [ ] **Test:** Uppdatera profil

**Request:**
```bash
curl -i -X PUT https://p8.rantila.com/shop/api/customers/profile \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer DITT_TOKEN" \
  -d '{
    "firstName": "Magnus",
    "lastName": "Updated",
    "phone": "0701234567"
  }'
```

**Förväntat:** 200 OK

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

## 8. SHOP SERVICE - CART

**Base:** `https://p8.rantila.com/shop/api`

### 8.1 Get Cart (GET /shop/api/cart) - JWT

- [ ] **Test:** Hämta kundvagn

**Request:**
```bash
curl -i https://p8.rantila.com/shop/api/cart \
  -H "Authorization: Bearer DITT_TOKEN"
```

**Förväntat:** 200 OK

**Faktiskt resultat:**
```
Status: ______
Headers:


Antal items: ______
Response: 


```

---

### 8.2 Add to Cart (POST /shop/api/cart/add) - JWT

- [ ] **Test:** Lägg till produkt i kundvagn

**Request:**
```bash
curl -i -X POST https://p8.rantila.com/shop/api/cart/add \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer DITT_TOKEN" \
  -d '{
    "productId": 1,
    "quantity": 2
  }'
```

**Förväntat:** 200 OK

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

### 8.3 Update Cart Item (PUT /shop/api/cart/update) - JWT

- [ ] **Test:** Uppdatera antal i kundvagn

**Request:**
```bash
curl -i -X PUT https://p8.rantila.com/shop/api/cart/update \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer DITT_TOKEN" \
  -d '{
    "cartItemId": 1,
    "quantity": 5
  }'
```

**Förväntat:** 200 OK

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

### 8.4 Remove from Cart (DELETE /shop/api/cart/remove/{itemId}) - JWT

- [ ] **Test:** Ta bort från kundvagn

**Request:**
```bash
curl -i -X DELETE https://p8.rantila.com/shop/api/cart/remove/1 \
  -H "Authorization: Bearer DITT_TOKEN"
```

**Förväntat:** 200 OK eller 204 No Content

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

### 8.5 Clear Cart (DELETE /shop/api/cart/clear) - JWT

- [ ] **Test:** Töm kundvagn

**Request:**
```bash
curl -i -X DELETE https://p8.rantila.com/shop/api/cart/clear \
  -H "Authorization: Bearer DITT_TOKEN"
```

**Förväntat:** 200 OK eller 204 No Content

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

## 9. SHOP SERVICE - ORDERS

**Base:** `https://p8.rantila.com/shop/api`

### 9.1 Create Order (POST /shop/api/orders/create) - JWT

- [ ] **Test:** Skapa order från kundvagn

**Request:**
```bash
curl -i -X POST https://p8.rantila.com/shop/api/orders/create \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer DITT_TOKEN" \
  -d '{
    "shippingAddressId": 1,
    "billingAddressId": 1
  }'
```

**Förväntat:** 201 Created

**Faktiskt resultat:**
```
Status: ______
Headers:


orderId: ______
Response: 


```

---

### 9.2 List Orders (GET /shop/api/orders) - JWT

- [ ] **Test:** Hämta mina ordrar

**Request:**
```bash
curl -i https://p8.rantila.com/shop/api/orders \
  -H "Authorization: Bearer DITT_TOKEN"
```

**Förväntat:** 200 OK

**Faktiskt resultat:**
```
Status: ______
Headers:


Antal ordrar: ______
Response: 


```

---

### 9.3 Get Order (GET /shop/api/orders/{id}) - JWT

- [ ] **Test:** Hämta specifik order

**Request:**
```bash
curl -i https://p8.rantila.com/shop/api/orders/1 \
  -H "Authorization: Bearer DITT_TOKEN"
```

**Förväntat:** 200 OK

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

### 9.4 Cancel Order (PUT /shop/api/orders/{id}/cancel) - JWT

- [ ] **Test:** Avbryt order

**Request:**
```bash
curl -i -X PUT https://p8.rantila.com/shop/api/orders/1/cancel \
  -H "Authorization: Bearer DITT_TOKEN"
```

**Förväntat:** 200 OK

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

## 10. SHOP SERVICE - PAYMENTS

**Base:** `https://p8.rantila.com/shop/api`

### 10.1 Initiate Payment (POST /shop/api/payments/initiate) - JWT

- [ ] **Test:** Starta betalning

**Request:**
```bash
curl -i -X POST https://p8.rantila.com/shop/api/payments/initiate \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer DITT_TOKEN" \
  -d '{
    "orderId": 1,
    "paymentMethod": "PAYPAL"
  }'
```

**Förväntat:** 200 OK

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

### 10.2 Process Payment (POST /shop/api/payments/process) - JWT

- [ ] **Test:** Slutför betalning

**Request:**
```bash
curl -i -X POST https://p8.rantila.com/shop/api/payments/process \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer DITT_TOKEN" \
  -d '{
    "orderId": 1,
    "paymentId": "PAYPAL_PAYMENT_ID",
    "payerId": "PAYPAL_PAYER_ID"
  }'
```

**Förväntat:** 200 OK

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

### 10.3 Get Payment Status (GET /shop/api/payments/{id}) - JWT

- [ ] **Test:** Hämta betalningsstatus

**Request:**
```bash
curl -i https://p8.rantila.com/shop/api/payments/1 \
  -H "Authorization: Bearer DITT_TOKEN"
```

**Förväntat:** 200 OK

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

## 11. SHOP SERVICE - SHIPMENTS

**Base:** `https://p8.rantila.com/shop/api`

### 11.1 Get Shipment (GET /shop/api/shipments/{orderId}) - JWT

- [ ] **Test:** Hämta fraktinfo

**Request:**
```bash
curl -i https://p8.rantila.com/shop/api/shipments/1 \
  -H "Authorization: Bearer DITT_TOKEN"
```

**Förväntat:** 200 OK

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

### 11.2 Update Shipment (PUT /shop/api/shipments/{id}) - ADMIN

- [ ] **Test:** Uppdatera fraktstatus

**Request:**
```bash
curl -i -X PUT https://p8.rantila.com/shop/api/shipments/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer DITT_TOKEN" \
  -d '{
    "status": "SHIPPED",
    "trackingNumber": "TRACK123456"
  }'
```

**Förväntat:** 200 OK

**Faktiskt resultat:**
```
Status: ______
Headers:


Response: 


```

---

## 12. SAMMANFATTNING

### Testresultat per Service

| Service | Totalt | ✅ Pass | ❌ Fail | ⏭️ Skip |
|---------|--------|---------|---------|---------|
| Auth | 5 | ___ | ___ | ___ |
| Blog | 6 | ___ | ___ | ___ |
| Image | 4 | ___ | ___ | ___ |
| Email | 2 | ___ | ___ | ___ |
| Products | 6 | ___ | ___ | ___ |
| Categories | 6 | ___ | ___ | ___ |
| Customers | 2 | ___ | ___ | ___ |
| Cart | 5 | ___ | ___ | ___ |
| Orders | 4 | ___ | ___ | ___ |
| Payments | 3 | ___ | ___ | ___ |
| Shipments | 2 | ___ | ___ | ___ |
| **TOTALT** | **45** | ___ | ___ | ___ |

---

### Problem att Fixa

| # | Service | Endpoint | Problem | HTTP Status | Prioritet |
|---|---------|----------|---------|-------------|-----------|
| 1 | | | | | |
| 2 | | | | | |
| 3 | | | | | |
| 4 | | | | | |
| 5 | | | | | |
| 6 | | | | | |
| 7 | | | | | |
| 8 | | | | | |
| 9 | | | | | |
| 10 | | | | | |

---

### Vanliga HTTP-statuskoder

| Status | Betydelse | Åtgärd |
|--------|-----------|--------|
| 200 | OK | ✅ Fungerar |
| 201 | Created | ✅ Skapad |
| 204 | No Content | ✅ Borttagen |
| 400 | Bad Request | Felaktig request body |
| 401 | Unauthorized | Token saknas/ogiltig |
| 403 | Forbidden | Saknar behörighet |
| 404 | Not Found | Endpoint/resurs finns ej |
| 409 | Conflict | Duplicerat (t.ex. email) |
| 500 | Server Error | Kontrollera loggar |

---

### Noteringar

```




```

---

**Testat av:** _______________  
**Datum:** _______________  
**Signatur:** _______________
