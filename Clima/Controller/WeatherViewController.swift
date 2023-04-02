import UIKit
import CoreLocation


class WeatherViewController: UIViewController {

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextFeild: UITextField!

    @IBOutlet weak var backgroundImage: UIImageView!
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self//位置情報を要求する前にWeatherViewControllerをデリゲートとして設定する必要がある．
        locationManager.requestWhenInUseAuthorization()//ユーザに位置情報取得許可を求めるポップアップを表示
        locationManager.requestLocation()//初期位置を取得
        weatherManager.delegate = self
        searchTextFeild.delegate = self//TextFeildとユーザーのやり取りをViewControllerに伝える.textfieldの代理(delegate)をviewcontrollerが務める
    }
    
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    


}

//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate{
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextFeild.endEditing(true)//searchボタンが押されたとき，テキストフィールドの編集を終了しキーボードを解除
    }
    /* これらのメソッドはtextFieldがトリガーとなるデリゲートメソッド -->*/
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextFeild.endEditing(true)//"Go"が押されたとき，テキストフィールドの編集を終了しキーボードを解除
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {//ユーザーの入力を検証.
        if textField.text != "" {//テキストフィールドに何か書いてあれば
            return true//textFieldDidEndEditing()が実行される
        }else{
            textField.placeholder = "都市名を入力してください"//未入力の時，placeholderを変化させ
            return false//テキストフィールドの編集を終了しない．
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {//searchTextFeild.endEditingがtrueになったとき呼び出される
        if let city = searchTextFeild.text{
            weatherManager.fetchWeather(cityName: city)
        }
        
        searchTextFeild.text = ""
    }
    /*<---ここまで*/
}

//MARK: - WeatherManagerDelegate

extension WeatherViewController:WeatherManagerDelegate {//extensionでprotcolが要求する関数を定義．WeatherManagerDelegate Prは2つの関数を要求
    /* このメソッドはweatherManagerがトリガーとなるデリゲートメソッド -->*/
    func didUpdateWeather(_ weatherManager: WeatherManager, weather:WeatherModel){// _ を使うことで外部パラメータを省略可能
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString//complettion handler内からUIの更新を行うとき，メインスレッドでは実行できずバックグラウンドで実行する必要がある．
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            print(weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
        
    }
    
    func didFeildWithError(error: Error) {
        print(error)
    }

}

//MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate{//CLLocationManagerのDelegateには以下の関数の実装を要求．（デフォはCLLocationManagerで既存）
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {//位置情報が返ってきたとき
        if let location = locations.last{
            //locationManager.stopUpdatingLocation()//位置情報の取得をストップしておかないと2回目以降の呼び出しができない//そんなことないかも
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {//エラーが返ってきた時
        print(error)
    }
}
