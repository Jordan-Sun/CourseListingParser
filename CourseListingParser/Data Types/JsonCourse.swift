//
//  JsonCourse.swift
//  CourseListingParser
//
//  Created by Zhuoran Sun on 2020/7/26.
//  Copyright © 2020 washu. All rights reserved.
//

import Foundation

class JSONCourse: Codable, Hashable {
    
    var id: String
    var name: String
    var desc: String? = nil
    var unit: Int? = nil
    
    var department: JSONDepartment? = nil
    var professor: JSONProfessor? = nil
    var session: JSONSession? = nil
    var attributes = [JSONAttribute]()
    var sections = [JSONSection]()
    
    init(id: String, name: String, desc: String? = nil, unit: Int? = nil, department: JSONDepartment? = nil, professor: JSONProfessor? = nil, session: JSONSession? = nil) {
        self.id = id
        self.name = name
        self.desc = desc
        self.unit = unit
        if let unwrappedDepartment = department {
            self.department = unwrappedDepartment
            unwrappedDepartment.courses.append(self)
        }
        if let unwrappedProfessor = professor {
            self.professor = unwrappedProfessor
            unwrappedProfessor.courses.append(self)
        }
        if let unwrappedSession = session {
            self.session = unwrappedSession
            unwrappedSession.courses.append(self)
        }
    }
    
    static func == (lhs: JSONCourse, rhs: JSONCourse) -> Bool {
        (lhs.id == rhs.id) && (lhs.name == rhs.name)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
    
}
