//
//  JsonSession.swift
//  CourseListingParser
//
//  Created by Zhuoran Sun on 2020/7/26.
//  Copyright © 2020 washu. All rights reserved.
//

import Foundation

class JSONSession: Codable, Hashable {
    
    var name: String
    var start: Date
    var end: Date
    
    var semester: JSONSemester? = nil
    var courses = [JSONCourse]()
    
    init(name: String, start: Date, end: Date) {
        self.name = name
        self.start = start
        self.end = end
    }
    
    static func == (lhs: JSONSession, rhs: JSONSession) -> Bool {
        (lhs.name == rhs.name) && (lhs.start == rhs.start) && (lhs.end == rhs.end)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(start)
        hasher.combine(end)
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case start
        case end
        case semester
        case courses
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        start = try container.decode(Date.self, forKey: .start)
        end = try container.decode(Date.self, forKey: .end)
        semester = try? container.decode(JSONSemester.self, forKey: .semester)
        courses = try container.decode([JSONCourse].self, forKey: .courses)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
        try container.encode(courses, forKey: .courses)
    }
    
}
