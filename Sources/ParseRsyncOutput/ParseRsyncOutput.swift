// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

@MainActor
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

@MainActor
public struct StringNumbersOnly {
    // Second last String in Array rsync output of how much in what time
    public var result: String
    // ver 3.x - [Number of regular files transferred: 24]
    // ver 2.x - [Number of files transferred: 24]
    public var filestransferred: [String]
    // ver 3.x - [Total transferred file size: 278,642 bytes]
    // ver 2.x - [Total transferred file size: 278197 bytes]
    public var totaltransferredfilessize: [String]
    // ver 3.x - [Total file size: 1,016,382,148 bytes]
    // ver 2.x - [Total file size: 1016381703 bytes]
    public var totalfilesize: [String]
    // ver 3.x - [Number of files: 3,956 (reg: 3,197, dir: 758, link: 1)]
    // ver 2.x - [Number of files: 3956]
    public var numberoffiles: [String]
    // New files
    public var numberofcreatedfiles: [String]
    // Delete files
    public var numberofdeletedfiles: [String]
}

@MainActor
public final class ParseRsyncOutput {
    public var stringnumbersonly: StringNumbersOnly?
    public var numbersonly: NumbersOnly?
    public var stats: String?

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

    public func rsyncver3(stringnumbersonly: StringNumbersOnly) {
       
        var my_filestransferred: [Int]?
        var my_totaltransferredfilessize: [Double]?
        var my_totalfilesize: [Double]?
        var my_numberoffiles: Int?
        var my_numberofcreatedfiles: [Int]?
        var my_numberofdeletedfiles: [Int]?
        var my_totaldirectories: Int?
        var datatosynchronize: Bool = false
        
        // returnIntNumber and returnDoubleNumber always returns at least one value. If it fails
        // it returns a [0]
        
        my_filestransferred = returnIntNumber(stringnumbersonly.filestransferred[0])
        my_totaltransferredfilessize = returnDoubleNumber(stringnumbersonly.totaltransferredfilessize[0])
        my_totalfilesize = returnDoubleNumber(stringnumbersonly.totalfilesize[0])
        let tempfiles = returnIntNumber(stringnumbersonly.numberoffiles[0])
        if tempfiles.count > 1 {
            my_numberoffiles = returnIntNumber(stringnumbersonly.numberoffiles[0])[1]
        } else {
            my_numberoffiles = 0
        }
        my_numberofcreatedfiles = returnIntNumber(stringnumbersonly.numberofcreatedfiles[0])
        my_numberofdeletedfiles = returnIntNumber(stringnumbersonly.numberofdeletedfiles[0])
        let directories = returnIntNumber(stringnumbersonly.numberoffiles[0])
        if directories.count > 2 {
            my_totaldirectories = returnIntNumber(stringnumbersonly.numberoffiles[0])[2]
        } else {
            my_totaldirectories = 0
        }
        guard my_filestransferred?.count ?? 0 > 0 else { return }
        guard my_totaltransferredfilessize?.count ?? 0 > 0 else { return }
        guard my_totalfilesize?.count ?? 0 > 0 else { return }
        guard my_numberoffiles != nil else { return }
        guard my_numberofcreatedfiles?.count ?? 0 > 0 else { return }
        guard my_numberofdeletedfiles?.count ?? 0 > 0 else { return }
        guard my_totaldirectories != nil else { return }

        if let my_filestransferred, my_filestransferred[0] > 0  {
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
            stats = stats(true, stringnumbersonly: stringnumbersonly, numbersonly: numbersonly)
        }
    }

    public func rsyncver2(stringnumbersonly: StringNumbersOnly) {
        
        var my_filestransferred: [Int]?
        var my_totaltransferredfilessize: [Double]?
        var my_totalfilesize: [Double]?
        var my_numberoffiles: [Int]?
        var datatosynchronize: Bool = false
        
        // returnIntNumber and returnDoubleNumber always returns at least one value. If it fails
        // it returns a [0]
        
        my_filestransferred = returnIntNumber(stringnumbersonly.filestransferred[0])
        my_totaltransferredfilessize = returnDoubleNumber(stringnumbersonly.totaltransferredfilessize[0])
        my_totalfilesize = returnDoubleNumber(stringnumbersonly.totalfilesize[0])
        my_numberoffiles = returnIntNumber(stringnumbersonly.numberoffiles[0])
        
        guard my_filestransferred?.count ?? 0 > 0 else { return }
        guard my_totaltransferredfilessize?.count ?? 0 > 0 else { return }
        guard my_totalfilesize?.count ?? 0 > 0 else { return }
        guard my_numberoffiles?.count ?? 0 > 0 else { return }

        if let my_filestransferred, my_filestransferred[0] > 0  {
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
            stats = stats(true, stringnumbersonly: stringnumbersonly, numbersonly: numbersonly)
        }
    }

