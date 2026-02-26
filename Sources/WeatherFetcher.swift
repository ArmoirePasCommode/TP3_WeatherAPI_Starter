// TP3 - Weather Data Aggregator
// Async Fetching Functions

// 4. FETCH FUNCTIONS (8 pts)

import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif
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
func buildWeatherURL(latitude: Double, longitude: Double) -> URL? {
    let urlString =
        "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current_weather=true"
    return URL(string: urlString)
}
func fetchWeather(for city: City) async throws -> CurrentWeather {
    let url = buildWeatherURL(latitude: city.latitude, longitude: city.longitude)
    let (data, _) = try await fetchData(from: url!)
    let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
    return weatherResponse.currentWeather
}
func fetchMultipleCities(cities: [City], cache: WeatherCache) async -> [(
    City, Result<CurrentWeather, Error>
)] {
    return await withTaskGroup(of: (City, Result<CurrentWeather, Error>).self) { group in
        for city in cities {
            group.addTask {
                if let cached = await cache.get(city.name) {
                    return (city, .success(cached))
                }
                do {
                    let weather = try await fetchWeather(for: city)
                    await cache.set(weather, for: city.name)
                    return (city, .success(weather))
                } catch {
                    return (city, .failure(error))
                }
            }
        }

        var results: [(City, Result<CurrentWeather, Error>)] = []
        for await result in group {
            results.append(result)
        }
        return results
    }
}
