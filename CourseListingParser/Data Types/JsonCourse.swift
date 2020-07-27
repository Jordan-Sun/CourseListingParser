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
//    var attributes = [JSONAttribute]()
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
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case unit
        case department
        case professor
        case session
        case sections
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        desc = try container.decode(String.self, forKey: .description)
        department = try? container.decode(JSONDepartment.self, forKey: .department)
        professor = try? container.decode(JSONProfessor.self, forKey: .professor)
        session = try? container.decode(JSONSession.self, forKey: .session)
        sections = try container.decode([JSONSection].self, forKey: .sections)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(desc, forKey: .description)
        try container.encode(sections, forKey: .sections)
    }
    
}
