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
    
    var useCamera : Bool = false
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
        saveComputers()
        
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
        saveComputers()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is PairComputerViewController
        {
            let vc = segue.destination as? PairComputerViewController
            vc?.useCamera = self.useCamera
            if (self.useCamera) {
                vc?.imagePicker.sourceType = .camera
            } else {
                vc?.imagePicker.sourceType = .photoLibrary
            }
            vc?.navigationItem.title = String.TAKE_A_PICTURE
        }
    }

    
    @IBAction func pairButtonClicked(_ sender: UIButton) {
//        performSegue(withIdentifier: "showAddImageView", sender: self)
        pickImageSourceAlert()
    }
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {
        if let currentCurrentComputer = currentComputer {
            addComputerToList(computer: currentCurrentComputer)
        }
    }
    
    /**
     Displays an alert to choose either the camera or the photo library as the image source
     
     - Parameter none:
     
     - Throws:
     
     - Returns:
     */
    func pickImageSourceAlert() {
        let alert = UIAlertController(title: String.EMPTY, message: String.CAMERA_OR_PHOTO, preferredStyle: .alert)
        alert.isModalInPopover = true
        
        alert.addAction(UIAlertAction(title: String.CAMERA, style: .default, handler: { (UIAlertAction) in
            self.navigationItem.title = String.TAKE_A_PICTURE
            self.useCamera = true
            self.performSegue(withIdentifier: "showPairComputerView", sender: self)
        }))
        
        alert.addAction(UIAlertAction(title: String.PHOTO_LIBRARY, style: .default, handler: { (UIAlertAction) in
            self.navigationItem.title = String.SELECT_A_PICTURE
            self.useCamera = false
            self.performSegue(withIdentifier: "showPairComputerView", sender: self)
        }))
        self.present(alert,animated: true, completion: nil )
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
        SVProgressHUD.show()
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(computers, toFile: Computer.ArchiveURL.path)
        if isSuccessfulSave {
            print("Computers successfully saved.")
        } else {
            print("Failed to save computers...")
        }
        SVProgressHUD.dismiss()
    }
    
    private func loadComputers() -> [Computer]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Computer.ArchiveURL.path) as? [Computer]
    }
}


