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
    public var resultRsync: String
    // Temporary numbers
    // ver 3.x - [Number of regular files transferred: 24]
    // ver 2.x - [Number of files transferred: 24]
    public var files: [String]
    // ver 3.x - [Total transferred file size: 278,642 bytes]
    // ver 2.x - [Total transferred file size: 278197 bytes]
    public var filesSize: [String]
    // ver 3.x - [Total file size: 1,016,382,148 bytes]
    // ver 2.x - [Total file size: 1016381703 bytes]
    public var totfileSize: [String]
    // ver 3.x - [Number of files: 3,956 (reg: 3,197, dir: 758, link: 1)]
    // ver 2.x - [Number of files: 3956]
    public var totfilesNum: [String]
    // New files
    public var new: [String]
    // Delete files
    public var delete: [String]
}

@MainActor
public final class ParseRsyncOutput {
    public var stringnumbersonly: StringNumbersOnly?
    public var numbersonly: NumbersOnly?
    public var count: Int?
    public var stats: String?

    public func rsyncver3(stringnumbersonly: StringNumbersOnly) {
        var totNum: Int?
        var totDir: Int?
        var totNumSize: Double?
        var transferNum: Int?
        var transferNumSize: Double?
        var newfiles: Int?
        var deletefiles: Int?

        guard stringnumbersonly.files.count > 0 else { return }
        guard stringnumbersonly.filesSize.count > 0 else { return }
        guard stringnumbersonly.totfilesNum.count > 0 else { return }
        guard stringnumbersonly.totfileSize.count > 0 else { return }
        guard stringnumbersonly.new.count > 0 else { return }
        guard stringnumbersonly.delete.count > 0 else { return }
        // Ver3 of rsync adds "," as 1000 mark, must replace it and then split numbers into components
        let filesPart = stringnumbersonly.files[0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        let filesPartSize = stringnumbersonly.filesSize[0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        let totfilesPart = stringnumbersonly.totfilesNum[0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        let totfilesPartSize = stringnumbersonly.totfileSize[0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        let newPart = stringnumbersonly.new[0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        let deletePart = stringnumbersonly.delete[0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        // ["Number", "of", "regular", "files", "transferred:", "24"]
        // ["Total", "transferred", "file", "size:", "281653", "bytes"]
        // ["Number", "of", "files:", "3956", "(reg:", "3197", "dir:", "758", "link:", "1)"]
        // ["Total", "file", "size:", "1016385159", "bytes"]
        // ["Number" "of" "created" "files:" "0"]
        // ["Number" "of" "deleted" "files:" "0"]
        if filesPart.count > 5 { transferNum = Int(filesPart[5]) } else { transferNum = 0 }
        if filesPartSize.count > 4 { transferNumSize = Double(filesPartSize[4]) } else { transferNumSize = 0 }
        if totfilesPart.count > 5 { totNum = Int(totfilesPart[5]) } else { totNum = 0 }
        if totfilesPartSize.count > 3 { totNumSize = Double(totfilesPartSize[3]) } else { totNumSize = 0 }
        if totfilesPart.count > 7 {
            totDir = Int(totfilesPart[7].replacingOccurrences(of: ")", with: ""))
        } else {
            totDir = 0
        }
        if newPart.count > 4 { newfiles = Int(newPart[4]) } else { newfiles = 0 }
        if deletePart.count > 4 { deletefiles = Int(deletePart[4]) } else { deletefiles = 0 }
        numbersonly = NumbersOnly(totNum: totNum ?? 0, totDir: totDir ?? 0, totNumSize: totNumSize ?? 0, transferNum: transferNum ?? 0, transferNumSize: transferNumSize ?? 0, newfiles: newfiles ?? 0, deletefiles: deletefiles ?? 0)
        if let numbersonly {
            stats = stats(true, stringnumbersonly: stringnumbersonly, numbersonly: numbersonly)
        }
    }

    public func rsyncver2(stringnumbersonly: StringNumbersOnly) {
        var totNum: Int?
        var totNumSize: Double?
        var transferNum: Int?
        var transferNumSize: Double?

        guard stringnumbersonly.files.count > 0 else { return }
        guard stringnumbersonly.filesSize.count > 0 else { return }
        guard stringnumbersonly.totfilesNum.count > 0 else { return }
        guard stringnumbersonly.totfileSize.count > 0 else { return }
        let filesPart = stringnumbersonly.files[0].components(separatedBy: " ")
        let filesPartSize = stringnumbersonly.filesSize[0].components(separatedBy: " ")
        let totfilesPart = stringnumbersonly.totfilesNum[0].components(separatedBy: " ")
        let totfilesPartSize = stringnumbersonly.totfileSize[0].components(separatedBy: " ")
        // ["Number", "of", "files", "transferred:", "24"]
        // ["Total", "transferred", "file", "size:", "281579", "bytes"]
        // ["Number", "of", "files:", "3956"]
        // ["Total", "file", "size:", "1016385085", "bytes"]
        if filesPart.count > 4 { transferNum = Int(filesPart[4]) } else { transferNum = 0 }
        if filesPartSize.count > 4 { transferNumSize = Double(filesPartSize[4]) } else { transferNumSize = 0 }
        if totfilesPart.count > 3 { totNum = Int(totfilesPart[3]) } else { totNum = 0 }
        if totfilesPartSize.count > 3 { totNumSize = Double(totfilesPartSize[3]) } else { totNumSize = 0 }
        numbersonly = NumbersOnly(totNum: totNum ?? 0, totDir: 0, totNumSize: totNumSize ?? 0, transferNum: transferNum ?? 0, transferNumSize: transferNumSize ?? 0, newfiles: 0, deletefiles: 0)
        if let numbersonly {
            stats = stats(false, stringnumbersonly: stringnumbersonly, numbersonly: numbersonly)
        }
    }

    public func stats(_ version3ofrsync: Bool, stringnumbersonly: StringNumbersOnly, numbersonly: NumbersOnly) -> String {
        let numberOfFiles = String(numbersonly.transferNum)
        var parts: [String]?
        if version3ofrsync {
            // ["sent", "409687", "bytes", "", "received", "5331", "bytes", "", "830036.00", "bytes/sec"]
            let newmessage = stringnumbersonly.resultRsync.replacingOccurrences(of: ",", with: "")
            parts = newmessage.components(separatedBy: " ")
        } else {
            // ["sent", "262826", "bytes", "", "received", "2248", "bytes", "", "58905.33", "bytes/sec"]
            parts = stringnumbersonly.resultRsync.components(separatedBy: " ")
        }
        var bytesTotal: Double = 0
        var bytesSec: Double = 0
        var seconds: Double = 0
        guard (parts?.count ?? 0) > 9 else { return "0" }
        // Sent and received
        let bytesTotalsent = Double(parts?[1] ?? "0") ?? 0
        let bytesTotalreceived = Double(parts?[5] ?? "0") ?? 0
        if bytesTotalsent > bytesTotalreceived {
            // backup task
            // let result = resultsent! + parts![8] + " b/sec"
            bytesSec = Double(parts?[8] ?? "0") ?? 0
            seconds = bytesTotalsent / bytesSec
            bytesTotal = bytesTotalsent
        } else {
            // restore task
            // let result = resultreceived! + parts![8] + " b/sec"
            bytesSec = Double(parts?[8] ?? "0") ?? 0
            seconds = bytesTotalreceived / bytesSec
            bytesTotal = bytesTotalreceived
        }
        if numberOfFiles == "0" {
            return String(count ?? 0) + " files : " +
                String(format: "%.2f", (bytesTotal / 1000) / 1000) +
                " MB in " + String(format: "%.2f", seconds) + " seconds"
        } else {
            return numberOfFiles + " files : " +
                String(format: "%.2f", (bytesTotal / 1000) / 1000) +
                " MB in " + String(format: "%.2f", seconds) + " seconds"
        }
    }

    // Input is TrimOutputFromRsync(myoutput).trimmeddata
    public init(_ output: [String], _ version3ofrsync: Bool) {
        var resultRsync = ""
        guard output.count > 0 else { return }

        count = output.count

        // Getting the summarized output from output.
        if output.count > 2 { resultRsync = output[output.count - 2] }
        let files = output.filter { $0.contains("files transferred:") }
        // ver 3.x - [Number of regular files transferred: 24]
        // ver 2.x - [Number of files transferred: 24]
        let filesSize = output.filter { $0.contains("Total transferred file size:") }
        // ver 3.x - [Total transferred file size: 278,642 bytes]
        // ver 2.x - [Total transferred file size: 278197 bytes]
        let totfileSize = output.filter { $0.contains("Total file size:") }
        // ver 3.x - [Total file size: 1,016,382,148 bytes]
        // ver 2.x - [Total file size: 1016381703 bytes]
        let totfilesNum = output.filter { $0.contains("Number of files:") }
        // ver 3.x - [Number of files: 3,956 (reg: 3,197, dir: 758, link: 1)]
        // ver 2.x - [Number of files: 3956]
        // New files
        let new = output.filter { $0.contains("Number of created files:") }
        // Delete files
        let delete = output.filter { $0.contains("Number of deleted files:") }

        stringnumbersonly = StringNumbersOnly(resultRsync: resultRsync,
                                              files: files,
                                              filesSize: filesSize,
                                              totfileSize: totfileSize,
                                              totfilesNum: totfilesNum,
                                              new: new,
                                              delete: delete)
        if files.count == 1, filesSize.count == 1, totfileSize.count == 1, totfilesNum.count == 1 {
            if version3ofrsync, let stringnumbersonly {
                rsyncver3(stringnumbersonly: stringnumbersonly)
            } else if let stringnumbersonly {
                rsyncver2(stringnumbersonly: stringnumbersonly)
            }
        }
    }
}

// swiftlint:enable cyclomatic_complexity
