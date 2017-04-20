//
//  ViewController.swift
//  PUAUTOLOGIN
//
//  Created by Saini  on 8/21/16.
//  Copyright © 2016 Saini . All rights reserved.
//

import UIKit
import CoreData
import SystemConfiguration
import Alamofire

class ViewController: BaseViewController,UITableViewDelegate, UITableViewDataSource
{
    var name = String()
    var pass = String()
    var webuser = String()
    var webpass = String()
    var loginresponse = 1
    var nameArray = [NSManagedObject]()
    var lastSelection: IndexPath!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addSlideMenuButton()
        self.retrieve()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
//MARK:Outlets //Where are the funcitons that you showed me?
    @IBOutlet weak var tableView: UITableView!

    @IBAction func loginbtn(_ sender: AnyObject) {
     //   self.validationempty()
        self.web1()
      //  self.validationsuccess()
    }
    @IBAction func add(_ sender: AnyObject)
    {
        self.fetch()
    }
//MARK:Tableview functions
    func tableView(_ tableView: UITableView, canEditRowAt indexPath:IndexPath) -> Bool
    {
        return true;
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == UITableViewCellEditingStyle.delete
        {
            let appdel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appdel.managedObjectContext
            
            context.delete(self.nameArray[indexPath.row])
            
            do {
                try context.save()
                self.nameArray.removeAll()
                retrieve()
                self.tableView.reloadData()
            } catch  {
                
            }
            }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        name = nameArray[(indexPath as NSIndexPath).row] .value(forKey: "usernamedb") as! String
        pass = nameArray[(indexPath as NSIndexPath).row] .value(forKey: "passworddb") as! String
        //cell.textLabel?.text = nameArray[(indexPath as NSIndexPath).row] //
        cell.textLabel?.text = ""+name
        cell.detailTextLabel?.text = ""+pass
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.lastSelection != nil {
            self.tableView.cellForRow(at: self.lastSelection)?.accessoryType = .none
        }
        
        self.tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
        
        self.lastSelection = indexPath as IndexPath!
        
        self.tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        let currentCell = tableView.cellForRow(at: lastSelection)! as UITableViewCell
        
        print(currentCell.textLabel!.text)
        print(currentCell.detailTextLabel!.text)
        
        webuser = currentCell.textLabel!.text!
        webpass = currentCell.detailTextLabel!.text!
        print(webuser)
        print(webpass)
        
    }
    
//MARK:Coredeata
    func retrieve()
    {
        let appdel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appdel.managedObjectContext
        
        do{ //let request = NSFetchRequest(entityName: "Users")
            let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Users")
            
            let results = try? context.fetch(request) as? [NSManagedObject]
            
            if results!!.count > 0
            {
                for item in results!! {
                    //   self.name = item.value(forKey: "usernamedb") as! String
                    // self.pass = item.value(forKey: "passworddb") as! String
                    // self.nameArray.append(self.name)
                    self.nameArray.append(item)
                    
                    // print(self.name,self.pass)
                    self.tableView.reloadData()
                }
                self.tableView.reloadData()
            }
        }catch{
            print("Error Saving data")
        }
    }

    func fetch()
    {
        var usernameTextField: UITextField?
        var passwordTextField: UITextField?
        
        //Alertview
        let alertController = UIAlertController(
            title: "ADD Credentials",
            message: "Please enter your credentials",
            preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelaction = UIAlertAction(title: "Cancel", style:UIAlertActionStyle.default){
            (action) -> Void in
            
            alertController.dismiss(animated: true, completion: nil)
        }
        let loginAction = UIAlertAction(
        title: "Save", style: UIAlertActionStyle.default) {
            (action) -> Void in
            
            let user = alertController.textFields![0]
            let pass = alertController.textFields![1]
            print(user.text)
            print(pass.text)
            
            
            let appdel: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appdel.managedObjectContext
            
            //Add new user
            
            let newuser = NSEntityDescription.insertNewObject(forEntityName: "Users", into: context)
            newuser.setValue(user.text, forKey: "usernamedb")
            newuser.setValue(pass.text, forKey: "passworddb")
            
            //Add Info to entity
            
            do{
                try context.save()
            }catch{
                print("Error Saving data")
            }
            self.nameArray.removeAll()
            
            //Retrieve the data
            
            self.retrieve()
            
            if let username = usernameTextField?.text {
                print(" Username = \(username)")
            } else {
                print("No Username entered")
            }
            
            if let password = passwordTextField?.text {
                print("Password = \(password)")
            } else {
                print("No password entered")
            }
            
            
        }
        
        //Textfields
        
        alertController.addTextField {
            (txtUsername) -> Void in
            usernameTextField = txtUsername
            usernameTextField!.placeholder = "Username"
        }
        
        alertController.addTextField {
            (txtPassword) -> Void in
            passwordTextField = txtPassword
            passwordTextField!.isSecureTextEntry = true
            passwordTextField!.placeholder = "Password"
        }
        
        // 5.
        alertController.addAction(loginAction)
        alertController.addAction(cancelaction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
//MARK:Authentication
    
    func web1(){
        
        let parameters: Parameters = [
            "user": ""+webuser,
            "password": ""+webpass,
           // "foo": "bar",
          //  "baz": ["a", 1],
            //"qux": [
              //  "x": 1,
                //"y": 2,
                //"z": 3
                //]
        ]
        
        Alamofire.request("https://securelogin.pu.ac.in/cgi-bin/login?cmd=login", parameters: parameters, encoding: URLEncoding.default).response{ response in
            print(response.error)

            if response.error == nil{
            print(response.response)
            print(response.response?.statusCode)//like here it works 
                
                if let statusCode = response.response?.statusCode{
                    print(statusCode)
             self.loginresponse = statusCode
                    
                    if statusCode == 200{
                    
                    
                    self.presentAlert(title: "Login Successfull", message: "")
                    
                    }
                    else{
                    self.presentAlert(title: "Login Unsuccessfull", message: "")
                    
                    
                    }
                   // if statusCode==200{
                     //   a=200;
                    //}
          //    self.validationsuccess()
                }
            
            }
            else{
            self.presentAlert(title: "Sorry", message: "Try again in some time")
            
            }
            
            
            // its called if let handling for optionals when you try to unwrap an optional and if that optional is by chance nil your application crashes because a non optional cannot have a nil value.
                   }
        //https://httpbin.org/post
        //https://securelogin.pu.ac.in/cgi-bin/login?cmd=login
    }
    
    func validationempty(){
        if webuser.isEmpty {
            print("Nothing to see here")
            let alertController1 = UIAlertController(title: "Hey There", message: "Please select one user ID from the list of saved credentials and try again", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Close", style: .default, handler: nil)
            alertController1.addAction(defaultAction)
            
            present(alertController1, animated: true, completion: nil)
            
        }
            
        }
   
    
    func presentAlert(title:String, message: String){
        let alertController2 = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController2.addAction(defaultAction)
        
        present(alertController2, animated: true, completion: nil)
    
    }
    
    }

