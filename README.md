# TP3 - Weather Data Aggregator

## Objectif

Créer une application CLI qui récupère en parallèle les données météo de 10 villes depuis une API REST, avec un système de cache thread-safe.

**Durée**: 2h
**Notation**: /20 (20% de la note finale)
**Rendu**: URL du repository GitHub

## Ce que vous allez apprendre

- Faire des requêtes HTTP asynchrones avec URLSession
- Décoder du JSON avec Codable
- Utiliser async/await pour la concurrence
- Implémenter un cache thread-safe avec Actor
- Paralléliser des tâches avec Task Groups
- Gérer les erreurs asynchrones

## API Météo

**Open-Meteo** (gratuite, sans auth)

```
https://api.open-meteo.com/v1/forecast?latitude=48.8566&longitude=2.3522&current_weather=true
```

**Réponse JSON:**
```json
{
  "latitude": 48.8566,
  "longitude": 2.3522,
  "current_weather": {
    "temperature": 12.3,
    "windspeed": 15.2,
    "weathercode": 0
  }
}
```

## Architecture du projet

Le projet est déjà structuré en 5 fichiers. Vous devez compléter les TODOs:

```
Sources/
├── WeatherModels.swift        // Structs Decodable + enums
├── WeatherCache.swift          // Actor pour cache thread-safe
├── WeatherFetcher.swift        // Fonctions async pour fetch API
├── WeatherAPIManager.swift     // Orchestration et affichage
└── WeatherAPIPackage.swift     // Point d'entrée @main
```

## Fonctionnalités attendues

### 1. Modèles de données (WeatherModels.swift)

Créer les structures pour parser la réponse JSON:
- `WeatherResponse` avec latitude, longitude, current_weather
- `CurrentWeather` avec temperature, windspeed, weathercode
- `City` avec name, latitude, longitude
- `WeatherError` pour les erreurs (invalidURL, networkError, decodingError)

### 2. Cache thread-safe (WeatherCache.swift)

Implémenter un `actor WeatherCache`:
- `get(_ cityName: String) -> CurrentWeather?`
- `set(_ weather: CurrentWeather, for cityName: String)`
- `getStats() -> (hits: Int, misses: Int, total: Int)`

L'actor garantit automatiquement qu'il n'y aura pas de data races.

### 3. Fetch asynchrone (WeatherFetcher.swift)

```swift
func fetchWeather(for city: City) async throws -> CurrentWeather
```

Cette fonction doit:
- Construire l'URL avec latitude/longitude
- Utiliser `fetchData(from: url)` (wrapper fourni qui fonctionne partout)
- Vérifier le code HTTP (200-299)
- Décoder le JSON avec JSONDecoder
- Throw une erreur appropriée en cas de problème

**Note**: Une fonction `fetchData(from: URL)` est déjà fournie dans le fichier. Elle remplace `URLSession.shared.data(from:)` et fonctionne sur toutes les plateformes (macOS, Linux, Windows).

### 4. Fetch parallèle (WeatherFetcher.swift)

```swift
func fetchMultipleCities(_ cities: [City], cache: WeatherCache) async -> [(City, Result<CurrentWeather, Error>)]
```

Utiliser `withTaskGroup` pour:
- Lancer un fetch par ville en parallèle
- Vérifier le cache avant de fetch
- Mettre en cache les résultats
- Retourner tous les résultats (succès et erreurs)

### 5. Statistiques (WeatherAPIManager.swift)

Afficher:
- Nombre de villes fetchées avec succès/échec
- Température moyenne, minimum, maximum
- Statistiques du cache (hits, misses, hit rate)
- Temps total d'exécution

## Villes à utiliser

```swift
let cities = [
    City(name: "Paris", latitude: 48.8566, longitude: 2.3522),
    City(name: "London", latitude: 51.5074, longitude: -0.1278),
    City(name: "Tokyo", latitude: 35.6762, longitude: 139.6503),
    City(name: "New York", latitude: 40.7128, longitude: -74.0060),
    City(name: "Sydney", latitude: -33.8688, longitude: 151.2093),
    City(name: "Berlin", latitude: 52.5200, longitude: 13.4050),
    City(name: "Moscow", latitude: 55.7558, longitude: 37.6173),
    City(name: "Dubai", latitude: 25.2048, longitude: 55.2708),
    City(name: "São Paulo", latitude: -23.5505, longitude: -46.6333),
    City(name: "Mumbai", latitude: 19.0760, longitude: 72.8777)
]
```

## Compilation et exécution

```bash
cd TP3_WeatherAPI_Starter
swift build
swift run
```

## Exemple de sortie attendue

```
=== Weather Data Aggregator ===

Fetching weather data for 10 cities...

✓ Paris: 12.3°C, Wind: 15.2 km/h
✓ London: 10.5°C, Wind: 18.7 km/h
✓ Tokyo: 8.9°C, Wind: 12.1 km/h
...

=== Statistics ===
Total cities: 10
Successful: 10
Failed: 0
Average temperature: 14.5°C
Warmest: Dubai at 28.5°C
Coldest: Moscow at -2.3°C

=== Cache Statistics ===
Cache hits: 0
Cache misses: 10
Hit rate: 0.0%

Execution time: 1.23s
```

## Critères d'évaluation (/20)

| Critère | Points |
|---------|--------|
| 1. Models + Errors (WeatherModels.swift) | 3 |
| 2. Actor WeatherCache (WeatherCache.swift) | 4 |
| 3. Fetch Functions (WeatherFetcher.swift) | 8 |
| 4. Manager + Stats (WeatherAPIManager.swift) | 5 |
| **Total** | **20** |
| Bonus: Test cache avec 2e fetch | +2 |

## Notes importantes
- Le projet compile sur macOS, Linux et Windows
- Nécessite Swift 5.9+ avec support concurrency (async/await)
- Une fonction `fetchData(from: URL)` est fournie dans WeatherFetcher.swift
- Cette fonction remplace `URLSession.shared.data(from:)` et fonctionne partout
- Utilisez toujours `fetchData(from:)` au lieu de URLSession directement
- L'API Open-Meteo est gratuite mais limitée, ne spammez pas
