//
//  UserModel+CoreDataProperties.swift
//  Assignment
//
//  Created by Sam.Lee on 8/7/24.
//
//

import Foundation
import CoreData


extension UserModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserModel> {
        return NSFetchRequest<UserModel>(entityName: "UserModel")
    }

    @NSManaged public var id: String?
    @NSManaged public var password: String?
    @NSManaged public var nickName: String?

}

extension UserModel : Identifiable {

}
