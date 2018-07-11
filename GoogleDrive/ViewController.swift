//
//  ViewController.swift
//  GoogleDrive
//
//  Created by Aryeh Greenberg on 7/9/18.
//  Copyright © 2018 AGApps. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/drive"]
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signInSilently()
        
        
        
        /*
        let myFile = Bundle.main.url(forResource: "test", withExtension: "txt")
        // user.authentication.
        
        //GTLRDriveService.autho
        let data = try? Data(contentsOf: myFile!)
        let file = GTLRDrive_File()
        file.name = "Test Upload from API"
        //to place in folder
        //file.parents = "</ID HERE>"
        
        let uploadParams = GTLRUploadParameters(data: data!, mimeType: "text/plain")
        uploadParams.shouldUploadWithSingleRequest = true
        
        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: uploadParams)
        query.fields = "id"
        
        //GTLRDriveService().ex
        
        driveService!.executeQuery(query) { (ticket, file, error) in
            if error == nil {
                print("File is \(ticket)")
            }
            else {
                print(error?.localizedDescription)
            }
        }*/
        print("View did load")
        
        let name = NSNotification.Name("signedInG")
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.signedIn), name: name, object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func signedIn() {
        getFolderId { (id) in
            print("Folder id is \(id)")
            self.currentBackupId(folderId: id, completion: { (fileId) in
                if fileId == nil {
                    self.uploadFileWithParentId(parent: id)
                }
                else {
                    print("Existing already")
                    self.updateFileWithId(fileId: fileId!)
                }
            })
            
        }
    }
    
    func updateFileWithId(fileId:String) {
        let file = GTLRDrive_File()
        file.originalFilename = "Test Upload from API"
        file.name = "Test Upload from API"
        //to place in folder
        //file.parents = [parent]
        
        let myFile = Bundle.main.url(forResource: "test2", withExtension: "txt")
        let data = try? Data(contentsOf: myFile!)

        
        
        let uploadParams = GTLRUploadParameters(data: data!, mimeType: "text/plain")
        uploadParams.shouldUploadWithSingleRequest = true
        
        
        
        let query = GTLRDriveQuery_FilesUpdate.query(withObject: file, fileId: fileId, uploadParameters: uploadParams)
        
        //GTLRDriveService().ex
        
        driveService!.executeQuery(query) { (ticket, file, error) in
            if error == nil {
                print("File is \(ticket)")
            }
            else {
                print(error?.localizedDescription)
            }
        }
    }
    
    func uploadFileWithParentId(parent:String) {
        let myFile = Bundle.main.url(forResource: "test", withExtension: "txt")
        // user.authentication.
        
        //GTLRDriveService.autho
        let data = try? Data(contentsOf: myFile!)
        let file = GTLRDrive_File()
        file.name = "Test Upload from API"
        //to place in folder
        file.parents = [parent]
        
        
        let uploadParams = GTLRUploadParameters(data: data!, mimeType: "text/plain")
        uploadParams.shouldUploadWithSingleRequest = true
        
        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: uploadParams)
        query.fields = "id"
        
        //GTLRDriveService().ex
        
        driveService!.executeQuery(query) { (ticket, file, error) in
            if error == nil {
                print("File is \(ticket)")
            }
            else {
                print(error?.localizedDescription)
            }
        }
    }
    
    func currentBackupId(folderId:String,completion: @escaping (_ id:String?) -> Void) {
        let query = GTLRDriveQuery_FilesList.query()
        query.q = "mimeType='text/plain' and name = 'Test Upload from API' and '\(folderId)' in parents and trashed = false"
        query.spaces = "drive"
        print("Excecuting query")
        
        driveService?.executeQuery(query, completionHandler: { (ticket, files, error) in
            if error == nil {
                
                guard let myFiles = files as? GTLRDrive_FileList
                    else {
                        print("Couldnt parse, returning")
                        return
                }
                if myFiles.files?.count ?? 0 == 0 {
                    //need to add folder
                    completion(nil)
                }
                else {
                    print("Folder already exists, returning current one")
                    completion(myFiles.files![0].identifier!)
                }
                
            }
                
            else {
                print("Error querying with \(error?.localizedDescription)")
            }
        })
    }
    
    func getFolderId(completion: @escaping (_ fileId:String) -> Void) {
        
        let query = GTLRDriveQuery_FilesList.query()
        query.q = "mimeType='application/vnd.google-apps.folder' and name = 'Book-List_Backup'"
        query.spaces = "drive"
        print("Excecuting query")
        
        driveService?.executeQuery(query, completionHandler: { (ticket, files, error) in
            if error == nil {
                
                guard let myFiles = files as? GTLRDrive_FileList
                    else {
                        print("Couldnt parse, returning")
                        return
                    }
                if myFiles.files?.count ?? 0 == 0 {
                    //need to add folder
                    print("No folder yet, adding one")
                    self.addFolder(completion: completion)
                }
                else {
                    print("Folder already exists, returning current one")
                    completion(myFiles.files![0].identifier!)
                }
                
            }
        
            else {
                print("Error querying with \(error?.localizedDescription)")
            }
        })
        
        
        
        
        

    }
    
    func addFolder(completion: @escaping (_ fileId:String) -> Void) {
        let folder = GTLRDrive_File()
        folder.name = "Book-List_Backup"
        folder.mimeType = "application/vnd.google-apps.folder"
        
        let createQuery = GTLRDriveQuery_FilesCreate.query(withObject: folder, uploadParameters: nil)
        createQuery.fields = "id"
        
        if driveService != nil {
            driveService?.executeQuery(createQuery, completionHandler: { (ticket, file, error) in
                if error == nil {
                    if let myFile = file as? GTLRDrive_File {
                        completion(myFile.identifier!)
                    }
                    else {
                        print("Couldnt parse")
                    }
                }
                else {
                    print("Error")
                }
            })
        }
        else {
            print("Drive services is nil")
        }
    }


}

extension ViewController:GIDSignInUIDelegate {
    
}




