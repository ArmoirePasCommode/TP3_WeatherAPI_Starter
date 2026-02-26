// TP3 - Weather Data Aggregator
// Weather Models

import Foundation

struct CurrentWeather: Decodable {
    let temperature: Double
    let windspeed: Double
    let weathercode: Int
}
struct WeatherResponse: Decodable {
    let latitude: Double
    let longitude: Double
    let currentWeather: CurrentWeather

    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case currentWeather = "current_weather"
    }
}
struct City {
    let name: String
    let latitude: Double
    let longitude: Double
}
enum WeatherError: Error {
    case invalidURL
    case networkError(String)
    case decodingError(String)
}
