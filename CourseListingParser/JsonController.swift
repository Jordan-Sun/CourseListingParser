//
//  JsonController.swift
//  WashU Calendar
//
//  Created by Zhuoran Sun on 2020/7/19.
//  Copyright © 2020 washu. All rights reserved.
//

import Foundation

class JsonController {
    
    var documentsDirectory: URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths.first
        return documentsDirectory
    }
    
}

extension JsonController {
    
    public func writeEncodableToDocuments<T>(_ encodable: T) where T: Encodable {
        
        // Try to encode data.
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        guard let data = try? jsonEncoder.encode(encodable) else {
            print("Failed to encode json data.")
            return
        }
        
        // Try to get the documents directory.
        guard let documentsDirectory = documentsDirectory else {
            print("Failed to get the url for documents directory.")
            return
        }
        print("Generating test data at path: \(documentsDirectory.absoluteString)")
        
        // Try to write encoded data to the documents directory.
        let timeStamp = Date().timeIntervalSince1970
        let fileDirectory = documentsDirectory.appendingPathComponent("\(timeStamp).json")
        do {
            try data.write(to: fileDirectory)
        } catch {
            print("Filed to write data to file directory: \(fileDirectory).")
        }
        
    }
    
}

// DEPRECIATED, DO NOT USE.

