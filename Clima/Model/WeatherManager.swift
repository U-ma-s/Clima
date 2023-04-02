
import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather:WeatherModel)
    func didFeildWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "{your Open Weather'API key}"
    
    
    var delegate: WeatherManagerDelegate?//WeatherViewControllerクラス側でWeatherManagerのdelegateをWeatherViewControllerに設定．
    
    func fetchWeather(cityName: String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {//withはただの外部パラメータ名//可読性の向上のため
        //1.Create a URL
        if let url = URL(string: urlString){//URLの作成に失敗する場合もあるのでoptional
            
            //2.Create a URLSession
            let session = URLSession(configuration: .default)
            
            //3.Give the Session a Task
            let task = session.dataTask(with: url) { data, respons, error in//dataTask will be finished -> closure(completion handler) will be called and do bellow
                if error != nil {
                    self.delegate?.didFeildWithError(error: error!)//closure内でもself不要になった？
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)//selfは"_"で省略された外部パラメータにWeatherManager型を渡す
                    }
                    
                }
            }
            /*↑completion handler*/
            //4.Start a task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)//decode(data type,data) //selfで型を参照
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            let weather = WeatherModel(conditionId: id, cityName: name, temprature: temp)
            return weather
        } catch {
            delegate?.didFeildWithError(error: error)//delegate(WeatherViewController側で宣言されたdidFeildWithError()を呼び出すことのみ宣言，具体的な処理はdelegate側で設定)
            return nil
        }
        
    }
    

    
}
