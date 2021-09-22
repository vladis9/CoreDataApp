//
//  ViewController.swift
//  CoreDataApp
//
//  Created by Vlad Zinevich on 13.09.2021.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    
    private let cellID = "cell"
    private var tasks: [Task] = []
    private let manageContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        // Cell register
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }

    /// Setup view
    private func setupView() {
        view.backgroundColor = .white
        setupNavigationBar()
    }
    
    /// Setup navigation bar
    private func setupNavigationBar() {
        title = "Tasks list"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 191/255,
            alpha: 194/255
        )
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        // Add button to nav bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add",
            style: .plain,
            target: self,
            action: #selector(addNewTask)
        )
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlert(title: "New Task", message: "What do you want to do")
    }
    
    // Create alert for a new task
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else {
                print("TextField is empty")
                return
            }
            
            // Add new task to array
            self.save(task)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
        
        // Entity name
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: manageContext) else { return }
        
        // Model instance
        let task = NSManagedObject(entity: entityDescription, insertInto: manageContext) as! Task
        
        task.name = taskName
        
        do {
            try manageContext.save()
            tasks.append(task)
            self.tableView.insertRows(
                at: [IndexPath(row: self.tasks.count - 1, section: 0)],
                with: .automatic
            )
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func fetchData() {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            tasks = try manageContext.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name
        
        return cell
    }
}
