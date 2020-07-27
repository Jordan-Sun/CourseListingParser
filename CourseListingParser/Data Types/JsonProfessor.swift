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
    
    private enum CodingKeys: String, CodingKey {
        case name
        case department
        case courses
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        department = try? container.decode(JSONDepartment.self, forKey: .department)
        courses = try container.decode([JSONCourse].self, forKey: .courses)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(courses, forKey: .courses)
    }
    
}
