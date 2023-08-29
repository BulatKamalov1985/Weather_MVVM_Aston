//
//  ViewController.swift
//  Weather_MVVM_Aston
//
//  Created by Bulat Kamalov on 20.08.2023.


import UIKit
import CoreLocation

class WeatherDetailViewController: UIViewController, CLLocationManagerDelegate {
    
    var cities: [String] = []
    var city: String = ""
    var locationManager: CLLocationManager!
    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let cityLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let temperatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 92)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let weatherLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let maxTemperatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let minTemperatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let temperatureStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 10
        return stackView
    }()
    let searchTextField: UITextField = {
        let textfield = UITextField()
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.placeholder = "Введите название города"
        textfield.borderStyle = .roundedRect
        return textfield
    }()
    let searchButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Поиск", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImageView.image = UIImage(named: "backgroundWeatherApp")
        setupUI()
        setupNavigationBar()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(title: "Сохранить город", style: .plain, target: self, action: #selector(addCityButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    func setupUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(temperatureLabel)
        view.addSubview(cityLabel)
        view.addSubview(weatherLabel)
        view.addSubview(temperatureStackView)
        view.addSubview(maxTemperatureLabel)
        view.addSubview(minTemperatureLabel)
        view.addSubview(searchTextField)
        view.addSubview(searchButton)
        temperatureStackView.addArrangedSubview(maxTemperatureLabel)
        temperatureStackView.addArrangedSubview(minTemperatureLabel)
    
        NSLayoutConstraint.activate([
            
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            cityLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            cityLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cityLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            temperatureLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 0),
            temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            weatherLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 0),
            weatherLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            temperatureStackView.topAnchor.constraint(equalTo: weatherLabel.bottomAnchor, constant: 10),
            temperatureStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            temperatureStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            
            searchTextField.topAnchor.constraint(equalTo: minTemperatureLabel.bottomAnchor, constant: 20),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            searchButton.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 20),
            searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchButton.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Получаем координаты местоположения
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        // Создаем URL для запроса к API с использованием полученных координат
        guard let weatherURL = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(WeatherServices.ApiKey)&units=\(Units.metric)") else { return }
        
        // Выполняем запрос и обработку данных
        NetworkServiceManager.shared.fetchData(from: weatherURL) { [weak self] data, _, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let weather = try decoder.decode(Weather.self, from: data)
                    DispatchQueue.main.async {
                        self.updateLabels(with: weather)
                        self.addCityToCityList(self.city)
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }
    }
    
    
    func fetchWeatherData() {
        guard let weatherURL = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(WeatherServices.ApiKey)&units=\(Units.metric)") else { return }
        
        NetworkServiceManager.shared.fetchData(from: weatherURL) { [weak self] data, _, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let weather = try decoder.decode(Weather.self, from: data)
                    DispatchQueue.main.async {
                        self.updateLabels(with: weather)
                        self.addCityToCityList(self.city)
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }
    }
    
    func addCityToCityList(_ city: String) {
        if !cities.contains(city) {
            cities.append(city)
        }
    }
    
    func saveCitiesToUserDefaults() {
        UserDefaults.standard.set(cities, forKey: "CityList")
    }
    
    func updateLabels(with weather: Weather) {
        let cityName = weather.name
        let temperature = weather.main.temp
        let weatherDescription = weather.weather.first?.description ?? "N/A"
        let maxTemperature = weather.main.tempMax
        let minTemperature = weather.main.tempMin
        
        cityLabel.text = cityName
        minTemperatureLabel.text = "Мин.: \(Int(minTemperature))°"
        maxTemperatureLabel.text = "Макс.: \(Int(maxTemperature))°"
        weatherLabel.text = "\(weatherDescription)"
        temperatureLabel.text = "\(Int(temperature))°"
    }
    
    @objc func addCityButtonTapped() {
        let cityName = cityLabel.text ?? ""
        addCityToCityList(cityName)
        saveCitiesToUserDefaults()
        
        if let tabBarController = self.tabBarController,
           let cityListNavigationController = tabBarController.viewControllers?[1] as? UINavigationController,
           let cityListViewController = cityListNavigationController.topViewController as? CityListTableViewController {
            cityListViewController.cities.append(cityName)
            cityListViewController.saveCitiesToUserDefaults()
            cityListViewController.tableView.reloadData()
        }
    }
    
    
    @objc func searchButtonTapped() {
        locationManager.stopUpdatingLocation()
        guard let searchCity = searchTextField.text else { return }
        city = searchCity
        fetchWeatherData() // Выполняем поиск погоды для введенного города
    }
}
