//
//  ViewController.swift
//  lab3 Wether Name
//
//  Created by Aashish Gautam on 2023-03-19.
//

import UIKit
import CoreLocation


class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    

    @IBOutlet weak var timeLable: UILabel!
    @IBOutlet var allView: UIView!
    
    @IBOutlet weak var wetherImageView: UIImageView!
    
    @IBOutlet weak var tempratureLable: UILabel!
    
    @IBOutlet weak var locationLable: UILabel!
    
    @IBOutlet weak var searchtextField: UITextField!
    var liveLocation :String = ""
    var showFaranite: Bool = false
    let locationManager = CLLocationManager()
    
    
    


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.requestWhenInUseAuthorization()
        
        searchtextField.delegate = self
        displayImage()
//        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
//            locationManager.desiredAccuracy = kCLLocationAccuracyBest
//            locationManager.allowsBackgroundLocationUpdates = true
//        }
        
        
        

    }
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       guard let location = locations.last else {
           return
           
       }
//        print(location.coordinate)
        let latitude = location.coordinate.latitude
       let longitude = location.coordinate.longitude
//       print("Latitude: \(latitude), Longitude: \(longitude)")
        liveLocation = "\(latitude),\(longitude)"
        print(liveLocation)
         locationManager.stopUpdatingLocation()
   }
    
    private func displayImage(){
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemYellow, .systemBlue,.white])
        wetherImageView.preferredSymbolConfiguration = config
        wetherImageView.image = UIImage(systemName: "globe.asia.australia.fill")
    }

    @IBAction func searchButtonTapped(_ sender: UIButton) {
        loadwether(search: searchtextField.text)
//        print("buttom pressed")
//        print(searchtextField.text as Any)
    }
    
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//       guard let location = locations.last else {
//           return
//
//       }
//        let latitude = location.coordinate.latitude
//       let longitude = location.coordinate.longitude
//       print("Latitude: \(latitude), Longitude: \(longitude)")
//        liveLocation = "\(latitude),\(longitude)"
//        print(liveLocation)
//   }
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        
        print("this is",liveLocation)
//        getURL(qurry: liveLocation)
        loadwether(search: liveLocation)
       
    }
    
    private func loadwether(search: String?){
        guard let search = search else{
            print("Search is empty")
            return
        }
//        connecting api
//        get URL
        guard let url = getURL(qurry: search) else{
            print("cound not get url")
            
            return
        }
//        create URL session
        let session = URLSession.shared
//      create task for api
        let dataTask = session.dataTask(with: url) { data, response, error in
            print("call made")
            
            guard error == nil else {
                print("error: ", error!)
                return
            }
            
            guard let data = data else{
                print("No data found")
                      return
            }
            print(String(data: data, encoding: .utf8) ?? "tttttttttt")

            if let wtherResponse = self.parseJSON(data: data){
                print(wtherResponse.location.name)
                print(wtherResponse.current.temp_c)
                print(wtherResponse.current.condition.code)
                print(wtherResponse.current.is_day)
//                let temprature = wtherResponse.current.temp_c
                DispatchQueue.main.async {
                    self.timeLable.text = wtherResponse.current.condition.text
                    if self.showFaranite == true{
                        self.tempratureLable.text = "\(wtherResponse.current.temp_f)F"
                    }else{
                        self.tempratureLable.text = "\(wtherResponse.current.temp_c)C"
                    }
                   
                    self.locationLable.text = wtherResponse.location.name
                    switch wtherResponse.current.condition.code {
                    case 1000:
                        self.wetherImageView.image = UIImage(systemName: "sun.max")
                    case 1003:
                        self.wetherImageView.image = UIImage(systemName: "cloud.sun.fill")
                    case 1006:
                        self.wetherImageView.image = UIImage(systemName: "cloud.fill")
                    case 1030:
                        self.wetherImageView.image = UIImage(systemName: "cloud.fog")
                    case 1195:
                        self.wetherImageView.image = UIImage(systemName: "cloud.hail")
                    case 1063:
                        self.wetherImageView.image = UIImage(systemName: "cloud.drizzle")
                    case 1009:
                        self.wetherImageView.image = UIImage(systemName: "smoke")
                    default:
                        self.wetherImageView.image = UIImage(systemName: "globe.asia.australia.fill")
                    }
                    if wtherResponse.current.is_day == 0{
                        self.allView.backgroundColor = UIColor.darkGray
                        self.wetherImageView.image = UIImage(systemName: "moon.stars.fill")
                    }
                    else{
                        self.allView.backgroundColor = UIColor.white
                    }
                   }
                
            }
            
            
        }
//        start task
        
        dataTask.resume()
        
    }
    
    
    @IBAction func onTempChange(_ sender: UIButton) {
        print("presed")
        if showFaranite{
            showFaranite = false
            sender.setTitle("Feranite", for: .normal)
        }else{
            showFaranite = true
            sender.setTitle("Celcius", for: .normal)
        }
        print(showFaranite)
        loadwether(search: searchtextField.text)
    }
    
    private func getURL(qurry:String)->URL?{
        let baseUrl = "https://api.weatherapi.com/v1"
        let currentEngpoint = "/current.json"
        let apiKey = "1d2404f97636490183c213132231903"
        guard let url = "\(baseUrl)\(currentEngpoint)?key=\(apiKey)&q=\(qurry)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
            return nil
        }
        print(url)
        return URL(string: url)
        
//        let url = "https://api.weatherapi.com/v1/current.json?key=b97ba85634214645ade195649231903&q=london ontario&aqi=no"
    }
    
    private func parseJSON(data:Data)-> WetherResponce? {
        let decoder  = JSONDecoder()
        var wether: WetherResponce?
        do{
            wether = try decoder.decode(WetherResponce.self, from: data)
            
        } catch{
            print("Error while decoding", error)
        }
        return wether
    }
    
    struct WetherResponce: Decodable {
        let location: Location
        let current: Wether
    }
    
    struct Location: Decodable{
        let name: String
        let localtime: String
    }
    struct Wether: Decodable{
        let temp_c: Float
        let temp_f: Float
        let condition : WetherCondition
        let is_day: Int
//        let text : String
    }
    struct WetherCondition: Decodable{
        let text: String
        let code: Int
    }
    
}

extension ViewController{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        loadwether(search: searchtextField.text)
        textField.endEditing(true)
        return true
    }
}

