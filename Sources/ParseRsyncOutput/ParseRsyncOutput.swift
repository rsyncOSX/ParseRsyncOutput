// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

@MainActor
public struct NumbersOnly {
    public var totNum: Int
    public var totDir: Int
    public var totNumSize: Double
    public var transferNum: Int
    public var transferNumSize: Double
    public var newfiles: Int
    public var deletefiles: Int
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
    public var count: Int?
    public var stats: String?

    public var formatted_transferredNumber: String {
        NumberFormatter.localizedString(from: NSNumber(value: numbersonly?.transferNum ?? 0), number: NumberFormatter.Style.none)
    }
    public var formatted_totalNumber: String {
        NumberFormatter.localizedString(from: NSNumber(value: numbersonly?.totNum ?? 0), number: NumberFormatter.Style.decimal)
    }
    public var formatted_totalNumberSizebytes: String {
        NumberFormatter.localizedString(from: NSNumber(value: numbersonly?.totNumSize ?? 0), number: NumberFormatter.Style.decimal)
    }
    public var formatted_totalDirs: String {
        NumberFormatter.localizedString(from: NSNumber(value: numbersonly?.totDir ?? 0), number: NumberFormatter.Style.decimal)
    }
    public var formatted_totalNumber_totalDirs: String {
        NumberFormatter.localizedString(from: NSNumber(value: (numbersonly?.totDir ?? 0) + (numbersonly?.totNum ?? 0)), number: NumberFormatter.Style.decimal)
    }
    public var formatted_newfiles: String {
        NumberFormatter.localizedString(from: NSNumber(value: numbersonly?.newfiles ?? 0), number: NumberFormatter.Style.none)
    }
    public var formatted_deletefiles: String {
        NumberFormatter.localizedString(from: NSNumber(value: numbersonly?.deletefiles ?? 0), number: NumberFormatter.Style.none)
    }

