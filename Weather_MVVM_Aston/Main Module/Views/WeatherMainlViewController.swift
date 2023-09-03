//
//  ViewController.swift
//  Weather_MVVM_Aston
//
//  Created by Bulat Kamalov on 20.08.2023.


import UIKit
import CoreLocation

final class WeatherMainViewController: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Properties
    
    var cities: [String] = []
    private var city: String = ""
    private var locationManager: CLLocationManager?
    private var saveButton: UIBarButtonItem?
        
    // MARK: - UI Elements
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 92)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let weatherLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let maxTemperatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let minTemperatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let temperatureStackView: UIStackView = {
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
    
    private let searchButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Поиск", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSavedCities()
        backgroundImageView.image = UIImage(named: "backgroundWeatherApp")
        setupUI()
        setupNavigationBar()
        setupLocationManager()
        searchTextField.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        loadCitiesFromUserDefaults()

    }
    
    // MARK: - Private Methods
    
    private func loadSavedCities() {
        if let savedCities = UserDefaults.standard.array(forKey: "CityList") as? [String] {
            cities = savedCities
        }
    }
    
    private func setupNavigationBar() {
        saveButton = UIBarButtonItem(title: "Save city", style: .plain, target: self, action: #selector(addCityButtonTapped))
        saveButton?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        navigationItem.rightBarButtonItem = saveButton
    }

    private func setupUI() {
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
    
    private func setupLocationManager() {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.requestWhenInUseAuthorization()
            locationManager?.startUpdatingLocation()
        }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        guard let weatherURL = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(WeatherServices.ApiKey)&units=\(Units.metric)") else { return }
        
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
    
    
    private func fetchWeatherData() {
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
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }
    }
    
    private func addCityToCityList(_ city: String) {
            cities.append(city)
    }
    
    func saveCitiesToUserDefaults() {
        UserDefaults.standard.set(cities, forKey: "CityList")
    }
    
    private func loadCitiesFromUserDefaults() {
        if let savedCities = UserDefaults.standard.array(forKey: "CityList") as? [String] {
            cities = savedCities
        }
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
    
    // MARK: - Button Actions
    
    private func textFieldDidChange(_ textField: UITextField, newText: String) {
            if !newText.isEmpty {
                saveButton?.title = "Save city"
                saveButton?.isEnabled = true
            } else {
                saveButton?.title = "City saved"
                saveButton?.isEnabled = false
            }
        }
    
    @objc private func addCityButtonTapped() {
            let cityName = cityLabel.text ?? ""
            
            if !cities.contains(cityName) {
                addCityToCityList(cityName)
                saveCitiesToUserDefaults()
                handleResult(city, isSuccess: true)
                
                if let tabBarController = self.tabBarController,
                   let cityListNavigationController = tabBarController.viewControllers?[1] as? UINavigationController,
                   let cityListViewController = cityListNavigationController.topViewController as? CityListTableViewController {
                    cityListViewController.cities.append(cityName)
                    cityListViewController.saveCitiesToUserDefaults()
                    cityListViewController.tableView.reloadData()
                }
            } else {
                print("The city is already in the list.")
                handleResult(city, isSuccess: false)
            }
            textFieldDidChange(searchTextField, newText: "")
        }
    
    func handleResult(_ city: String, isSuccess: Bool) {
        let title: String
        let message: String
        
        if isSuccess {
            title = "Отлично!"
            message = "Город \(city) удачно сохранен"
        } else {
            title = "Извините!"
            message = "Город \(city) уже есть в списке"
        }
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Ok", style: .default)
        ac.addAction(cancel)
        self.present(ac, animated: true)
    }

    @objc private func searchButtonTapped() {
        locationManager?.stopUpdatingLocation()
        guard let searchCity = searchTextField.text else { return }
        city = searchCity
        fetchWeatherData()
        searchTextField.text = ""
    }
}


extension WeatherMainViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        textFieldDidChange(textField, newText: newText)
        return true
    }
}
