// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import OSLog

// MARK: - Error Types

public enum VersionRsync {
    case ver3
    case openrsync
}

public enum RsyncParseError: Error, LocalizedError {
    case missingRequiredField(String)
    case invalidNumberFormat(field: String, value: String)
    case invalidOutputFormat(String)
    case incompleteSummaryLine
    case divisionByZero
    case unsupportedVersion
    case nostats
    
    public var errorDescription: String? {
        switch self {
        case .missingRequiredField(let field):
            return "Missing required field: \(field)"
        case .invalidNumberFormat(let field, let value):
            return "Invalid number format in \(field): '\(value)'"
        case .invalidOutputFormat(let details):
            return "Invalid output format: \(details)"
        case .incompleteSummaryLine:
            return "Incomplete or malformed summary line (sent/received/bytes)"
        case .divisionByZero:
            return "Cannot calculate transfer time: bytes/sec is zero"
        case .unsupportedVersion:
            return "Unsupported rsync version or output format"
        case .nostats:
            return "No stats available"
        }
    }
}

public struct ParseResult {
    public let numbersonly: NumbersOnly?
    public let stats: String?
    public let errors: [RsyncParseError]
    public let warnings: [String]
    
    public var isSuccess: Bool {
        return errors.isEmpty && numbersonly != nil
    }
    
    public var hasWarnings: Bool {
        return !warnings.isEmpty
    }
}

// MARK: - Data Structures

public struct NumbersOnly {
    public var numberoffiles: Int
    public var totaldirectories: Int
    public var totalfilesize: Double
    public var filestransferred: Int
    public var totaltransferredfilessize: Double
    public var numberofcreatedfiles: Int
    public var numberofdeletedfiles: Int
    public var datatosynchronize: Bool
}

public struct StringNumbersOnly {
    public var result: String
    public var filestransferred: [String]
    public var totaltransferredfilessize: [String]
    public var totalfilesize: [String]
    public var numberoffiles: [String]
    public var numberofcreatedfiles: [String]
    public var numberofdeletedfiles: [String]
}

// MARK: - Parser

@MainActor
public final class ParseRsyncOutput {
    public var stringnumbersonly: StringNumbersOnly?
    public var numbersonly: NumbersOnly?
    private var stats: String?
    public private(set) var errors: [RsyncParseError] = []
    public private(set) var warnings: [String] = []

    public var formatted_filestransferred: String {
        NumberFormatter.localizedString(from: NSNumber(value: numbersonly?.filestransferred ?? 0), number: NumberFormatter.Style.none)
    }
    public var formatted_numberoffiles: String {
        NumberFormatter.localizedString(from: NSNumber(value: numbersonly?.numberoffiles ?? 0), number: NumberFormatter.Style.decimal)
    }
    public var formatted_totalfilesize: String {
        NumberFormatter.localizedString(from: NSNumber(value: numbersonly?.totalfilesize ?? 0), number: NumberFormatter.Style.decimal)
    }
    public var formatted_totaldirectories: String {
        NumberFormatter.localizedString(from: NSNumber(value: numbersonly?.totaldirectories ?? 0), number: NumberFormatter.Style.decimal)
    }
    public var formatted_numberoffiles_totaldirectories: String {
        NumberFormatter.localizedString(from: NSNumber(value: (numbersonly?.totaldirectories ?? 0) + (numbersonly?.numberoffiles ?? 0)), number: NumberFormatter.Style.decimal)
    }
    public var formatted_numberofcreatedfiles: String {
        NumberFormatter.localizedString(from: NSNumber(value: numbersonly?.numberofcreatedfiles ?? 0), number: NumberFormatter.Style.none)
    }
    public var formatted_numberofdeletedfiles: String {
        NumberFormatter.localizedString(from: NSNumber(value: numbersonly?.numberofdeletedfiles ?? 0), number: NumberFormatter.Style.none)
    }
    
    public var parseResult: ParseResult {
        ParseResult(numbersonly: numbersonly,
                   stats: stats,
                   errors: errors,
                   warnings: warnings)
    }

    private func addError(_ error: RsyncParseError) {
        errors.append(error)
        Logger.process.error("ParseRsyncOutput Error: \(error.localizedDescription)")
    }
    
    private func addWarning(_ warning: String) {
        warnings.append(warning)
        Logger.process.warning("ParseRsyncOutput Warning: \(warning)")
    }
    
    public func getstats() throws -> String? {
        guard let stats else {
            throw RsyncParseError.nostats
        }
        return stats
    }