    public func rsyncver3(stringnumbersonly: StringNumbersOnly) {
        var totNum: Int?
        var totDir: Int?
        var totNumSize: Double?
        var transferNum: Int?
        var transferNumSize: Double?
        var newfiles: Int?
        var deletefiles: Int?

        guard stringnumbersonly.filestransferred.count > 0 else { return }
        guard stringnumbersonly.totaltransferredfilessize.count > 0 else { return }
        guard stringnumbersonly.totalfilesize.count > 0 else { return }
        guard stringnumbersonly.numberoffiles.count > 0 else { return }
        
        guard stringnumbersonly.numberofcreatedfiles.count > 0 else { return }
        guard stringnumbersonly.numberofdeletedfiles.count > 0 else { return }
        
        // Ver3 of rsync adds "," as 1000 mark, must replace it and then split numbers into components
        let filestransferred = stringnumbersonly.filestransferred[0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        let totaltransferredfilessize = stringnumbersonly.totaltransferredfilessize[0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        let totalfilesize = stringnumbersonly.totalfilesize[0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        let numberoffiles = stringnumbersonly.numberoffiles[0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        let numberofcreatedfiles = stringnumbersonly.numberofcreatedfiles[0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        let numberofdeletedfiles = stringnumbersonly.numberofdeletedfiles[0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        
        // (1) ["Number", "of", "regular", "files", "transferred:", "6,846"]
        // (2) ["Total", "transferred", "file", "size:", "24,788,299", "bytes"]
        // (3) ["Number", "of", "files:", "7,192", "(reg:", "6,846", "dir:", "346", "link:", "1)"]
        // (4) ["Total", "file", "size:", "24,788,299", "bytes"]
        // The
        // (5) ["Number", "of", "created", "files:", "7,191", "(reg:", "6,846", "dir:", "346)"]
        // (6) ["Number", "of", "deleted", "files:", "0"]
        /* The parantes in "346)" is removed below
         (3) Number of files: 7,192 (reg: 6,846, dir: 346)
         (5) Number of created files: 7,191 (reg: 6,846, dir: 345)
         (6) Number of deleted files: 0
         (1) Number of regular files transferred: 6,846
         (4) Total file size: 24,788,299 bytes
         (2) Total transferred file size: 24,788,299 bytes
         Literal data: 0 bytes
         Matched data: 0 bytes
         File list size: 0
         File list generation time: 0.003 seconds
         File list transfer time: 0.000 seconds
         Total bytes sent: 394,304
         Total bytes received: 22,226
         */
        if filestransferred.count > 5 { transferNum = Int(filestransferred[5]) } else { transferNum = 0 }
        if totaltransferredfilessize.count > 4 { transferNumSize = Double(totaltransferredfilessize[4]) } else { transferNumSize = 0 }
        if totalfilesize.count > 3 { totNumSize = Double(totalfilesize[3]) } else { totNumSize = 0 }
        if numberoffiles.count > 5 { totNum = Int(numberoffiles[5]) } else { totNum = 0 }
        if numberoffiles.count > 7 {
            totDir = Int(numberoffiles[7].replacingOccurrences(of: ")", with: ""))
        } else {
            totDir = 0
        }
        if numberofcreatedfiles.count > 4 { newfiles = Int(numberofcreatedfiles[4]) } else { newfiles = 0 }
        if numberofdeletedfiles.count > 4 { deletefiles = Int(numberofdeletedfiles[4]) } else { deletefiles = 0 }
        numbersonly = NumbersOnly(totNum: totNum ?? 0,
                                  totDir: totDir ?? 0,
                                  totNumSize: totNumSize ?? 0,
                                  transferNum: transferNum ?? 0,
                                  transferNumSize: transferNumSize ?? 0,
                                  newfiles: newfiles ?? 0,
                                  deletefiles: deletefiles ?? 0)
        if let numbersonly {
            stats = stats(true, stringnumbersonly: stringnumbersonly, numbersonly: numbersonly)
        }
    }

    public func rsyncver2(stringnumbersonly: StringNumbersOnly) {
        var totNum: Int?
        var totNumSize: Double?
        var transferNum: Int?
        var transferNumSize: Double?
        
        guard stringnumbersonly.filestransferred.count > 0 else { return }
        guard stringnumbersonly.totaltransferredfilessize.count > 0 else { return }
        guard stringnumbersonly.totalfilesize.count > 0 else { return }
        guard stringnumbersonly.numberoffiles.count > 0 else { return }
        
        let filestransferred = stringnumbersonly.filestransferred[0].components(separatedBy: " ")
        let totaltransferredfilessize = stringnumbersonly.totaltransferredfilessize[0].components(separatedBy: " ")
        let totalfilesize = stringnumbersonly.totalfilesize[0].components(separatedBy: " ")
        let numberoffiles = stringnumbersonly.numberoffiles[0].components(separatedBy: " ")
        
        // (1) ["Number", "of", "files", "transferred:", "6846"]
        // (2) ["Total", "transferred", "file", "size:", "24788299", "bytes"]
        // (3) ["Number", "of", "files:", "7192"]
        // (4) ["Total", "file", "size:", "24788299", "bytes"]
        /*
         (3) Number of files: 7192
         (1) Number of files transferred: 6846
         (4) Total file size: 24788299 bytes
         (2) Total transferred file size: 24788299 bytes
         Literal data: 0 bytes
         Matched data: 0 bytes
         File list size: 336861
         File list generation time: 0.052 seconds
         File list transfer time: 0.000 seconds
         Total bytes sent: 380178
         Total bytes received: 43172
         */
        if filestransferred.count > 4 { transferNum = Int(filestransferred[4]) } else { transferNum = 0 }
        if totaltransferredfilessize.count > 4 { transferNumSize = Double(totaltransferredfilessize[4]) } else { transferNumSize = 0 }
        if totalfilesize.count > 3 { totNumSize = Double(totalfilesize[3]) } else { totNumSize = 0 }
        if numberoffiles.count > 3 { totNum = Int(numberoffiles[3]) } else { totNum = 0 }
        
        numbersonly = NumbersOnly(totNum: totNum ?? 0,
                                  totDir: 0,
                                  totNumSize: totNumSize ?? 0,
                                  transferNum: transferNum ?? 0,
                                  transferNumSize: transferNumSize ?? 0,
                                  newfiles: 0,
                                  deletefiles: 0)
        if let numbersonly {
            stats = stats(false, stringnumbersonly: stringnumbersonly, numbersonly: numbersonly)
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

        return String(numbersonly.transferNum) + " files : " +
            String(format: "%.2f", (bytesTotal / 1000) / 1000) +
            " MB in " + String(format: "%.2f", seconds) + " seconds"
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
        let numberoffiles = preparedoutputfromrsync.filter { $0.contains("Number of files:") }
        // ver 3.x - [Number of regular files transferred: 24]
        // ver 2.x - [Number of files transferred: 24]
        let filestransferred = preparedoutputfromrsync.filter { $0.contains("files transferred:") }
        // ver 3.x - [Total file size: 1,016,382,148 bytes]
        // ver 2.x - [Total file size: 1016381703 bytes]
        let totalfilesize = preparedoutputfromrsync.filter { $0.contains("Total file size:") }
        // ver 3.x - [Total transferred file size: 278,642 bytes]
        // ver 2.x - [Total transferred file size: 278197 bytes]
        let totaltransferredfilessize = preparedoutputfromrsync.filter { $0.contains("Total transferred file size:") }
        // ver 3.x - [Number of created files: 7,191 (reg: 6,846, dir: 345)]
        // ver 3.x only
        let numberofcreatedfiles = preparedoutputfromrsync.filter { $0.contains("Number of created files:") }
        // ver 3.x - [Number of deleted files: 0]
        // ver 3.x only
        let numberofdeletedfiles = preparedoutputfromrsync.filter { $0.contains("Number of deleted files:") }

        if filestransferred.count == 1, totaltransferredfilessize.count == 1, totalfilesize.count == 1, numberoffiles.count == 1 {
            
            stringnumbersonly = StringNumbersOnly(result: result,
                                                  filestransferred: filestransferred,
                                                  totaltransferredfilessize: totaltransferredfilessize,
                                                  totalfilesize: totalfilesize,
                                                  numberoffiles: numberoffiles,
                                                  numberofcreatedfiles: numberofcreatedfiles,
                                                  numberofdeletedfiles: numberofdeletedfiles)
            if version3ofrsync, let stringnumbersonly {
                rsyncver3(stringnumbersonly: stringnumbersonly)
            } else if let stringnumbersonly {
                rsyncver2(stringnumbersonly: stringnumbersonly)
            }
        }
    }
}

// swiftlint:enable cyclomatic_complexity

/*
 (3) Number of files: 7192
 (1) Number of files transferred: 6846
 (4) Total file size: 24788299 bytes
 (2) Total transferred file size: 24788299 bytes
 Literal data: 0 bytes
 Matched data: 0 bytes
 File list size: 336861
 File list generation time: 0.052 seconds
 File list transfer time: 0.000 seconds
 Total bytes sent: 380178
 Total bytes received: 43172
 */
