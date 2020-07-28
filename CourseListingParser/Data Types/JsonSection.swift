//
//  JsonSection.swift
//  CourseListingParser
//
//  Created by Zhuoran Sun on 2020/7/26.
//  Copyright © 2020 washu. All rights reserved.
//

import Foundation

class JSONSection: Codable, Hashable {
    
    var id: String
    var desc: String? = nil
    var start: Date
    var end: Date
    var days: String
    var location: String? = nil
    var uuid = UUID()
    
    var course: JSONCourse? = nil
    
    init(id: String, desc: String? = nil, start: Date, end: Date, days: String, location: String? = nil, course: JSONCourse? = nil) {
        self.id = id
        self.desc = desc
        self.start = start
        self.end = end
        self.days = days
        self.location = location
        if let unwrappedCourse = course {
            self.course = unwrappedCourse
            unwrappedCourse.sections.append(self)
        }
    }
    
    static func == (lhs: JSONSection, rhs: JSONSection) -> Bool {
        lhs.uuid == rhs.uuid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case description
        case start
        case end
        case days
        case location
        case course
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        desc = try? container.decode(String.self, forKey: .description)
        start = try container.decode(Date.self, forKey: .start)
        end = try container.decode(Date.self, forKey: .end)
        days = try container.decode(String.self, forKey: .days)
        location = try? container.decode(String.self, forKey: .location)
        course = try container.decode(JSONCourse.self, forKey: .course)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try? container.encode(desc, forKey: .description)
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
        try container.encode(days, forKey: .days)
        try? container.encode(location, forKey: .location)
    }
    
}
