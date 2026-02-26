// TP3 - Weather Data Aggregator
// Main Manager

import Foundation

final class WeatherAPIManager {
    static let shared = WeatherAPIManager()
    private init() {}

    func run() async {
        print("=== Weather Data Aggregator ===\n")
        let cities = [
            City(name: "Paris", latitude: 48.8566, longitude: 2.3522),
            City(name: "London", latitude: 51.5074, longitude: -0.1278),
            City(name: "New York", latitude: 40.7128, longitude: -74.0060),
            City(name: "Tokyo", latitude: 35.6895, longitude: 139.6917),
            City(name: "Sydney", latitude: -33.8688, longitude: 151.2093),
            City(name: "Berlin", latitude: 52.5200, longitude: 13.4050),
            City(name: "Madrid", latitude: 40.4168, longitude: -3.7038),
            City(name: "Rome", latitude: 41.9028, longitude: 12.4964),
            City(name: "Ottawa", latitude: 45.4215, longitude: -75.6972),
            City(name: "Cairo", latitude: 30.0444, longitude: 31.2357)
        ]
        let cache = WeatherCache()
        
        func performAndDisplayFetch(label: String) async {
            print("--- \(label) ---")
            let start = Date()
            let results = await fetchMultipleCities(cities: cities, cache: cache)
            let end = Date()
            let duration = end.timeIntervalSince(start)

            var successCount = 0
            var temps: [Double] = []

            for (city, result) in results {
                switch result {
                case .success(let weather):
                    print("✓ \(city.name): \(weather.temperature)°C, Wind: \(weather.windspeed) km/h")
                    successCount += 1
                    temps.append(weather.temperature)
                case .failure(let error):
                    print("✗ \(city.name): Error - \(error.localizedDescription)")
                }
            }
            print("\nStatistics:")
            print("- Total: \(cities.count) | Success: \(successCount) | Failed: \(cities.count - successCount)")
            if !temps.isEmpty {
                let avg = temps.reduce(0, +) / Double(temps.count)
                print("- Temperature: avg \(String(format: "%.1f", avg))°C | min \(temps.min()!)°C | max \(temps.max()!)°C")
            }
            
            let stats = await cache.getStats()
            print("- Cache: hits \(stats.hits) | misses \(stats.misses) | hit rate \(String(format: "%.1f", stats.total > 0 ? (Double(stats.hits) / Double(stats.total) * 100) : 0))%")
            print("- Execution Time: \(String(format: "%.2f", duration))s\n")
        }
        await performAndDisplayFetch(label: "First Fetch (Network)")
        await performAndDisplayFetch(label: "Second Fetch (Cache)")
    }
}
