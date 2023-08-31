//
//  TableViewController.swift
//  Weather_MVVM_Aston
//
//  Created by Bulat Kamalov on 20.08.2023.
//

import UIKit

final class CityListTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var cities: [String] = []

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadCitiesFromUserDefaults()
    
    }

    // MARK: - TableView Setup
    
    private func setupTableView() {
        tableView.register(CityTableViewCell.self, forCellReuseIdentifier: CityTableViewCell.reuseIdentifier)
    }

    // MARK: - TableView Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CityTableViewCell.reuseIdentifier, for: indexPath) as! CityTableViewCell
        let cityName = cities[indexPath.row]
        cell.configure(cityName: cityName)
        return cell
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete {
               _ = cities.remove(at: indexPath.row)
               saveCitiesToUserDefaults()
               tableView.deleteRows(at: [indexPath], with: .fade)
               
               // Обновление cities в WeatherMainViewController
               if let weatherMainViewController = presentingViewController as? WeatherMainViewController {
                   weatherMainViewController.cities = cities
                   weatherMainViewController.saveCitiesToUserDefaults()
               }
           }
       }

    // MARK: - Data Handling
    
    private func loadCitiesFromUserDefaults() {
        if let savedCities = UserDefaults.standard.array(forKey: "CityList") as? [String] {
            cities = savedCities
        }
    }

    func saveCitiesToUserDefaults() {
        UserDefaults.standard.set(cities, forKey: "CityList")
    }
}

