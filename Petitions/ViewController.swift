//
//  ViewController.swift
//  Petitions
//
//  Created by Mihai Leonte on 9/11/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showCredits))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterResults))
        
        var urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            //urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
            urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        } else {
            //urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
            urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
        }
        
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    self?.parse(data: data)
                    return
                }
            }
            
            self?.showError()
        }
        
        
        
    }
    
    @objc func filterResults() {
        let ac = UIAlertController(title: "Search", message: "Enter a search string", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Filter", style: .default, handler: { [unowned ac, weak self] _ in
            guard let searchTerm = ac.textFields?[0].text else { return }
            self?.title = "\"\(searchTerm)\""
            self?.filteredPetitions = self?.petitions.filter { $0.title.uppercased().contains(searchTerm.uppercased()) || $0.body.uppercased().contains(searchTerm.uppercased())
                } ?? []
            
            self?.tableView.reloadData()
        }))
                     
        present(ac, animated: true)
    }
    
    @objc func showCredits() {
        let ac = UIAlertController(title: "Credits", message: "The data comes from We The People API of the Whitehouse", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true)
    }
    
    func parse(data: Data) {
        let decoder = JSONDecoder()
        
        if let petitions = try? decoder.decode(Petitions.self, from: data) {
            self.petitions = petitions.results
            self.filteredPetitions = petitions.results
            
            // UI should be done back on the on the Main Thread
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    func showError() {
        DispatchQueue.main.async { [weak self] in
            let ac = UIAlertController(title: "Error", message: "There was a problem loading the page. Try again later", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self?.present(ac, animated: true )
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPetitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = filteredPetitions[indexPath.row].title
        cell.detailTextLabel?.text = filteredPetitions[indexPath.row].body
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = filteredPetitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

}