    public func stats(_ version3ofrsync: Bool,
                      stringnumbersonly: StringNumbersOnly,
                      numbersonly: NumbersOnly) -> String {
        var parts: [String]?
        if version3ofrsync {
            let newmessage = stringnumbersonly.result.replacingOccurrences(of: ",", with: "")
            parts = newmessage.components(separatedBy: " ")
        } else {
            parts = stringnumbersonly.result.components(separatedBy: " ")
        }
        var bytesTotal: Double = 0
        var bytesSec: Double = 0
        var seconds: Double = 0
        guard (parts?.count ?? 0) > 9 else { return "Could not set total" }
        // Sent and received
        let bytesTotalsent = Double(parts?[1] ?? "0") ?? 0
        bytesSec = Double(parts?[8] ?? "0") ?? 0
        seconds = bytesTotalsent / bytesSec
        bytesTotal = bytesTotalsent

        return String(numbersonly.filestransferred) + " files : " +
            String(format: "%.2f", (bytesTotal / 1000) / 1000) +
            " MB in " + String(format: "%.2f", seconds) + " seconds"
    }
    
/*
    public func returnNumber<T>( _ input: String) -> [T]? {
        var numbers: [T] = []
        let str = input.replacingOccurrences(of: ",", with: "")
        let stringArray = str.components(separatedBy: CharacterSet.decimalDigits.inverted)
        for item in stringArray where item.isEmpty == false {
            if let number = (item) as? T {
                numbers.append(number)
            }
        }
        if numbers.count == 0 {
            return nil
        } else {
            return numbers
        }
       
    }
    
*/
    public func returnIntNumber( _ input: String) -> [Int] {
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
    
    public func returnDoubleNumber( _ input: String) -> [Double] {
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

    public init(_ preparedoutputfromrsync: [String], _ version3ofrsync: Bool) {
        var result = ""
        
        // Getting the summarized output from suboutput.
        let resultRsync = preparedoutputfromrsync.filter { $0.contains("sent") && $0.contains("received") && $0.contains("bytes/sec") }
        if resultRsync.count == 1 {
            result = resultRsync[0]
        } else {
            result = "Could not set total"
        }
        // ver 3.x - [Number of files: 3,956 (reg: 3,197, dir: 758, link: 1)]
        // ver 2.x - [Number of files: 3956]
        let numberoffiles = preparedoutputfromrsync.compactMap {
            $0.contains("Number of files:") ? $0 : nil
        }
        // ver 3.x - [Number of regular files transferred: 24]
        // ver 2.x - [Number of files transferred: 24]
        let filestransferred = preparedoutputfromrsync.compactMap {
            $0.contains("files transferred:") ? $0 : nil
        }
        // ver 3.x - [Total file size: 1,016,382,148 bytes]
        // ver 2.x - [Total file size: 1016381703 bytes]
        let totalfilesize = preparedoutputfromrsync.compactMap {
            $0.contains("Total file size:") ? $0 : nil
        }
        // ver 3.x - [Total transferred file size: 278,642 bytes]
        // ver 2.x - [Total transferred file size: 278197 bytes]
        let totaltransferredfilessize = preparedoutputfromrsync.compactMap {
            $0.contains("Total transferred file size:") ? $0 : nil
        }
        // ver 3.x - [Number of created files: 7,191 (reg: 6,846, dir: 345)]
        // ver 3.x only
        let numberofcreatedfiles = preparedoutputfromrsync.compactMap {
            $0.contains("Number of created files:") ? $0 : nil
        }
        // ver 3.x - [Number of deleted files: 0]
        // ver 3.x only
        let numberofdeletedfiles = preparedoutputfromrsync.compactMap {
            $0.contains("Number of deleted files:") ? $0 : nil
        }
        
        if filestransferred.count == 1,
           totaltransferredfilessize.count == 1,
           totalfilesize.count == 1,
           numberoffiles.count == 1,
           version3ofrsync == false {
            
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
        } else if totaltransferredfilessize.count == 1,
                  totalfilesize.count == 1,
                  numberoffiles.count == 1,
                  filestransferred.count == 1,
                  numberofcreatedfiles.count == 1,
                  numberofdeletedfiles.count == 1,
                  version3ofrsync {
            
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
        }
    }
}

// swiftlint:enable cyclomatic_complexity

