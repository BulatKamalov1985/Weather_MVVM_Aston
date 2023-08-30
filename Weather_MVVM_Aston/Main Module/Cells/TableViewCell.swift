//
//  TableViewCell.swift
//  Weather_MVVM_Aston
//
//  Created by Bulat Kamalov on 23.08.2023.
//

import UIKit

class CityTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static var reuseIdentifier: String { "\(Self.self)" }
    
    let cityNameLabel = UILabel()
    let temperatureLabel = UILabel()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    func configure(cityName: String) {
        cityNameLabel.text = cityName
        fetchTemperature(for: cityName)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        cityNameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cityNameLabel)
        
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(temperatureLabel)
        
        NSLayoutConstraint.activate([
            cityNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cityNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            temperatureLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            temperatureLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // MARK: - Data Fetching
    
    private func fetchTemperature(for cityName: String) {
        guard let weatherURL = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=\(WeatherServices.ApiKey)&units=\(Units.metric)") else { return }
        
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
                        let temperature = weather.main.temp
                        self.temperatureLabel.text = "\(Int(temperature))°"
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }
    }
}
