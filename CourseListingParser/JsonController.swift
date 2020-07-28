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
            print("Failed to write data to file directory: \(fileDirectory).")
        }
        
    }
    
}
