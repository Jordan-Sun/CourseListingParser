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
    
    private enum CodingKeys: String, CodingKey {
        case name
        case sessions
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        sessions = try container.decode([JSONSession].self, forKey: .sessions)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(sessions, forKey: .sessions)
    }
    
}
