//
//  ViewController.swift
//  TestingInAppPurchases
//
//  Created by Tashreque Mohammed Haq on 26/9/21.
//

import UIKit
import StoreKit

class ProductsViewController: UIViewController {
    
    // The product model list.
    var models = [SKProduct]()
    
    // Table view to display products.
    let productTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupUI()
        
        // Add payment observer.
        SKPaymentQueue.default().add(self)
        
        fetchProducts()
    }
    
    private func setupUI() {
        productTableView.dataSource = self
        productTableView.delegate = self
        
        self.view.addSubview(productTableView)
        productTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([productTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor), productTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor), productTableView.topAnchor.constraint(equalTo: self.view.topAnchor), productTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)])
    }

}

extension ProductsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let product = models[indexPath.row]
        cell.textLabel?.text = "\(product.localizedTitle), \(product.localizedDescription)"
        cell.detailTextLabel?.text = "\(product.price)"
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("Selected product at index \(indexPath.row)")
        
        // Add payment to the transaction queue.
        let payment = SKPayment(product: models[indexPath.row])
        SKPaymentQueue.default().add(payment)
    }
}

extension ProductsViewController: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        // Populate the model array using the products obtained as a resulf of the product request.
        self.models = response.products
        
        // Populate table view.
        DispatchQueue.main.async { [weak self] in
            self?.productTableView.reloadData()
        }
    }
    
    func fetchProducts() {
        // Send a product fetch request, set relevant delegate to receive updates.
        let request = SKProductsRequest(productIdentifiers: Set(Product.allCases.compactMap({ $0.rawValue })))
        request.delegate = self
        request.start()
    }
}

extension ProductsViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        // Check the current purchase status and perform any activity if required.
        transactions.forEach { transaction in
            let state = transaction.transactionState
            
            switch state {
            case .purchasing:
                print("purchasing")
            case .purchased:
                print("purchased")
            case .failed:
                print("failed")
            case .restored:
                print("restored")
            case .deferred:
                print("deferred")
            @unknown default:
                print("unknown")
            }
        }
    }
}