    public func rsyncver3(stringnumbersonly: StringNumbersOnly) {
        Logger.process.debugmesseageonly("ParseRsyncOutput: rsyncver3()")
        
        var my_filestransferred: [Int]?
        var my_totaltransferredfilessize: [Double]?
        var my_totalfilesize: [Double]?
        var my_numberoffiles: Int?
        var my_numberofcreatedfiles: [Int]?
        var my_numberofdeletedfiles: [Int]?
        var my_totaldirectories: Int?
        var datatosynchronize: Bool = false
        
        // Parse files transferred
        my_filestransferred = returnIntNumber(stringnumbersonly.filestransferred[0])
        if my_filestransferred?.isEmpty ?? true {
            addError(.invalidNumberFormat(field: "files transferred",
                                         value: stringnumbersonly.filestransferred[0]))
            return
        }
        
        // Parse transferred file size
        my_totaltransferredfilessize = returnDoubleNumber(stringnumbersonly.totaltransferredfilessize[0])
        if my_totaltransferredfilessize?.isEmpty ?? true {
            addError(.invalidNumberFormat(field: "total transferred file size",
                                         value: stringnumbersonly.totaltransferredfilessize[0]))
            return
        }
        
        // Parse total file size
        my_totalfilesize = returnDoubleNumber(stringnumbersonly.totalfilesize[0])
        if my_totalfilesize?.isEmpty ?? true {
            addError(.invalidNumberFormat(field: "total file size",
                                         value: stringnumbersonly.totalfilesize[0]))
            return
        }
        
        // Parse number of files and directories
        let tempfiles = returnIntNumber(stringnumbersonly.numberoffiles[0])
        if tempfiles.count > 1 {
            my_numberoffiles = tempfiles[1]
        } else {
            my_numberoffiles = 0
            addWarning("Could not parse regular files count from: '\(stringnumbersonly.numberoffiles[0])'")
        }
        
        let directories = returnIntNumber(stringnumbersonly.numberoffiles[0])
        if directories.count > 2 {
            my_totaldirectories = directories[2]
        } else {
            my_totaldirectories = 0
            addWarning("Could not parse directories count from: '\(stringnumbersonly.numberoffiles[0])'")
        }
        
        // Parse created files
        my_numberofcreatedfiles = returnIntNumber(stringnumbersonly.numberofcreatedfiles[0])
        if my_numberofcreatedfiles?.isEmpty ?? true {
            addError(.invalidNumberFormat(field: "number of created files",
                                         value: stringnumbersonly.numberofcreatedfiles[0]))
            return
        }
        
        // Parse deleted files
        my_numberofdeletedfiles = returnIntNumber(stringnumbersonly.numberofdeletedfiles[0])
        if my_numberofdeletedfiles?.isEmpty ?? true {
            addError(.invalidNumberFormat(field: "number of deleted files",
                                         value: stringnumbersonly.numberofdeletedfiles[0]))
            return
        }

        // Determine if data needs synchronization
        if let my_filestransferred, my_filestransferred[0] > 0 {
            datatosynchronize = true
        }
        
        if let my_numberofcreatedfiles, my_numberofcreatedfiles[0] > 0 {
            datatosynchronize = true
        }
        
        if let my_numberofdeletedfiles, my_numberofdeletedfiles[0] > 0 {
            datatosynchronize = true
        }

        numbersonly = NumbersOnly(numberoffiles: my_numberoffiles ?? 0,
                                  totaldirectories: my_totaldirectories ?? 0,
                                  totalfilesize: my_totalfilesize?[0] ?? 0,
                                  filestransferred: my_filestransferred?[0] ?? 0,
                                  totaltransferredfilessize: my_totaltransferredfilessize?[0] ?? 0,
                                  numberofcreatedfiles: my_numberofcreatedfiles?[0] ?? 0,
                                  numberofdeletedfiles: my_numberofdeletedfiles?[0] ?? 0,
                                  datatosynchronize: datatosynchronize)
        
        if let numbersonly {
            do {
                stats = try calculateStats(true, stringnumbersonly: stringnumbersonly, numbersonly: numbersonly)
            } catch {
                addError(error as? RsyncParseError ?? .invalidOutputFormat("Unknown error calculating stats"))
            }
        }
    }

