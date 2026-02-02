// TP3 - Weather Data Aggregator
// Main Manager

import Foundation

final class WeatherAPIManager {
    static let shared = WeatherAPIManager()
    private init() {}

    func run() async {
        print("=== Weather Data Aggregator ===\n")

        // TODO 5.1: Créer array de 10 villes (1 pt)
        // Exemples: Paris (48.8566, 2.3522), London (51.5074, -0.1278), etc.

        // TODO 5.2: Créer WeatherCache + mesurer temps (1 pt)

        // TODO 5.3: Appeler fetchMultipleCities et afficher résultats (2 pts)
        // ✓ Paris: 12.3°C, Wind: 15.2 km/h
        // ✗ London: Error - ...

        // TODO 5.4: Calculer et afficher statistiques (3 pts)
        // - Total/Success/Failed
        // - Température avg/min/max
        // - Cache hits/misses/hit rate
        // - Temps d'exécution

        // BONUS: Deuxième fetch pour tester le cache (+2 pts)
    }
}
