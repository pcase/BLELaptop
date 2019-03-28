//
//  ComputerListViewController.swift
//  BluetoothLaptop
//
//  Created by Patty Case on 3/26/19.
//  Copyright © 2019 Azure Horse Creations. All rights reserved.
//

import UIKit
import SVProgressHUD

class ComputerListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var pairButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var computers = [Computer]()
    var currentComputer: Computer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.show()
        if let savedComputers = loadComputers() {
            computers.removeAll()
            computers.append(contentsOf: savedComputers)
        }
        SVProgressHUD.dismiss()
        
        if let currentCurrentComputer = currentComputer {
            addComputerToList(computer: currentCurrentComputer)
        }
        SVProgressHUD.show()
        saveComputers()
        SVProgressHUD.dismiss()
        
        tableView?.dataSource = self
        tableView?.delegate = self
        
        tableView.estimatedRowHeight = 120.0
        tableView.rowHeight = UITableView.automaticDimension
        
//        tableView?.rowHeight = UITableView.automaticDimension
//        tableView?.estimatedRowHeight = 44
//
//        tableView.sectionHeaderHeight = UITableView.automaticDimension;
//        tableView.estimatedSectionHeaderHeight = 30;
//
//        tableView.sectionFooterHeight = UITableView.automaticDimension;
//        tableView.estimatedSectionFooterHeight = 30;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let savedComputers = loadComputers() {
            computers.removeAll()
            computers.append(contentsOf: savedComputers)
        }
        
        if let currentCurrentComputer = currentComputer {
            addComputerToList(computer: currentCurrentComputer)
        }
        SVProgressHUD.show()
        saveComputers()
        SVProgressHUD.dismiss()
    }
    
    @IBAction func pairButtonClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "showAddImageView", sender: self)
    }
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {
        if let currentCurrentComputer = currentComputer {
            addComputerToList(computer: currentCurrentComputer)
        }
    }
    
    /**
     Returns number of components in vie
     
     - Parameter pickerview:
     
     - Throws:
     
     - Returns: int value of 1
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return computers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier", for: indexPath) as! TableViewCell
        
        let computer = computers[indexPath.row]
        cell.MACAddress.text = computer.MACAddress
        cell.dateAdded.text = String.DATE_ADDED + computer.dateAdded
        cell.imageView?.image = computer.image
        
        return cell
    }
    
    func addComputerToList(computer: Computer) {
        var found: Bool = false
        for comp in computers {
            if comp.MACAddress == computer.MACAddress {
                found = true;
            }
        }
        if !found {
            computers.append(computer)
        } else {
            //            showDuplicateDeviceError()
        }
        SVProgressHUD.show()
        saveComputers()
        SVProgressHUD.dismiss()
        currentComputer = nil;
        self.tableView.reloadData()
    }
    
    /**
     Displays an alert for duplicate computer
     
     - Parameter none:
     
     - Throws:
     
     - Returns:
     */
    func showDuplicateDeviceError() {
        let alert = UIAlertController(title: String.EMPTY, message: String.DUPLICATE_DEVICE, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.dismiss(animated: false, completion: nil)
        }))
        
        self.present(alert, animated: false, completion: nil)
    }
    
    //MARK: Private Methods
    
    private func saveComputers() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(computers, toFile: Computer.ArchiveURL.path)
        if isSuccessfulSave {
            print("Computers successfully saved.")
        } else {
            print("Failed to save computers...")
        }
    }
    
    private func loadComputers() -> [Computer]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Computer.ArchiveURL.path) as? [Computer]
    }
}


