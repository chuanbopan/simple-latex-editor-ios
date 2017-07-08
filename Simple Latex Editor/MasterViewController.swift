//
//  MasterViewController.swift
//  Simple Latex Editor
//
//  Created by Chuanbo Pan on 7/8/17.
//  Copyright © 2017 Chuanbo Pan. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {
    // views
    var detailViewController: DetailViewController? = nil
    var objects = [Any]()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! NSDate
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let object = objects[indexPath.row] as! NSDate
        cell.textLabel!.text = object.description
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    
    // MARK: - file management
    
    @IBAction func createNewProject(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Create New Project", message: "Please enter a project name", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Project name"
        }
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if let textFields = alertController.textFields {
                if let projectName = textFields[0].text {
                    self.createProjectWithName(projectName)
                    alertController.dismiss(animated: true, completion: nil)
                }
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func createProjectWithName(_ name: String) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let folderDirectory = (documentsPath as NSString).appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: folderDirectory) {
            projectExists()
        } else {
            do {
                let mainFile = (folderDirectory as NSString).appendingPathComponent("main.tex")
                let data = try Data(contentsOf: Bundle.main.url(forResource: "Default", withExtension: "tex")!)
                
                try FileManager.default.createDirectory(atPath: folderDirectory, withIntermediateDirectories: true, attributes: nil)
                
                FileManager.default.createFile(atPath: mainFile, contents: data, attributes: nil)
            } catch let error {
                self.failedToCreateProject(error)
            }
        }
    }
    
    // MARK: - Error Popups
    
    func projectExists() {
        let alertController = UIAlertController(title: "Project Exists", message: "A project with the same name already exists. Please choose a different project name.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    func failedToCreateProject(_ error: Error) {
        let alertController = UIAlertController(title: "Failed to Create Project", message: "Error: \(error.localizedDescription)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

