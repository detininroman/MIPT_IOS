//
//  ViewController.swift
//  Converter
//
//  Created by Roman on 12/05/2019.
//  Copyright © 2019 Roman. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var pickerFrom: UIPickerView!
    @IBOutlet weak var pickerTo: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let currencies = ["RUB", "USD", "EUR"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.label.text = "test"
        
        self.pickerTo.dataSource = self
        self.pickerFrom.dataSource = self
        
        self.pickerTo.delegate = self
        self.pickerFrom.delegate = self
        
        self.requestCurrencyRates(baseCurrency: "RUB") { (data, error) in }
        
        self.retrieveCurrencyRate(baseCurrency: "USD", toCurrency: "RUB") { [weak self] (value) in DispatchQueue.main.async(execute: {
            if let strongSelf = self {
                strongSelf.label.text = value
            }
        })}
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencies.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencies[row]
    }
    
    func requestCurrencyRates(baseCurrency: String, parseHandler: @escaping (Data?, Error?) -> Void) {
        let url = URL(string: "http://data.fixer.io/api/latest?access_key=1d03581943cbf9c16822d4cf42ac821a&format=1")!
        
        let dataTask = URLSession.shared.dataTask(with: url) {
            (dataRecieved, response, error) in parseHandler(dataRecieved, error)
        }
        
        dataTask.resume()
    }
    
    func parseCurrencyRatesResponce(data: Data?, toCurrency: String) -> String {
        var value: String = ""
        
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, Any>
            
            if let parsedJSON = json {
                print("\(parsedJSON)")
                if let rates = parsedJSON["rates"] as? Dictionary<String, Double> {
                    if let rate = rates[toCurrency] {
                        value = "\(rate)"
                        } else {
                        value = "No rate for currency \"\(toCurrency)\" found"
                        }
                } else {
                    value = "No \"rates\" field found"
                }
            } else {
                value = "No JSON value parsed"
            }
        } catch {
            value = error.localizedDescription
        }
        return value
    }
    
    func retrieveCurrencyRate(baseCurrency: String, toCurrency: String, completion: @escaping (String) -> Void) {
        self.requestCurrencyRates(baseCurrency: baseCurrency) { [weak self] (data, error) in
            var string = "No currency retrieved!"
            
            if let currentError = error {
                string = currentError.localizedDescription
            } else {
                if let strongSelf = self {
                    string = strongSelf.parseCurrencyRatesResponce(data: data, toCurrency: toCurrency)
                }
            }
            
            completion(string)
            }
    }
    
    
}

