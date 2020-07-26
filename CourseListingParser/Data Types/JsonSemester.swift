//
//  JsonSemester.swift
//  CourseListingParser
//
//  Created by Zhuoran Sun on 2020/7/26.
//  Copyright © 2020 washu. All rights reserved.
//

import Foundation

class JSONSemester: Codable, Hashable {
    
    var name: String
    
    var sessions = [JSONSession]()
    
    init(name: String) {
        self.name = name
    }
    
    static func == (lhs: JSONSemester, rhs: JSONSemester) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
}
