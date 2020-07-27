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
    var uuid = UUID()
    
    var course: JSONCourse? = nil
    
    init(id: String, desc: String? = nil, start: Date, end: Date, days: String, course: JSONCourse? = nil) {
        self.id = id
        self.desc = desc
        self.start = start
        self.end = end
        self.days = days
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
    
}
