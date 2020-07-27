//
//  JsonProfessor.swift
//  CourseListingParser
//
//  Created by Zhuoran Sun on 2020/7/26.
//  Copyright © 2020 washu. All rights reserved.
//

import Foundation

class JSONProfessor: Codable, Hashable {
    
    var name: String
    
    var department: JSONDepartment? = nil
    var courses = [JSONCourse]()
    
    init(name: String, department: JSONDepartment? = nil) {
        self.name = name
        if let unwrappedDepartment = department {
            self.department = unwrappedDepartment
            unwrappedDepartment.professors.append(self)
        }
    }
    
    static func == (lhs: JSONProfessor, rhs: JSONProfessor) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
}
