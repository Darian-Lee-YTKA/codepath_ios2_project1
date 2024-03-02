//
//  ViewController.swift
//  scavangerhunt
//
//  Created by Darian Lee on 2/29/24.
//

import UIKit
import PhotosUI
class TaskCell: UITableViewCell {
    
    @IBOutlet weak var task_label: UILabel!
    
    @IBOutlet weak var pink_butterfly: UIImageView!
    

    @IBOutlet weak var initial_butterfly: UIImageView!
    @IBOutlet weak var blue_butterfly: UIImageView!
    @IBOutlet weak var green_butterfly: UIImageView!
    var choosenButterfly: UIImageView?
    var task: Task?

    
    override func awakeFromNib() {
            super.awakeFromNib()
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 1.0
        guard let task = task else{
            print("no task!")
            return
        }
            if task.done == true{
            self.initial_butterfly.isHidden = true
                print("done! we done!")
            let others = [self.blue_butterfly,
                          self.pink_butterfly,
                          self.green_butterfly]
            if let chosenButterfly = others.randomElement() {
                self.choosenButterfly = chosenButterfly
                self.choosenButterfly?.isHidden = false
            }
            self.choosenButterfly?.isHidden = false
            
            
            
        }
        else{
            self.initial_butterfly.isHidden = false
                self.blue_butterfly.isHidden = true
                self.pink_butterfly.isHidden = true
                self.green_butterfly.isHidden = true
        }
        
        }
    
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks!.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: "goToPic", sender: indexPath)
            print("segued")
        tableView.deselectRow(at: indexPath, animated: true)
            if let cell = tableView.cellForRow(at: indexPath) {
                let colors = [
                    UIColor(red: 153/255, green: (216+20)/255, blue: 230/255, alpha: 0.25), // Light Blue
                    UIColor(red: 255/255, green: 105/255, blue: 180/255, alpha: 0.25),     // Pink
                    UIColor(red: 150/255, green: 200/255, blue: 100/255, alpha: 0.25),     // Light Green
                    UIColor(red: 128/255, green: 0/255, blue: 128/255, alpha: 0.25),       // Purple
                    UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 0.25),        // Yellow
                    UIColor(red: 255/255, green: 165/255, blue: 0/255, alpha: 0.25),
                    UIColor(red: 200/255, green: 0/255, blue: 255/255, alpha: 0.25)// purple
                ]

                    cell.contentView.backgroundColor = colors.randomElement()!
                }
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        
        // Get the post associated with this row
        let task = tasks![indexPath.row]
        
        // Set the text for titleText and descriptionText
        
        cell.task_label.text = task.title
        cell.task = task
        print("we gave it a task!")
        if task.done == true {
                // Hide the initial butterfly
                cell.initial_butterfly.isHidden = true
            print("done! we done!")

                // Create an array of butterfly image views that can be shown
                let butterflies = [cell.blue_butterfly, cell.pink_butterfly, cell.green_butterfly]

                // Choose a random butterfly image view
                if let chosenButterfly = butterflies.randomElement() {
                    // Hide all butterfly image views
                    for butterfly in butterflies {
                        butterfly?.isHidden = true
                    }
                    // Show the chosen butterfly image view
                    chosenButterfly?.isHidden = false
                }
            } else {
                // If task is not done, ensure all butterflies are hidden
                cell.initial_butterfly.isHidden = false
                cell.blue_butterfly.isHidden = true
                cell.pink_butterfly.isHidden = true
                cell.green_butterfly.isHidden = true
            }

            return cell
        }
   
    
    
    // hard coding in posts for simplicity
    
    
    @IBOutlet weak var taskTable: UITableView!
    var tasks: [Task]?
    override func viewDidLoad() {
        super.viewDidLoad()
        if tasks == nil{
            tasks = [Task(title: "Consume oilfish", done: false, description: "Arf Arf I'm a seal"), Task(title: "Bask on ice", done: false, description: "Arf Arf I'm a seal"), Task(title: "Remove parasites from pelt", done: false, description: "Arf Arf I'm a seal"), Task(title: "Find mate (not Sergei again. You can do better)", done: false, description: "Arf Arf I'm a seal"), Task(title: "Swim", done: false, description: "Arf Arf I'm a seal"), Task(title: "Play with little rock", done: false, description: "Arf Arf I'm a seal"), Task(title: "Sit on big rock and make loud noises", done: false, description: "Arf Arf I'm a seal")]}
        
        // Set the data source of the table view
        taskTable.dataSource = self
        taskTable.delegate = self
        taskTable.layer.cornerRadius = 8
        taskTable.layer.borderColor = UIColor.gray.cgColor
        taskTable.layer.borderWidth = 1.5
        taskTable.reloadData()
        
        // Do any additional setup after loading the view.
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? SetPictureVC {
            // Here, you can configure properties of the destinationViewController
            // For example, you can pass data to it
            if let indexPath = taskTable.indexPathForSelectedRow {
                // Retrieve the task corresponding to the selected row
                let selectedTask = tasks![indexPath.row]
                // Pass the selected task to the destinationViewController
                destinationViewController.task = selectedTask
                destinationViewController.tasks = tasks
                destinationViewController.taskIndex = indexPath.row
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            // Reload the table view to update the cells
            taskTable.reloadData()
        }
    
    
    
}
