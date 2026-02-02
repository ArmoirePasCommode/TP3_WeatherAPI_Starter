// TP3 - Weather Data Aggregator
// Async Fetching Functions

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// HELPER: Wrapper cross-platform pour URLSession (fourni)
// Cette fonction fonctionne sur macOS, Linux et Windows
@available(macOS 10.15, *)
func fetchData(from url: URL) async throws -> (Data, URLResponse) {
#if os(macOS)
    if #available(macOS 12.0, *) {
        return try await URLSession.shared.data(from: url)
    }
#endif
    
    return try await withCheckedThrowingContinuation { continuation in
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                continuation.resume(throwing: error)
                return
            }
            guard let data = data, let response = response else {
                continuation.resume(throwing: URLError(.badServerResponse))
                return
            }
            continuation.resume(returning: (data, response))
        }
        task.resume()
    }
}

// 4. FETCH FUNCTIONS (8 pts)

// TODO 4.1: Fonction buildWeatherURL(latitude:longitude:) -> URL? (1 pt)
// URL: https://api.open-meteo.com/v1/forecast?latitude=XX&longitude=YY&current_weather=true

// TODO 4.2: Fonction async fetchWeather(for city: City) throws -> CurrentWeather (3 pts)
// - Construire l'URL
// - Utiliser fetchData(from: url) pour obtenir (data, response)
// - Vérifier code HTTP 200-299
// - JSONDecoder().decode(WeatherResponse.self, from: data)
// - Retourner currentWeather

// TODO 4.3: Fonction async fetchMultipleCities(cities, cache) -> [(City, Result<CurrentWeather, Error>)] (4 pts)
// - withTaskGroup
// - Pour chaque ville: group.addTask { ... }
// - Vérifier cache avant fetch
// - Mettre en cache après fetch réussi
// - Collecter tous les résultats avec for await