// Generate Json Files
/*
extension JsonController {
    
    private func writeDataToDocuments(_ data: Data, objectKind: String, superName: String = "All", page: Int) {
        
        // Try to get the documents directory.
        guard let documentsDirectory = documentsDirectory else {
            print("Failed to get the url for documents directory.")
            return
        }
        
        let fileDirectory = documentsDirectory.appendingPathComponent("\(objectKind)_\(superName)_\(page).json")
        do {
            try data.write(to: fileDirectory)
        } catch {
            print("Filed to write data to file directory: \(fileDirectory).")
        }
        
    }
    
    func generateSchoolResults(schools: [JSONSchool]) {
        
        // Calculate the total number of pages needed to generate.
        let total_pages = (schools.count - 1) / 20 + 1
        
        // Generate all pages except for the last page.
        for page in 1 ..< total_pages {
            // Gather school results.
            let startIndex = (page - 1) * 20
            let endIndex = page * 20
            let schoolResults = JSONSchoolResults(page: page, total_pages: total_pages, schools: Array(schools[startIndex..<endIndex]))
            // Try to encode data.
            guard let data = try? JSONEncoder().encode(schoolResults) else {
                print("Failed to encode the \(page) page of school results to json data.")
                return
            }
            writeDataToDocuments(data, objectKind: "School", page: page)
        }
        
        // Generate the last page.
        // Gather school results.
        let startIndex = (total_pages - 1) * 20
        let schoolResults = JSONSchoolResults(page: total_pages, total_pages: total_pages, schools: Array(schools[startIndex...]))
        // Try to encode data.
        guard let data = try? JSONEncoder().encode(schoolResults) else {
            print("Failed to encode the \(total_pages) page of school results to json data.")
            return
        }
        writeDataToDocuments(data, objectKind: "School", page: total_pages)
        
    }
    
    func generateDepartmentResults(departments: [JSONDepartment], school: JSONSchool? = nil) {
        
        // Validate input.
        if let school = school {
            for department in departments {
                guard let departmentSchool = department.school else {
                    print("Expected that \(department.fullName) belongs to \(school.fullName), but found that it does not belong to any school.")
                    return
                }
                guard departmentSchool == school else {
                    print("Expected that \(department.fullName) belongs to \(school.fullName), but found that it belongs to \(departmentSchool.fullName).")
                    return
                }
            }
        }
        
        // Get the name of the school.
        let superName = school?.fullName ?? "All"
        // Calculate the total number of pages needed to generate.
        let total_pages = (departments.count - 1) / 20 + 1
        
        // Generate all pages except for the last page.
        for page in 1 ..< total_pages {
            // Gather school results.
            let startIndex = (page - 1) * 20
            let endIndex = page * 20
            let departmentResults = JSONDepartmentResults(school: school, page: page, total_pages: total_pages, departments: Array(departments[startIndex..<endIndex]))
            // Try to encode data.
            guard let data = try? JSONEncoder().encode(departmentResults) else {
                print("Failed to encode the \(page) page of department results to json data.")
                return
            }
            writeDataToDocuments(data, objectKind: "Department", superName: superName, page: page)
        }
        
        // Generate the last page.
        // Gather school results.
        let startIndex = (total_pages - 1) * 20
        let departmentResults = JSONDepartmentResults(school: school, page: total_pages, total_pages: total_pages, departments: Array(departments[startIndex...]))
        // Try to encode data.
        guard let data = try? JSONEncoder().encode(departmentResults) else {
            print("Failed to encode the \(total_pages) page of department results to json data.")
            return
        }
        writeDataToDocuments(data, objectKind: "Department", superName: superName, page: total_pages)
        
    }
    
    func generateProfessorResults(professors: [JSONProfessor], department: JSONDepartment? = nil) {
        
        // Validate input.
        if let department = department {
            for professor in professors {
                guard let professorDepartment = professor.department else {
                    print("Expected that \(professor.name) belongs to \(department.fullName), but found that it does not belong to any department.")
                    return
                }
                guard professorDepartment == department else {
                    print("Expected that \(professor.name) belongs to \(department.fullName), but found that it belongs to \(professorDepartment.fullName).")
                    return
                }
            }
        }
        
        // Get the name of the school.
        let superName = department?.fullName ?? "All"
        // Calculate the total number of pages needed to generate.
        let total_pages = (professors.count - 1) / 20 + 1
        
        // Generate all pages except for the last page.
        for page in 1 ..< total_pages {
            // Gather school results.
            let startIndex = (page - 1) * 20
            let endIndex = page * 20
            let professorResults = JSONProfessorResults(department: department, page: page, total_pages: total_pages, professors: Array(professors[startIndex..<endIndex]))
            // Try to encode data.
            guard let data = try? JSONEncoder().encode(professorResults) else {
                print("Failed to encode the \(page) page of professor results to json data.")
                return
            }
            writeDataToDocuments(data, objectKind: "Professor", superName: superName, page: page)
        }
        
        // Generate the last page.
        // Gather school results.
        let startIndex = (total_pages - 1) * 20
        let professorResults = JSONProfessorResults(department: department, page: total_pages, total_pages: total_pages, professors: Array(professors[startIndex...]))
        // Try to encode data.
        guard let data = try? JSONEncoder().encode(professorResults) else {
            print("Failed to encode the \(total_pages) page of professor results to json data.")
            return
        }
        writeDataToDocuments(data, objectKind: "Professor", superName: superName, page: total_pages)
        
    }
    
    func generateSemesterResults(semesters: [JSONSemester]) {
        
        // Calculate the total number of pages needed to generate.
        let total_pages = (semesters.count - 1) / 20 + 1
        
        // Generate all pages except for the last page.
        for page in 1 ..< total_pages {
            // Gather school results.
            let startIndex = (page - 1) * 20
            let endIndex = page * 20
            let semesterResults = JSONSemesterResults(page: page, total_pages: total_pages, semesters: Array(semesters[startIndex..<endIndex]))
            // Try to encode data.
            guard let data = try? JSONEncoder().encode(semesterResults) else {
                print("Failed to encode the \(page) page of semester results to json data.")
                return
            }
            writeDataToDocuments(data, objectKind: "Semester", page: page)
        }
        
        // Generate the last page.
        // Gather school results.
        let startIndex = (total_pages - 1) * 20
        let semesterResults = JSONSemesterResults(page: total_pages, total_pages: total_pages, semesters: Array(semesters[startIndex...]))
        // Try to encode data.
        guard let data = try? JSONEncoder().encode(semesterResults) else {
            print("Failed to encode the \(total_pages) page of semester results to json data.")
            return
        }
        writeDataToDocuments(data, objectKind: "Semester", page: total_pages)
        
    }
    
    func generateSessionResults(sessions: [JSONSession], semester: JSONSemester? = nil) {
        
        // Validate input.
        if let semester = semester {
            for session in sessions {
                guard let sessionSemester = session.semester else {
                    print("Expected that \(session.name) belongs to \(semester.name), but found that it does not belong to any semester.")
                    return
                }
                guard sessionSemester == semester else {
                    print("Expected that \(session.name) belongs to \(semester.name), but found that it belongs to \(sessionSemester.name).")
                    return
                }
            }
        }
        
        // Get the name of the school.
        let superName = semester?.name ?? "All"
        // Calculate the total number of pages needed to generate.
        let total_pages = (sessions.count - 1) / 20 + 1
        
        // Generate all pages except for the last page.
        for page in 1 ..< total_pages {
            // Gather school results.
            let startIndex = (page - 1) * 20
            let endIndex = page * 20
            let sessionResults = JSONSessionResults(semester: semester, page: page, total_pages: total_pages, sessions: Array(sessions[startIndex..<endIndex]))
            // Try to encode data.
            guard let data = try? JSONEncoder().encode(sessionResults) else {
                print("Failed to encode the \(page) page of session results to json data.")
                return
            }
            writeDataToDocuments(data, objectKind: "Session", superName: superName, page: page)
        }
        
        // Generate the last page.
        // Gather school results.
        let startIndex = (total_pages - 1) * 20
        let sessionResults = JSONSessionResults(semester: semester, page: total_pages, total_pages: total_pages, sessions: Array(sessions[startIndex...]))
        // Try to encode data.
        guard let data = try? JSONEncoder().encode(sessionResults) else {
            print("Failed to encode the \(total_pages) page of session results to json data.")
            return
        }
        writeDataToDocuments(data, objectKind: "Session", superName: superName, page: total_pages)
        
    }
    
    func generateCourseResults(courses: [JSONCourse], department: JSONDepartment? = nil, session: JSONSession? = nil, attribute: JSONAttribute? = nil) {
        
        // Validate input.
        if let department = department {
            for course in courses {
                guard let courseDepartment = course.department else {
                    print("Expected that \(course.name) belongs to \(department.fullName), but found that it does not belong to any department.")
                    return
                }
                guard courseDepartment == department else {
                    print("Expected that \(course.name) belongs to \(department.fullName), but found that it belongs to \(courseDepartment.fullName)")
                    return
                }
            }
        }
        if let session = session {
            for course in courses {
                guard let courseSession = course.session else {
                    print("Expected that \(course.name) belongs to \(session.name), but found that it does not belong to any session")
                    return
                }
                guard courseSession == session else {
                    print("Expected that \(course.name) belongs to \(session.name), but found that it belongs to \(courseSession.name)")
                    return
                }
            }
        }
        if let attribute = attribute {
            for course in courses {
                guard course.attributes.contains(attribute) else {
                    print("Expected that \(course.name) has attribute \(attribute.name).")
                    return
                }
            }
        }
        
        // Get the name of the school.
        let superName = "\(department?.fullName ?? "All")&\(session?.name ?? "All")&\(attribute?.name ?? "All")"
        // Calculate the total number of pages needed to generate.
        let total_pages = (courses.count - 1) / 20 + 1
        
        // Generate all pages except for the last page.
        for page in 1 ..< total_pages {
            // Gather school results.
            let startIndex = (page - 1) * 20
            let endIndex = page * 20
            let courseResults = JSONCourseResults(department: department, session: session, attribute: attribute, page: page, total_pages: total_pages, courses: Array(courses[startIndex..<endIndex]))
            // Try to encode data.
            guard let data = try? JSONEncoder().encode(courseResults) else {
                print("Failed to encode the \(page) page of course results to json data.")
                return
            }
            writeDataToDocuments(data, objectKind: "Course", superName: superName, page: page)
        }
        
        // Generate the last page.
        // Gather school results.
        let startIndex = (total_pages - 1) * 20
        let courseResults = JSONCourseResults(department: department, session: session, attribute: attribute, page: total_pages, total_pages: total_pages, courses: Array(courses[startIndex...]))
        // Try to encode data.
        guard let data = try? JSONEncoder().encode(courseResults) else {
            print("Failed to encode the \(total_pages) page of course results to json data.")
            return
        }
        writeDataToDocuments(data, objectKind: "Course", superName: superName, page: total_pages)
        
    }
    
}
*/
// Debug functions
/*
extension JsonController {
    
    func generateTestData() {
        
        print("Generating test data at path: \(documentsDirectory?.absoluteString ?? "nil")")
        
        let engineering = JSONSchool(fullName: "McKelvey School of Engineering", shortName: "Engineering")
        generateSchoolResults(schools: [engineering])
        let bme = JSONDepartment(fullName: "Biomedical Engineering", shortName: "BME", code: "E62", school: engineering)
        let cse = JSONDepartment(fullName: "Computer Science and Engineering", shortName: "CSE", code: "E81", school: engineering)
        let ese = JSONDepartment(fullName: "Electrical and Systems Engineering", shortName: "ESE", code: "E35", school: engineering)
        let eece = JSONDepartment(fullName: "Energy, Environmental and Chemecial Engineering", shortName: "ChemE", code: "E44", school: engineering)
        let me = JSONDepartment(fullName: "Mechanical Engineering and Materials Science", shortName: "MechE", code: "E37", school: engineering)
        let general = JSONDepartment(fullName: "General Engineering", code: "E60", school: engineering)
        generateDepartmentResults(departments: [bme,cse,ese,eece,me,general])
        generateDepartmentResults(departments: [bme,cse,ese,eece,me,general], school: engineering)
        
    }
    
}
 */