    public func rsyncver2(stringnumbersonly: StringNumbersOnly) {
        Logger.process.debugmesseageonly("ParseRsyncOutput: rsyncver2()")
        
        var my_filestransferred: [Int]?
        var my_totaltransferredfilessize: [Double]?
        var my_totalfilesize: [Double]?
        var my_numberoffiles: [Int]?
        var datatosynchronize: Bool = false
        
        // Parse files transferred
        my_filestransferred = returnIntNumber(stringnumbersonly.filestransferred[0])
        if my_filestransferred?.isEmpty ?? true {
            addError(.invalidNumberFormat(field: "files transferred",
                                         value: stringnumbersonly.filestransferred[0]))
            return
        }
        
        // Parse transferred file size
        my_totaltransferredfilessize = returnDoubleNumber(stringnumbersonly.totaltransferredfilessize[0])
        if my_totaltransferredfilessize?.isEmpty ?? true {
            addError(.invalidNumberFormat(field: "total transferred file size",
                                         value: stringnumbersonly.totaltransferredfilessize[0]))
            return
        }
        
        // Parse total file size
        my_totalfilesize = returnDoubleNumber(stringnumbersonly.totalfilesize[0])
        if my_totalfilesize?.isEmpty ?? true {
            addError(.invalidNumberFormat(field: "total file size",
                                         value: stringnumbersonly.totalfilesize[0]))
            return
        }
        
        // Parse number of files
        my_numberoffiles = returnIntNumber(stringnumbersonly.numberoffiles[0])
        if my_numberoffiles?.isEmpty ?? true {
            addError(.invalidNumberFormat(field: "number of files",
                                         value: stringnumbersonly.numberoffiles[0]))
            return
        }

        if let my_filestransferred, my_filestransferred[0] > 0 {
            datatosynchronize = true
        }
        
        numbersonly = NumbersOnly(numberoffiles: my_numberoffiles?[0] ?? 0,
                                  totaldirectories: 0,
                                  totalfilesize: my_totalfilesize?[0] ?? 0,
                                  filestransferred: my_filestransferred?[0] ?? 0,
                                  totaltransferredfilessize: my_totaltransferredfilessize?[0] ?? 0,
                                  numberofcreatedfiles: 0,
                                  numberofdeletedfiles: 0,
                                  datatosynchronize: datatosynchronize)
       
        if let numbersonly {
            do {
                stats = try calculateStats(false, stringnumbersonly: stringnumbersonly, numbersonly: numbersonly)
            } catch {
                addError(error as? RsyncParseError ?? .invalidOutputFormat("Unknown error calculating stats"))
            }
        }
    }

    private func calculateStats(_ version3ofrsync: Bool,
                               stringnumbersonly: StringNumbersOnly,
                               numbersonly: NumbersOnly) throws -> String {
        
        Logger.process.debugmesseageonly("ParseRsyncOutput: calculateStats()")
        
        var parts: [String]?
        if version3ofrsync {
            let newmessage = stringnumbersonly.result.replacingOccurrences(of: ",", with: "")
            parts = newmessage.components(separatedBy: " ")
        } else {
            parts = stringnumbersonly.result.components(separatedBy: " ")
        }
        
        guard let parts = parts, parts.count > 9 else {
            throw RsyncParseError.incompleteSummaryLine
        }
        
        guard let bytesTotalsent = Double(parts[1]) else {
            throw RsyncParseError.invalidNumberFormat(field: "sent bytes", value: parts[1])
        }
        
        guard let bytesSec = Double(parts[8]) else {
            throw RsyncParseError.invalidNumberFormat(field: "bytes/sec", value: parts[8])
        }
        
        guard bytesSec > 0 else {
            throw RsyncParseError.divisionByZero
        }
        
        let seconds = bytesTotalsent / bytesSec
        let bytesTotal = bytesTotalsent

        return String(numbersonly.filestransferred) + " files : " +
            String(format: "%.2f", (bytesTotal / 1000) / 1000) +
            " MB in " + String(format: "%.2f", seconds) + " seconds"
    }
    
    public func returnIntNumber(_ input: String) -> [Int] {
        var numbers: [Int] = []
        let str = input.replacingOccurrences(of: ",", with: "")
        let stringArray = str.components(separatedBy: CharacterSet.decimalDigits.inverted).compactMap { $0.isEmpty == true ? nil : $0 }
        
        for item in stringArray where item.isEmpty == false {
            if let number = Int(item) {
                numbers.append(number)
            }
        }
        
        if numbers.count == 0 {
            return [0]
        } else {
            return numbers
        }
    }
    
