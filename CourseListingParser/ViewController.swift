//
//  ViewController.swift
//  CourseListingParser
//
//  Created by Zhuoran Sun on 2020/7/25.
//  Copyright © 2020 washu. All rights reserved.
//

import UIKit
import WebKit
import SwiftSoup

class ViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var label: UILabel!
    var finishedNavigation = false
    
    var unknownSchool = JSONSchool(fullName: "Unkown School")
    var jsonDepartments = [JSONDepartment]()
    var jsonSessions = [JSONSession]()
    var jsonCourses = [JSONCourse]()
    let jsonController = JsonController()
    
    fileprivate func loadWebView() {
        // Do any additional setup after loading the view.
        guard let url = URL(string: "https://acadinfo.wustl.edu/Courselistings/Semester/Listing.aspx") else {
            print("Fail to generate url.")
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebView()
        webView.navigationDelegate = self
    }
    
    @IBAction func parseButton(_ sender: Any) {
        webView.evaluateJavaScript("new XMLSerializer().serializeToString(document)", completionHandler: { (html: Any?, error: Error?) in
            guard let htmlString = html as? String else {
                print("Fail to convert html to String.")
                return
            }
            self.parse(htmlString)
        })
    }
    
}

extension ViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Web view did finished navigation.")
    }
    
    /// Prase the data from a html string.
    /// - Parameter html: The html to prase as a string.
    func parse(_ html: String) {
        
        // Clean data storage
        jsonDepartments = [JSONDepartment]()
        jsonSessions = [JSONSession]()
        jsonCourses = [JSONCourse]()
        
        // Parse document
        guard let doc: Document = try? SwiftSoup.parse(html) else {
            print("Swift soup failed to parse html document.")
            return
        }
        guard let bodyDivResults: Element = try? doc.select("div#Body_divResults").first() else {
            print("Body div results element not found in document.")
            return
        }
        
// Scrap department info
        
        // Find
        guard let deptBars: Elements = try? bodyDivResults.select("table#tabDeptBar0") else {
            print("Tab dept bar element not found in document.")
            return
        }
        
        for deptBar in deptBars {
            
            if let redLink: Element = try? deptBar.select("a.RedLink").first() {
                
                let deptName = try? redLink.text()
                
                if let splits = deptName?.split(separator: "(") {
                    
                    let deptFullName = String(splits[0])
                    let deptCode = String(splits[1].split(separator: ")")[0])
                    jsonDepartments.append(JSONDepartment(fullName: deptFullName, code: deptCode, school: unknownSchool))
                    
                } else {
                    print("Failed to decode department info.")
                }
                
            } else {
                print("Department red link element not found in tab dept bar: \(deptBar)")
            }
            
        }
        
// Scrap course info
        // Find <div class="Crs****">
        guard let courseDivs: Elements = try? bodyDivResults.select("div[class^=Crs]") else {
            print("Body div course div element not found in document.")
            return
        }
        
        for courseDiv in courseDivs {
            
            var newCourse: JSONCourse!
            
            // Find <td style="width:14%;vertical-align:top;">
            guard let courseInfoTd = try? courseDiv.select("td[style=\"width:14%;vertical-align:top;\"]").first()?.text() else {
                print("Course div info td element not found in document.")
                return
            }
            
            // Assign course info
            let courseInfoSplit = courseInfoTd.split(separator: " ")
            if courseInfoSplit.count == 3 {
                let departmentCode = String(courseInfoSplit[0])
                let departmentIndex = findDeptIndexByCode(code: departmentCode)
//                let departmentAbbrivation = String(courseInfoSplit[1])
                let courseId = String(courseInfoSplit[2])
                newCourse = JSONCourse(id: courseId, name: "Unknown Course", desc: nil, department: jsonDepartments[departmentIndex], professor: nil, session: nil)
            } else {
                print("Invalid course info split count for course div info.")
            }
            
            // Create new course
            
            
            // Find <td style="width:57%;vertical-align:top;">
            guard let courseNameTd = try? courseDiv.select("td[style=\"width:57%;vertical-align:top;\"]").first()?.text() else {
                print("Course div course name td element not found in document.")
                return
            }
            
            // Assign course name
            newCourse.name = courseNameTd

            // Find <div id="dvDetail*" class="DivDetail" style="margin-left: 6px; width: 100%; display: none;">
            guard let courseDetailDiv: Element = try? courseDiv.select("div.DivDetail").first() else {
                print("Course div detail div not found in document.")
                return
            }
//
//            // Assign session name
//            let courseDivId = courseDetailDiv.id()
//            let sessionName = String(courseDivId[courseDivId.index(courseDivId.startIndex, offsetBy: 8) ..< courseDivId.index(courseDivId.startIndex, offsetBy: 14)])
            
            // Find <td style="width:91%;">
            guard let courseDescTd: Element = try? courseDetailDiv.select("td[style=\"width:91%;\"]").first() else {
                print("Course div detail div course desc td not found in document.")
                return
            }
            newCourse.desc = try? courseDescTd.text()
            
            // Find <div id="dvResultTable*" class="ResultTable" style="width:100%;">
            guard let courseResultTableDiv: Element = try? courseDiv.select("div.ResultTable").first() else {
                print("Course div result table div not found in document.")
                return
            }
            
            // Find <div class="ResultRow2*" id="divSelectRow*" dept="*" crs="*" sch="*">
            guard let sectionResultRow2Divs: Elements = try? courseResultTableDiv.select("div[class^=\"ResultRow2\"]") else {
                print("Course div result table div result row 2 div not found in document.")
                return
            }
            
            for sectionResultRow2Div in sectionResultRow2Divs {
                
                // Find <a style="text-align:left; color:#0000ff;" class="lnkSubSemester" sem="*">
                guard let sectionResultLnkSubSemester: Element = try? sectionResultRow2Div.select("a.lnkSubSemester").first() else {
                    print("Course div result table div result row 2 div lnk sub semester a not found in document.")
                    return
                }
//                guard let semesterName = try? sectionResultLnkSubSemester.attr("sem") else {
//                    print("Course div result table div result row 2 div lnk sub semester a sem attribute not found in document.")
//                    return
//                }
//                print(semesterName)
                
                // Find <td style="width:250px;">
                guard let sectionResultSectionStartEndTd = try? sectionResultRow2Div.select("td[style=\"width:250px;\"]").first()?.text() else {
                    print("Course div result table div result row 2 div section start and end time td not found in document.")
                    return
                }
                let dateSplit = sectionResultSectionStartEndTd.split(separator: " ")
                let startSplit = dateSplit[0].split(separator: ":")
                let endSplit = dateSplit[1].split(separator: ":")
                
                // Find <td class="ItemRow">
                var resultStrings = [String]()
                guard let sectionResultItemRowTds: Elements = try? sectionResultRow2Div.select("td.ItemRow") else {
                    print("Course div result table div result row 2 div item row td not found in document.")
                    return
                }
                for sectionResultItemRowTd in sectionResultItemRowTds {
                    if let resultString = try? sectionResultItemRowTd.text() {
                        resultStrings.append(resultString)
                    } else {
                        resultStrings.append("")
                        print("Fail to cast course div result table div result row 2 div item row td into string")
                    }
                }
                
                // Find <td style="width:650px;"> (Optional)
                var desc: String? = nil
                if let sectionResultDescTd: Element = try? sectionResultRow2Div.select("td[style=\"width:650px;\"]").first() {
                    desc = try? sectionResultDescTd.text()
                }
                
                // Assign section
                let timeSplits = resultStrings[2].split(separator: "-")
                if (startSplit.count == 2) && (endSplit.count == 2) && (timeSplits.count == 2) {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = " MM/dd/yyyy hh:mma"
                    let startDateString = String(startSplit[1]) + " " + String(timeSplits[0]) + "M"
                    let startDate = dateFormatter.date(from: startDateString)!
                    let endDateString = String(endSplit[1]) + " " + String(timeSplits[1]) + "M"
                    let endDate = dateFormatter.date(from: endDateString)!
                    let _ = JSONSection(id: resultStrings[0], desc: desc, start: startDate, end: endDate, days: resultStrings[1], location: resultStrings[3], course: newCourse)
                } else {
                    print("Fail to cast course div result table div result row 2 div item row td into json section")
                }
            }
            
            // Assign course
            jsonCourses.append(newCourse)
            
        }
        
        jsonController.writeEncodableToDocuments(jsonDepartments)
        
    }
    
    /// Find a department in the cache array with a given department code, and create one if not found.
    /// - Parameter code: A string indicating the department code of the department.
    /// - Returns: The index of the department in the cache array.
    func findDeptIndexByCode(code: String) -> Int {
        for jsonDepartment in jsonDepartments {
            if jsonDepartment.code == code {
                return jsonDepartments.firstIndex(of: jsonDepartment)!
            }
        }
        jsonDepartments.append(JSONDepartment(fullName: "Unknown Department", code: code, school: unknownSchool))
        return jsonDepartments.count - 1
    }
    
//    /// Find a session in the cache array with a given session name, and create one if not found
//    /// - Parameter name: A string indicating the session name of the department
//    /// - Returns: <#description#>
//    func findSessionIndexByName(name: String) -> Int {
//        for jsonSession in jsonSessions {
//            if jsonSession.name == name {
//                return jsonSessions.firstIndex(of: jsonSession)!
//            }
//        }
//        jsonSessions.append(JSONSession(name: <#T##String#>, start: <#T##Date#>, end: <#T##Date#>))
//        return jsonDepartments.count - 1
//    }
    
}
