//
//  Logger.swift
//  YeongPlayer
//
//  Created by inforex on 2021/09/15.
//

import Foundation
import os.log

class log {
    private class config {
        static var systemLog: Active = .disable
        static var date: Active = .enable
        static var event: Active = .enable
        static var fileName: Active = .enable
        static var lineColumn: Active = .enable
        static var funcName: Active = .enable
    }
    
    enum Active {
        case disable
        case enable
        
        var rawValue: Bool {
            switch self {
            case .disable: return false
            case .enable: return true
            }
        }
    }
    
    enum Event: String {
        case e = "‼️"
        case i = "ℹ️"
        case d = "🔷"
        case v = "💬"
        case w = "⚠️"
        case s = "🔥"
    }
    
    static var filter: String = "*^-^*"
    static var dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
    static var dateForMatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
    
    class func log(_ object: Any,
                   date: String,
                   event: String,
                   sourceFileName: String,
                   line: Int,
                   column: Int,
                   funcName: String) {
        let date = config.date.rawValue ? date : ""
        let event = config.event.rawValue ? event : ""
        let sourceFileName = config.fileName.rawValue ? "[\(sourceFileName)]" : ""
        let lineColumn = config.lineColumn.rawValue ? "\(line):\(column)" : ""
        let funcName = config.funcName.rawValue ? funcName : ""
        
        if let mode = getenv("OS_ACTIVITY_MODE") {
            if (strcmp(mode, "disable") == 0) { config.systemLog = .disable }
            else { config.systemLog = .enable }
        } else {
            config.systemLog = .enable
        }
        
        #if DEBUG
        if config.systemLog.rawValue {
            NSLog("\(lineColumn) \(filter)\(event)\(sourceFileName) \(funcName) : \(object)")
        } else {
            print("\(date) \(lineColumn) \(filter)\(event)\(sourceFileName) \(funcName) : \(object)")
        }
        #endif
        
    }
    
    class func e(_ object: Any,
                 filename: String = #file,
                 line: Int = #line,
                 column: Int = #column,
                 funcName: String = #function) {
        log(object, date: dateForMatter.string(from: Date()), event: Event.e.rawValue, sourceFileName: sourceFileName(filePath: filename), line: line, column: column, funcName: funcName)
    }
    
    class func i(_ object: Any,
                 filename: String = #file,
                 line: Int = #line,
                 column: Int = #column,
                 funcName: String = #function) {
        log(object, date: dateForMatter.string(from: Date()), event: Event.i.rawValue, sourceFileName: sourceFileName(filePath: filename), line: line, column: column, funcName: funcName)
    }
    
    class func d(_ object: Any,
                 filename: String = #file,
                 line: Int = #line,
                 column: Int = #column,
                 funcName: String = #function) {
        log(object, date: dateForMatter.string(from: Date()), event: Event.d.rawValue, sourceFileName: sourceFileName(filePath: filename), line: line, column: column, funcName: funcName)
    }
    
    class func v(_ object: Any,
                 filename: String = #file,
                 line: Int = #line,
                 column: Int = #column,
                 funcName: String = #function) {
        log(object, date: dateForMatter.string(from: Date()), event: Event.v.rawValue, sourceFileName: sourceFileName(filePath: filename), line: line, column: column, funcName: funcName)
    }
    
    class func w(_ object: Any,
                 filename: String = #file,
                 line: Int = #line,
                 column: Int = #column,
                 funcName: String = #function) {
        log(object, date: dateForMatter.string(from: Date()), event: Event.w.rawValue, sourceFileName: sourceFileName(filePath: filename), line: line, column: column, funcName: funcName)
    }
    
    
    class func s(_ object: Any,
                 filename: String = #file,
                 line: Int = #line,
                 column: Int = #column,
                 funcName: String = #function) {
        log(object, date: dateForMatter.string(from: Date()), event: Event.s.rawValue, sourceFileName: sourceFileName(filePath: filename), line: line, column: column, funcName: funcName)
    }
}
