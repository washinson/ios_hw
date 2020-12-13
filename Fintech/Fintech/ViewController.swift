//
//  ViewController.swift
//  Fintech
//
//  Created by alex on 13.12.2020.
//  Copyright © 2020 washinson. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var companyLogo: UIImageView!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var companySymbolLabel: UILabel!
    @IBOutlet weak var companyPickerView: UIPickerView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var companies: [String:  String] = ["Apple": "AAPL",
                                                "Microsoft": "MSFT",
                                                "Google": "GOOG",
                                                "Facebook": "FB"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.companyPickerView.dataSource = self
        self.companyPickerView.delegate = self
        self.companyPickerView.reloadAllComponents()
        
        self.activityIndicator.hidesWhenStopped = true

        self.requestCompaniesList()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.companies.keys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(self.companies.keys)[row]
    }
    
    func requestQuoteUpdate() {
        self.activityIndicator.startAnimating()
        self.companyNameLabel.text = "-"
        self.companySymbolLabel.text = "-"
        self.priceLabel.text = "-"
        self.priceChangeLabel.text = "-"
        self.priceChangeLabel.textColor = .black
        self.companyLogo.image = nil
        
        let selectedRow = self.companyPickerView.selectedRow(inComponent: 0)
        let selectedSymbol = Array(self.companies.values)[selectedRow]
        
        self.requestQuote(for: selectedSymbol)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.requestQuoteUpdate()
    }
    
    private func createAlert(withTitle title: String, andMessage message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    private func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    private func downloadImage(from url: URL) {
        self.getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.companyLogo.image = UIImage(data: data)
            }
        }
    }
    
    private func requestCompaniesList() {
        let url = URL(string: "https://cloud.iexapis.com/stable/stock/market/collection/list?collectionName=mostactive&token=pk_4df4c857b5fe48fcb8b8d324d199c4f6")!
        
        let listTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else {
                self.createAlert(withTitle: "Network error", andMessage: "Network error")
                return
            }
            
            self.parseCompaniesList(data: data)
        }
        
        listTask.resume()
    }
    
    private func parseCompaniesList(data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            
            guard
                let json = jsonObject as? [Any]
            else {
                self.createAlert(withTitle: "Invalid JSON format", andMessage: "Invalid JSON format")
                return
            }
            
            var newCompanies = [String: String]()
            for element in json {
                guard
                    let company = element as? [String: Any],
                    let symbol = company["symbol"] as? String,
                    let companyName = company["companyName"] as? String
                else {
                    self.createAlert(withTitle: "Invalid JSON format", andMessage: "Invalid JSON format")
                    return
                }
                newCompanies[companyName] = symbol
            }
            DispatchQueue.main.async {
                self.updateCompaniesList(companies: newCompanies)
            }
        } catch {
            self.createAlert(withTitle: "JSON parsing error", andMessage: "JSON parsing error: " + error.localizedDescription)
        }
    }
    
    private func updateCompaniesList(companies: [String: String]) {
        self.companies = companies
        self.companyPickerView.reloadComponent(0)
        self.requestQuoteUpdate()
    }
    
    private func requestQuote(for symbol: String) {
        let url = URL(string: "https://cloud.iexapis.com/v1/stock/\(symbol)/quote?token=pk_4df4c857b5fe48fcb8b8d324d199c4f6")!
        let logoUrl = URL(string: "https://cloud.iexapis.com/v1/stock/\(symbol)/logo?token=pk_4df4c857b5fe48fcb8b8d324d199c4f6")!
        
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else {
                self.createAlert(withTitle: "Network error", andMessage: "Network error")
                return
            }
            
            self.parseQuote(data: data)
        }
        
        let logoTask = URLSession.shared.dataTask(with: logoUrl) { data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else {
                self.createAlert(withTitle: "Network error", andMessage: "Network error")
                return
            }
            
            self.parseLogoUrl(data: data)
        }
        
        dataTask.resume()
        logoTask.resume()
    }
    
    private func parseLogoUrl(data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            
            guard
                let json = jsonObject as? [String: Any],
                let logo = json["url"] as? String
            else {
                self.createAlert(withTitle: "Invalid JSON format", andMessage: "Invalid JSON format")
                return
            }
            
            let url = URL(string: logo)!
            DispatchQueue.main.async {
                self.downloadImage(from: url)
            }
        } catch {
            self.createAlert(withTitle: "JSON parsing error", andMessage: "JSON parsing error: " + error.localizedDescription)
        }
    }
    
    private func parseQuote(data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            
            guard
                let json = jsonObject as? [String: Any],
                let companyName = json["companyName"] as? String,
                let companySymbol = json["symbol"] as? String,
                let price = json["latestPrice"] as? Double,
                let priceChange = json["change"] as? Double
            else {
                self.createAlert(withTitle: "Invalid JSON format", andMessage: "Invalid JSON format")
                return
            }
            
            DispatchQueue.main.async {
                self.displayStockInfo(companyName: companyName,
                                      symbol: companySymbol,
                                      price: price,
                                      priceChange: priceChange)
            }
        } catch {
            self.createAlert(withTitle: "JSON parsing error", andMessage: "JSON parsing error: " + error.localizedDescription)
        }
    }
    
    private func displayStockInfo(companyName: String, symbol: String, price: Double, priceChange: Double) {
        self.activityIndicator.stopAnimating()
        self.companyNameLabel.text = companyName
        self.companySymbolLabel.text = symbol
        self.priceLabel.text = "\(price)"
        self.priceChangeLabel.text = "\(priceChange)"
        
        if priceChange > 0 {
            self.priceChangeLabel.textColor = .green
        } else if priceChange < 0 {
            self.priceChangeLabel.textColor = .red
        } else {
            self.priceChangeLabel.textColor = .black
        }
    }
}

