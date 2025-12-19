# Perfect8 Flutter Training - Pedagogisk Guide

**Version:** 1.0  
**Datum:** 2025-11-23  
**Författare:** Magnus & Claude  
**Syfte:** Lära Flutter genom att bygga en frontend till Perfect8 backend

---

## 📋 INNEHÅLLSFÖRTECKNING

1. [Översikt](#översikt)
2. [Projektstruktur](#projektstruktur)
3. [Hur Filerna Hänger Ihop](#hur-filerna-hänger-ihop)
4. [Steg-för-Steg Förklaring](#steg-för-steg-förklaring)
5. [Köra Appen](#köra-appen)
6. [Felsökning](#felsökning)
7. [Nästa Steg](#nästa-steg)

---

## 🎯 ÖVERSIKT

### Vad gör denna app?

Appen gör **Health Check** på alla Perfect8 backend-services:
- Admin Service (port 8081)
- Blog Service (port 8082)
- Email Service (port 8083)
- Image Service (port 8084)
- Shop Service (port 8085)

### Flödet:

```
Användare klickar knapp
        ↓
ApiService gör HTTP GET request
        ↓
Backend svarar med JSON
        ↓
HealthResponse konverterar JSON → Dart objekt
        ↓
UI uppdateras med resultat (✅ eller ❌)
```

---

## 📁 PROJEKTSTRUKTUR

```
flutter_training/
├── lib/
│   ├── main.dart                    # Startpunkt (void main())
│   ├── config/
│   │   └── api_config.dart          # API URL:er och portar
│   ├── models/
│   │   └── health_response.dart     # Data-modell för JSON
│   ├── services/
│   │   └── api_service.dart         # HTTP-anrop till backend
│   └── screens/
│       └── health_check_screen.dart # UI med knappar
├── pubspec.yaml                      # Dependencies (bibliotek)
└── docs/
    └── FLUTTER_GUIDE.md              # Denna fil
```

---

## 🔗 HUR FILERNA HÄNGER IHOP

### 1. main.dart (Startpunkt)
```dart
void main() {
  runApp(const Perfect8App());
}
```
→ Startar appen och visar HealthCheckScreen

### 2. api_config.dart (Konfiguration)
```dart
static const String baseUrl = 'http://localhost';
static String get adminHealth => '$adminUrl/actuator/health';
```
→ Definierar alla API-endpoints

### 3. health_response.dart (Data-modell)
```dart
class HealthResponse {
  final String status;
  factory HealthResponse.fromJson(Map<String, dynamic> json) { ... }
}
```
→ Konverterar JSON från backend till Dart-objekt

### 4. api_service.dart (HTTP-anrop)
```dart
Future<HealthResponse?> checkHealth(String serviceUrl) async {
  final response = await http.get(Uri.parse(serviceUrl));
  return HealthResponse.fromJson(json.decode(response.body));
}
```
→ Gör HTTP GET request och returnerar HealthResponse

### 5. health_check_screen.dart (UI)
```dart
ElevatedButton(
  onPressed: _checkAdminHealth,
  child: const Text('Admin Service (8081)'),
)
```
→ Visar knappar och resultat

---

## 🔄 STEG-FÖR-STEG FÖRKLARING

### Exempel: Användaren klickar "Admin Service (8081)"

#### Steg 1: Knapp-klick
```dart
// health_check_screen.dart
ElevatedButton(
  onPressed: _checkAdminHealth,  // ← Denna funktion anropas
  child: const Text('Admin Service (8081)'),
)
```

#### Steg 2: Uppdatera UI till "laddar..."
```dart
Future<void> _checkAdminHealth() async {
  setState(() {
    _isLoading = true;        // Visa laddnings-indikator
    _errorMessage = '';       // Rensa gamla fel
    _adminHealth = null;      // Rensa gammalt resultat
  });
```

#### Steg 3: Anropa API-service
```dart
  final result = await _apiService.checkAdminHealth();
```

#### Steg 4: ApiService gör HTTP request
```dart
// api_service.dart
Future<HealthResponse?> checkAdminHealth() async {
  return await checkHealth(ApiConfig.adminHealth);
  // ApiConfig.adminHealth = 'http://localhost:8081/actuator/health'
}
```

#### Steg 5: HTTP GET request
```dart
final response = await http.get(
  Uri.parse('http://localhost:8081/actuator/health'),
  headers: {'Content-Type': 'application/json'},
).timeout(const Duration(seconds: 5));
```

#### Steg 6: Backend svarar med JSON
```json
{
  "status": "UP",
  "components": {
    "db": {"status": "UP"}
  }
}
```

#### Steg 7: Konvertera JSON → Dart objekt
```dart
final Map<String, dynamic> jsonData = json.decode(response.body);
return HealthResponse.fromJson(jsonData);
```

#### Steg 8: Uppdatera UI med resultat
```dart
  setState(() {
    _adminHealth = result;    // Spara resultat
    _isLoading = false;       // Dölj laddnings-indikator
  });
}
```

#### Steg 9: UI visar resultat
```dart
// Status indicator visar ✅ eller ❌
Icon(
  healthResponse.isHealthy ? Icons.check : Icons.close,
  color: Colors.white,
)
```

---

## 🚀 KÖRA APPEN

### Förberedelser

1. **Starta backend:**
```bash
# På servern eller lokalt
docker compose up -d
```

2. **Verifiera att services körs:**
```bash
curl http://localhost:8081/actuator/health
# Ska returnera: {"status":"UP"}
```

### Starta Flutter-appen

#### Alternativ 1: Chrome (Webbläsare)
```bash
cd flutter_training
flutter run -d chrome
```

#### Alternativ 2: Edge
```bash
flutter run -d edge
```

#### Alternativ 3: Lista tillgängliga enheter
```bash
flutter devices
# Välj sedan:
flutter run -d <device-id>
```

### Vad händer när appen startar?

1. Flutter kompilerar Dart-koden
2. `main()` körs
3. `Perfect8App` skapas
4. `HealthCheckScreen` visas
5. Du ser UI med knappar!

---

## 🐛 FELSÖKNING

### Problem: "Failed to load"

**Orsak:** Backend körs inte eller fel URL

**Lösning:**
1. Kontrollera att backend körs: `docker compose ps`
2. Testa manuellt: `curl http://localhost:8081/actuator/health`
3. Kolla `api_config.dart` att URL stämmer

### Problem: "Timeout after 5 seconds"

**Orsak:** Backend svarar långsamt eller hänger

**Lösning:**
1. Kolla backend-loggar: `docker compose logs admin-service`
2. Öka timeout i `api_service.dart`:
```dart
.timeout(const Duration(seconds: 10))  // Öka till 10 sekunder
```

### Problem: "Connection refused"

**Orsak:** Backend lyssnar inte på rätt port

**Lösning:**
1. Verifiera portar: `docker compose ps`
2. Testa med curl: `curl http://localhost:8081/actuator/health`
3. Kolla `docker-compose.yml` att ports stämmer

### Problem: Hot reload funkar inte

**Lösning:**
1. Tryck `r` i terminalen (restart)
2. Tryck `R` i terminalen (hot restart)
3. Starta om helt: `flutter run -d chrome`

---

## 🎨 GUI BEST PRACTICES

### 1. Material Design
Vi använder Material Design 3 (Googles design-system):
```dart
theme: ThemeData(
  useMaterial3: true,
  primarySwatch: Colors.blue,
),
```

### 2. Responsiv Layout
```dart
Padding(
  padding: const EdgeInsets.all(16.0),  // 16px padding överallt
  child: Column(...),
)
```

### 3. Tydliga Färger
- Grön = Healthy (UP)
- Röd = Unhealthy (DOWN)
- Grå = Inte testad än

### 4. Feedback till Användare
- Loading indicator under API-anrop
- Felmeddelanden i röd box
- Status-ikoner (✅ / ❌)

### 5. Disabled State
```dart
ElevatedButton(
  onPressed: _isLoading ? null : _checkAdminHealth,
  // null = knappen är disabled
)
```

---

## 📚 DART-KONCEPT SOM ANVÄNDS

### 1. Async/Await
```dart
Future<HealthResponse?> checkHealth(String url) async {
  final response = await http.get(Uri.parse(url));
  return HealthResponse.fromJson(json.decode(response.body));
}
```
- `Future<T>` = Returnerar värde i framtiden
- `async` = Funktionen är asynkron
- `await` = Vänta på resultat innan fortsättning

### 2. Null Safety
```dart
HealthResponse? _adminHealth;  // Kan vara null
String _errorMessage = '';      // Kan INTE vara null
```
- `?` = Nullable (kan vara null)
- Utan `?` = Non-nullable (måste ha värde)

### 3. setState()
```dart
setState(() {
  _adminHealth = result;
});
```
→ Uppdaterar UI när state ändras

### 4. Factory Constructor
```dart
factory HealthResponse.fromJson(Map<String, dynamic> json) {
  return HealthResponse(
    status: json['status'] as String,
  );
}
```
→ Skapar objekt från JSON

### 5. Getters
```dart
bool get isHealthy => status.toLowerCase() == 'up';
```
→ Beräknad property (fungerar som en metod men ser ut som en variabel)

---

## ➡️ NÄSTA STEG

### Steg 2: Customer Registration

Nu när Health Check fungerar, nästa steg är att bygga:

**Ny skärm: register_screen.dart**
- Formulär med email, password, firstName, lastName
- Validering av input
- POST request till `/api/v1/customers/register`
- Hantera svar (success / error)

**Nya modeller:**
- `register_request.dart` - Data att skicka
- `register_response.dart` - Svar från backend

**Uppdaterad ApiService:**
- `registerCustomer()` metod
- POST request istället för GET

### Steg 3: Customer Login

Efter registrering bygger vi:

**Ny skärm: login_screen.dart**
- Formulär med email, password
- POST request till `/api/v1/customers/login`
- Spara JWT token lokalt
- Navigera till "Home" efter lyckad login

**Nya modeller:**
- `login_request.dart`
- `login_response.dart` (med JWT token)

---

## 🎯 SAMMANFATTNING

### Vad vi lärt oss:

✅ **Flutter projekt-struktur** (lib/, models/, services/, screens/)  
✅ **HTTP requests** med `http` package  
✅ **JSON parsing** med `dart:convert`  
✅ **State management** med `setState()`  
✅ **UI widgets** (Scaffold, AppBar, ElevatedButton, etc.)  
✅ **Async programming** (Future, async, await)  
✅ **Material Design** för proffsigt GUI

### Viktiga filer:

1. **api_config.dart** - API URLs
2. **health_response.dart** - Data-modell
3. **api_service.dart** - HTTP-anrop
4. **health_check_screen.dart** - UI
5. **main.dart** - Startpunkt

---

## 📞 SUPPORT

**Problem?** Kolla:
1. Backend körs: `docker compose ps`
2. Portar öppna: `curl http://localhost:8081/actuator/health`
3. Flutter console för fel-meddelanden

**Frågor?** Dokumentationen finns i:
- `docs/FLUTTER_GUIDE.md` (denna fil)
- Backend API: `Perfect8_API_Guide_v1.0.md`

---

**Version:** 1.0  
**Senast uppdaterad:** 2025-11-23  
**Licens:** MIT  
**GitHub:** https://github.com/Perfect8-v1/backend

---

*Med denna guide har du allt du behöver för att förstå och vidareutveckla Flutter-frontenden! 🚀*
