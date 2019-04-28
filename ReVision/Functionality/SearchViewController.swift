//
//  SearchViewController.swift
//  ReVision
//
//  Created by Jacob Marsh (student LM) on 2/26/19.
//  Copyright © 2019 Eugenia Feng (student LM). All rights reserved.
//

import UIKit
import FirebaseDatabase

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var ref : DatabaseReference?
    var handle : DatabaseHandle?
    var activePetitions = [Petition]()
    var completedPetitoins = [Petition]()
    var filteredPetitions = [Petition]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        searchBar.returnKeyType = UIReturnKeyType.done
        ref = Database.database().reference().child("Active Petitions")
        
        
        ref?.observeSingleEvent(of: .value, with: { (snapshot) in
            //Creating a dictionary of the Petitions
            let dicts = snapshot.value as? [String : AnyObject] ?? [:]
            for i in dicts.keys{
                let petit = dicts[i] as? [String : AnyObject] ?? [:]
                //Getting the data
                let petition = Petition()
                
                petition.title = petit["Title"] as? String
                petition.subtitle = petit["Subtitle"] as? String
                petition.author = petit["Author"] as? String
                petition.description = petit["Description"] as? String
                petition.creator = i
                petition.ID = i
                petition.active = true
                self.activePetitions.append(petition)
                
                }
            self.tableView.reloadData()
        })
        
        ref = Database.database().reference().child("Completed Petitions")

        ref?.observeSingleEvent(of: .value, with: { (snapshot) in
            //Creating a dictionary of the Petitions
            let dict = snapshot.value as? [String : AnyObject] ?? [:]
            for i in dict.keys{
                let petit = dict[i] as? [String : AnyObject] ?? [:]
                //Getting the data
                let petition = Petition()
                
                petition.title = petit["Title"] as? String
                petition.subtitle = petit["Subtitle"] as? String
                petition.author = petit["Author"] as? String
                petition.description = petit["Description"] as? String
                petition.creator = petit["Creator"] as? String
                petition.ID = i
                self.completedPetitoins.append(petition)
                
            }
            self.tableView.reloadData()
        })
        
        self.navigationItem.title = "Search"

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredPetitions.count > 0{
            return filteredPetitions.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchedPetition", for: indexPath) as! SearchTableViewCell
        let row = indexPath.row
        if filteredPetitions.count > 0{
            //cell.textLabel?.text = filteredPetitions[row].title
            cell.title.text = filteredPetitions[row].title
            cell.subtitle.text = filteredPetitions[row].subtitle
            cell.author.text = "By: \(filteredPetitions[row].author ?? "ERROR")"
            cell.creator = filteredPetitions[row].creator
            cell.active = filteredPetitions[row].active
            cell.id = filteredPetitions[row].ID
    
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? SearchTableViewCell {
            if let vc = segue.destination as? PetitionViewController {
                vc.userId = cell.creator
                vc.active = cell.active
                vc.petitionID = cell.id
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.selectedScopeButtonIndex == 0 {
            filteredPetitions = activePetitions.filter({ (petition) -> Bool in
                guard let text = searchBar.text else {return false}
    //            return petition.title?.contains(text) ?? false
                if petition.title?.lowercased().contains(text.lowercased()) ?? false || petition.creator?.lowercased().contains(text.lowercased()) ?? false || petition.subtitle?.lowercased().contains(text.lowercased()) ?? false || petition.description?.lowercased().contains(text.lowercased()) ?? false {
                    return true
                }
                return false
            })
        }else{
            filteredPetitions = completedPetitoins.filter({ (petition) -> Bool in
                guard let text = searchBar.text else {return false}
                //            return petition.title?.contains(text) ?? false
                if petition.title?.lowercased().contains(text.lowercased()) ?? false || petition.creator?.lowercased().contains(text.lowercased()) ?? false || petition.subtitle?.lowercased().contains(text.lowercased()) ?? false || petition.description?.lowercased().contains(text.lowercased()) ?? false {
                    return true
                }
                return false
            })
        }
        tableView.reloadData()
        //searchBar.text
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchBar.text = ""
        filteredPetitions.removeAll()
        tableView.reloadData()
    }
}
