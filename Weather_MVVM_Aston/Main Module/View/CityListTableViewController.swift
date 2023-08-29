//
//  TableViewController.swift
//  Weather_MVVM_Aston
//
//  Created by Bulat Kamalov on 20.08.2023.
//

import UIKit

class CityListTableViewController: UITableViewController {
    
    var cities: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(CityTableViewCell.self, forCellReuseIdentifier: CityTableViewCell.reuseIdentifier)
        loadCitiesFromUserDefaults()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(cities)
        return cities.count
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CityTableViewCell.reuseIdentifier, for: indexPath) as! CityTableViewCell
        let cityName = cities[indexPath.row]
        cell.configure(cityName: cityName)
        return cell
    }

    func loadCitiesFromUserDefaults() {
        if let savedCities = UserDefaults.standard.array(forKey: "CityList") as? [String] {
            cities = savedCities
        }
    }

    func saveCitiesToUserDefaults() {
        UserDefaults.standard.set(cities, forKey: "CityList")
    }
}
