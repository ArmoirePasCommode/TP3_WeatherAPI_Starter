import Foundation

@main
struct WeatherAPIPackage {
    static func main() async {
        await WeatherAPIManager.shared.run()
    }
}
