//
//  JsonDepartment.swift
//  CourseListingParser
//
//  Created by Zhuoran Sun on 2020/7/26.
//  Copyright © 2020 washu. All rights reserved.
//

import Foundation

class JSONDepartment: Codable, Hashable {
    
    var fullName: String
    var shortName: String? = nil
    var code: String
    
    var school: JSONSchool? = nil
    var professors = [JSONProfessor]()
    
    init(fullName: String, shortName: String? = nil, code: String, school: JSONSchool? = nil) {
        self.fullName = fullName
        self.shortName = shortName
        self.code = code
        if let unwrappedSchool = school {
            self.school = unwrappedSchool
            unwrappedSchool.departments.append(self)
        }
    }
    
    static func == (lhs: JSONDepartment, rhs: JSONDepartment) -> Bool {
        lhs.code == rhs.code
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }
    
}
