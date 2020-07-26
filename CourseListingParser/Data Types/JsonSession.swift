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
    
}
