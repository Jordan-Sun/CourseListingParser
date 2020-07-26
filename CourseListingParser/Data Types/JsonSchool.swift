//
//  JsonSchool.swift
//  CourseListingParser
//
//  Created by Zhuoran Sun on 2020/7/26.
//  Copyright © 2020 washu. All rights reserved.
//

import Foundation

class JSONSchool: Codable, Hashable {
    
    var fullName: String
    var shortName: String? = nil
    
    var departments = [JSONDepartment]()
    
    init(fullName: String, shortName: String? = nil) {
        self.fullName = fullName
        self.shortName = shortName
    }
    
    static func == (lhs: JSONSchool, rhs: JSONSchool) -> Bool {
        lhs.fullName == rhs.fullName
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(fullName)
    }
    
}
