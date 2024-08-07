//
//  CoreDataManager.swift
//  Assignment
//
//  Created by Sam.Lee on 8/7/24.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LoginCoreData")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func isIdExists(_ id: String) -> Bool {
        let fetchRequest: NSFetchRequest<UserModel> = UserModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            return false
        }
    }
    
    func isPasswordCorrect(for id: String, password: String) -> Bool {
        let fetchRequest: NSFetchRequest<UserModel> = UserModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND password == %@", id, password)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            return false
        }
    }
    
    // ID에 따라 닉네임을 반환하는 함수
    func getNickname(for id: String) -> String? {
        let fetchRequest: NSFetchRequest<UserModel> = UserModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let users = try context.fetch(fetchRequest)
            return users.first?.nickName
        } catch {
            return nil
        }
    }
    
    func deleteUser(for id: String) -> Bool {
        let fetchRequest: NSFetchRequest<UserModel> = UserModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let users = try context.fetch(fetchRequest)
            if let user = users.first {
                context.delete(user)
                try context.save()
                return true
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    func addUser(user : User) -> Bool {
        let userModel = UserModel(context: context)
        userModel.id = user.id
        userModel.password = user.password
        userModel.nickName = user.nickName
        
        do {
            try context.save()
            return true
        } catch {
            print("Failed to save UserModel: \(error)")
            return false
        }
    }
    
    func fetchAllUsers() {
        let fetchRequest: NSFetchRequest<UserModel> = UserModel.fetchRequest()
        
        do {
            let users = try context.fetch(fetchRequest)
            for user in users {
                print("ID: \(user.id ?? "Unknown"), Password: \(user.password ?? "Unknown"), Nickname: \(user.nickName ?? "Unknown")")
            }
        } catch {
            print("Failed to fetch UserModels: \(error)")
        }
    }
    
    func deleteAllUsers() -> Bool {
        let fetchRequest: NSFetchRequest<UserModel> = UserModel.fetchRequest()
        
        do {
            let users = try context.fetch(fetchRequest)
            for user in users {
                context.delete(user)
            }
            try context.save()
            return true
        } catch {
            print("Failed to delete all UserModels: \(error)")
            return false
        }
    }
}
