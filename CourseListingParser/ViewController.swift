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

    /// Web view outlet
    @IBOutlet weak var webView: WKWebView!
    
    /// Activity Indicator view outlet
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    /// Collection view outlet
    @IBOutlet weak var collectionView: UICollectionView!
    /// Collection view data source
    private var collectionViewDiffableDataSource: UICollectionViewDiffableDataSource<JSONCourse,JSONSection>!
    
    var unknownSchool = JSONSchool(fullName: "Unkown School")
    var jsonDepartments = [JSONDepartment]()
    var jsonSessions = [JSONSession]()
    var jsonCourses = [JSONCourse]()
    let jsonController = JsonController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebView()
        configureCollectionLayout()
        configureCollectionDataSource()
        webView.navigationDelegate = self
    }
    
    fileprivate func loadWebView() {
        // Do any additional setup after loading the view.
        guard let url = URL(string: "https://acadinfo.wustl.edu/Courselistings/Semester/Listing.aspx") else {
            print("Fail to generate url.")
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
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

// Collection View Layout

extension ViewController {
    
    /// Configure the layout of the movie preview collection view
    private func configureCollectionLayout() {
        collectionView.collectionViewLayout = createLayout()
        collectionView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: "courseHeader", withReuseIdentifier: HeaderCollectionReusableView.reuseIdentifier)
    }
    
    /// Create a new collection view compositional layout
    private func createLayout() -> UICollectionViewCompositionalLayout {
        
        let layout = UICollectionViewCompositionalLayout {
            (_: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
            
            let groupColumns = 1
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: groupColumns)
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .estimated(44)), elementKind: "courseHeader", alignment: .top)
            header.pinToVisibleBounds = true
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [header]
            
            return section
            
        }
        
        return layout
        
    }
    
}

// Collection View Data Source

extension ViewController {
    
    /// Configure the datasource of the movie preview collection view
    private func configureCollectionDataSource() {
        
        // Diffable data source cell provider
        collectionViewDiffableDataSource = UICollectionViewDiffableDataSource<JSONCourse,JSONSection>(collectionView: self.collectionView) { (collectionView, indexPath, section) -> UICollectionViewCell? in
            
            // Dequeue reuseable cell
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.reuseIdentifier, for: indexPath) as? CollectionViewCell else {
                fatalError("Expected reused cell to be of type CollectionViewCell.")
            }
            
            // Update cell
            cell.idLabel.text = section.id
            cell.daysLabel.text = section.days
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.setLocalizedDateFormatFromTemplate("hh:mm a")
            cell.timeLabel.text = "\(dateFormatter.string(from: section.start))-\(dateFormatter.string(from: section.end))"
            cell.locationLabel.text = section.location
            dateFormatter.setLocalizedDateFormatFromTemplate("MM/dd/yyyy")
            cell.startLabel.text = dateFormatter.string(from: section.start)
            cell.endLabel.text = dateFormatter.string(from: section.end)
            if (section.desc != nil) && (section.desc != "") {
                cell.descriptionLabel.text = section.desc
                cell.descriptionLabel.isHidden = false
            } else {
                cell.descriptionLabel.isHidden = true
            }
            cell.layer.cornerRadius = 8
            cell.backgroundColor = .secondarySystemBackground
            
            return cell
            
        }
        
        // Diffable data source supplementary view provider
        collectionViewDiffableDataSource.supplementaryViewProvider = {
            (collectionView, kind, indexPath) -> UICollectionReusableView? in

            // Check is proving a rating badge supplementary view
            switch kind {
            case "courseHeader":
                return self.createHeader(collectionView: collectionView, indexPath: indexPath)
            default:
                return nil
            }

        }
        
    }
    
    private func createHeader(collectionView: UICollectionView, indexPath: IndexPath) -> HeaderCollectionReusableView? {

        // Dequeue reuseable supplementary view
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: "courseHeader", withReuseIdentifier: HeaderCollectionReusableView.reuseIdentifier, for: indexPath) as? HeaderCollectionReusableView else {
            fatalError("Expected reused badge to be of type HeaderCollectionReusableView.")
        }
        
        // Configure header
        header.backgroundColor = .systemGray
        if let course = collectionViewDiffableDataSource.itemIdentifier(for: indexPath)?.course {
            if let department = course.department {
                header.label.text = "\(department.code) \(course.id) \(course.name)"
            } else {
                header.label.text = "\(course.id) \(course.name)"
            }
        } else {
            header.label.text = "Unknown Course"
        }

        return header

    }
    
    /// Initialize the snapshot using NSFetchRequest
    private func updateSnapshot() {
        
        // Initialize a new snapshot
        var snapshot = NSDiffableDataSourceSnapshot<JSONCourse, JSONSection>()
        
        // Fetch all course and section
        snapshot.appendSections(jsonCourses)
        for jsonCourse in jsonCourses {
            snapshot.appendItems(jsonCourse.sections, toSection: jsonCourse)
        }
        
        // Apply snapshot
        collectionViewDiffableDataSource.apply(snapshot)
        
    }
    
}

// Web Kit Parsing

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
        updateSnapshot()
        activityIndicatorView.startAnimating()
        
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
        
        // Find department bar
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
//                guard let sectionResultLnkSubSemester: Element = try? sectionResultRow2Div.select("a.lnkSubSemester").first() else {
//                    print("Course div result table div result row 2 div lnk sub semester a not found in document.")
//                    return
//                }
//                guard let semesterName = try? sectionResultLnkSubSemester.attr("sem") else {
//                    print("Course div result table div result row 2 div lnk sub semester a sem attribute not found in document.")
//                    return
//                }
//                print(semesterName)
                
                // Find <td style="width:250px;">
                var startDayString = ""
                var endDayString = ""
                if let sectionResultSectionStartEndTd = try? sectionResultRow2Div.select("td[style=\"width:250px;\"]").first()?.text() {
                    let dateSplit = sectionResultSectionStartEndTd.split(separator: " ")
                    let startSplit = dateSplit[0].split(separator: ":")
                    startDayString = String(startSplit[1])
                    let endSplit = dateSplit[1].split(separator: ":")
                    endDayString = String(endSplit[1])
                } else {
                    print("Course div result table div result row 2 div section start and end time td not found in document.")
                }
                
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
                if (!startDayString.isEmpty) && (!endDayString.isEmpty) && (timeSplits.count == 2) {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = " MM/dd/yyyy hh:mma"
                    let startDateString = startDayString + " " + String(timeSplits[0]) + "M"
                    let startDate = dateFormatter.date(from: startDateString)!
                    let endDateString = endDayString + " " + String(timeSplits[1]) + "M"
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
        updateSnapshot()
        activityIndicatorView.stopAnimating()
        
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
