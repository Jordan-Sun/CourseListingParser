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
    var courses = [JSONCourse]()
    
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
    
    private enum CodingKeys: String, CodingKey {
        case fullName
        case shortName
        case code
        case school
        case professors
        case courses
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fullName = try container.decode(String.self, forKey: .fullName)
        shortName = try? container.decode(String.self, forKey: .shortName)
        code = try container.decode(String.self, forKey: .code)
        school = try? container.decode(JSONSchool.self, forKey: .school)
        professors = try container.decode([JSONProfessor].self, forKey: .professors)
        courses = try container.decode([JSONCourse].self, forKey: .courses)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fullName, forKey: .fullName)
        try? container.encode(shortName, forKey: .shortName)
        try container.encode(code, forKey: .code)
        try container.encode(professors, forKey: .professors)
        try container.encode(courses, forKey: .courses)
    }
    
}
