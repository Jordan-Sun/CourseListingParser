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
    
    private enum CodingKeys: String, CodingKey {
        case fullName
        case shortName
        case departments
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fullName = try container.decode(String.self, forKey: .fullName)
        shortName = try? container.decode(String.self, forKey: .shortName)
        departments = try container.decode([JSONDepartment].self, forKey: .departments)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(fullName, forKey: .fullName)
        try? container.encode(shortName, forKey: .shortName)
        try container.encode(departments, forKey: .departments)
    }
    
}
