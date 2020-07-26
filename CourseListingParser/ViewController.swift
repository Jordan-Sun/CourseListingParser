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
                    print(jsonDepartments)
                } else {
                    print("Failed to decode department info.")
                }
            } else {
                print("Department red link element not found in tab dept bar: \(deptBar)")
            }
        }
        
        // Scrap course info
        guard let courseDivs: Elements = try? bodyDivResults.select("div.DivDetail") else {
            print("Body div detail element not found in document.")
            return
        }
        for courseDiv in courseDivs {
            let courseDivId = courseDiv.id()
            let sessionIndex = courseDivId.index(courseDivId.startIndex, offsetBy: 8)
            let departmentIndex = courseDivId.index(courseDivId.startIndex, offsetBy: 14)
            let courseIndex = courseDivId.index(courseDivId.startIndex, offsetBy: 17)
            let sessionName = String(courseDivId[sessionIndex ..< departmentIndex])
            let departmentCode = String(courseDivId[departmentIndex ..< courseIndex])
            let courseCode = String(courseDivId[courseIndex...])
            print("Session: \(sessionName), Department: \(departmentCode), Course: \(courseCode)")
            if let courseTrs: Elements = try? courseDiv.select("tr") {
                for courseTr in courseTrs {
                    if let courseTrText = try? courseTr.text() {
                        let splits = courseTrText.split(separator: ":")
                        var description = ""
                        var attributes = ""
                        switch splits[0] {
                        case "Description":
                            description = String(splits[1])
                        default:
                            break
                        }
//                        jsonCourses.append(JSONCourse(id: <#T##String#>, name: <#T##String#>, desc: description, department: <#T##JSONDepartment#>, professor: <#T##JSONProfessor#>, session: <#T##JSONSession#>))
                    } else {
                        print("Unable to get course tr text from course tr: \(courseTr)")
                    }
                }
            } else {
                print("Descriptions not found in course div: \(courseDiv)")
            }
        }
        
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
    
}