    public func returnDoubleNumber(_ input: String) -> [Double] {
        var numbers: [Double] = []
        let str = input.replacingOccurrences(of: ",", with: "")
        let stringArray = str.components(separatedBy: CharacterSet.decimalDigits.inverted).compactMap { $0.isEmpty == true ? nil : $0 }
        
        for item in stringArray where item.isEmpty == false {
            if let number = Double(item) {
                numbers.append(number)
            }
        }
        
        if numbers.count == 0 {
            return [0]
        } else {
            return numbers
        }
    }

    public init(_ preparedoutputfromrsync: [String], _ rsyncversion: VersionRsync) {
        var result = ""
        
        // Validate input
        guard !preparedoutputfromrsync.isEmpty else {
            addError(.invalidOutputFormat("Empty rsync output"))
            return
        }
        
        // Getting the summarized output
        let resultRsync = preparedoutputfromrsync.filter {
            $0.contains("sent") && $0.contains("received") && $0.contains("bytes/sec")
        }
        
        if resultRsync.count == 1 {
            result = resultRsync[0]
        } else if resultRsync.isEmpty {
            addError(.missingRequiredField("sent/received/bytes summary line"))
            return  // Stop processing if summary line is missing
        } else {
            addWarning("Multiple summary lines found, using first one")
            result = resultRsync[0]
        }
        
        // Extract fields
        let numberoffiles = preparedoutputfromrsync.compactMap {
            $0.contains("Number of files:") ? $0 : nil
        }
        let filestransferred = preparedoutputfromrsync.compactMap {
            $0.contains("files transferred:") ? $0 : nil
        }
        let totalfilesize = preparedoutputfromrsync.compactMap {
            $0.contains("Total file size:") ? $0 : nil
        }
        let totaltransferredfilessize = preparedoutputfromrsync.compactMap {
            $0.contains("Total transferred file size:") ? $0 : nil
        }
        let numberofcreatedfiles = preparedoutputfromrsync.compactMap {
            $0.contains("Number of created files:") ? $0 : nil
        }
        let numberofdeletedfiles = preparedoutputfromrsync.compactMap {
            $0.contains("Number of deleted files:") ? $0 : nil
        }
        
        switch rsyncversion {
        case .ver3:
            Logger.process.debugmesseageonly("ParseRsyncOutput: init() version 3 of rsync")
            // Validate v3 requirements
            var missingFields: [String] = []
            if totaltransferredfilessize.count != 1 { missingFields.append("Total transferred file size") }
            if totalfilesize.count != 1 { missingFields.append("Total file size") }
            if numberoffiles.count != 1 { missingFields.append("Number of files") }
            if filestransferred.count != 1 { missingFields.append("Number of files transferred") }
            if numberofcreatedfiles.count != 1 { missingFields.append("Number of created files") }
            if numberofdeletedfiles.count != 1 { missingFields.append("Number of deleted files") }
            
            if !missingFields.isEmpty {
                addError(.missingRequiredField("v3 fields: " + missingFields.joined(separator: ", ")))
                return
            }
            
            stringnumbersonly = StringNumbersOnly(result: result,
                                                  filestransferred: filestransferred,
                                                  totaltransferredfilessize: totaltransferredfilessize,
                                                  totalfilesize: totalfilesize,
                                                  numberoffiles: numberoffiles,
                                                  numberofcreatedfiles: numberofcreatedfiles,
                                                  numberofdeletedfiles: numberofdeletedfiles)
            
            if let stringnumbersonly {
                rsyncver3(stringnumbersonly: stringnumbersonly)
            }
        case .openrsync:
            Logger.process.debugmesseageonly("ParseRsyncOutput: init() version 2 or openrsync")
            // Validate v2 requirements
            var missingFields: [String] = []
            if filestransferred.count != 1 { missingFields.append("Number of files transferred") }
            if totaltransferredfilessize.count != 1 { missingFields.append("Total transferred file size") }
            if totalfilesize.count != 1 { missingFields.append("Total file size") }
            if numberoffiles.count != 1 { missingFields.append("Number of files") }
            
            if !missingFields.isEmpty {
                addError(.missingRequiredField("v2 fields: " + missingFields.joined(separator: ", ")))
                return
            }
            
            stringnumbersonly = StringNumbersOnly(result: result,
                                                  filestransferred: filestransferred,
                                                  totaltransferredfilessize: totaltransferredfilessize,
                                                  totalfilesize: totalfilesize,
                                                  numberoffiles: numberoffiles,
                                                  numberofcreatedfiles: numberofcreatedfiles,
                                                  numberofdeletedfiles: numberofdeletedfiles)
            
            if let stringnumbersonly {
                rsyncver2(stringnumbersonly: stringnumbersonly)
            }
        }
    }
}
