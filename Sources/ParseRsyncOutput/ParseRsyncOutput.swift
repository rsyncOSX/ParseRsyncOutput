// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

@MainActor
public struct Result2 {
    public var totNum: Int
    public var totDir: Int
    public var totNumSize: Double
    public var transferNum: Int
    public var transferNumSize: Double
    public var newfiles: Int
    public var deletefiles: Int
}

@MainActor
public struct Result {
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
    public var result: Result?
    public var result2: Result2?

    public func rsyncver3(result: Result) {
        var totNum: Int?
        var totDir: Int?
        var totNumSize: Double?
        var transferNum: Int?
        var transferNumSize: Double?
        var newfiles: Int?
        var deletefiles: Int?

        guard result.files.count > 0 else { return }
        guard result.filesSize.count > 0 else { return }
        guard result.totfilesNum.count > 0 else { return }
        guard result.totfileSize.count > 0 else { return }
        guard result.new.count > 0 else { return }
        guard result.delete.count > 0 else { return }
        // Ver3 of rsync adds "," as 1000 mark, must replace it and then split numbers into components
        let filesPart = result.files[0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        let filesPartSize = result.filesSize[0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        let totfilesPart = result.totfilesNum[0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        let totfilesPartSize = result.totfileSize[0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        let newPart = result.new[0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        let deletePart = result.delete[0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
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
        result2 = Result2(totNum: totNum ?? 0, totDir: totDir ?? 0, totNumSize: totNumSize ?? 0, transferNum: transferNum ?? 0, transferNumSize: transferNumSize ?? 0, newfiles: newfiles ?? 0, deletefiles: deletefiles ?? 0)
    }

    public func rsyncver2(result: Result) {
        var totNum: Int?
        var totNumSize: Double?
        var transferNum: Int?
        var transferNumSize: Double?

        guard result.files.count > 0 else { return }
        guard result.filesSize.count > 0 else { return }
        guard result.totfilesNum.count > 0 else { return }
        guard result.totfileSize.count > 0 else { return }
        let filesPart = result.files[0].components(separatedBy: " ")
        let filesPartSize = result.filesSize[0].components(separatedBy: " ")
        let totfilesPart = result.totfilesNum[0].components(separatedBy: " ")
        let totfilesPartSize = result.totfileSize[0].components(separatedBy: " ")
        // ["Number", "of", "files", "transferred:", "24"]
        // ["Total", "transferred", "file", "size:", "281579", "bytes"]
        // ["Number", "of", "files:", "3956"]
        // ["Total", "file", "size:", "1016385085", "bytes"]
        if filesPart.count > 4 { transferNum = Int(filesPart[4]) } else { transferNum = 0 }
        if filesPartSize.count > 4 { transferNumSize = Double(filesPartSize[4]) } else { transferNumSize = 0 }
        if totfilesPart.count > 3 { totNum = Int(totfilesPart[3]) } else { totNum = 0 }
        if totfilesPartSize.count > 3 { totNumSize = Double(totfilesPartSize[3]) } else { totNumSize = 0 }
        result2 = Result2(totNum: totNum ?? 0, totDir: 0, totNumSize: totNumSize ?? 0, transferNum: transferNum ?? 0, transferNumSize: transferNumSize ?? 0, newfiles: 0, deletefiles: 0)
    }

    // Input is TrimOutputFromRsync(myoutput).trimmeddata
    public init(_ output: [String], _ version3ofrsync: Bool) {
        var resultRsync = ""
        guard output.count > 0 else { return }
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

        result = Result(resultRsync: resultRsync,
                        files: files,
                        filesSize: filesSize,
                        totfileSize: totfileSize,
                        totfilesNum: totfilesNum,
                        new: new,
                        delete: delete)
        if files.count == 1, filesSize.count == 1, totfileSize.count == 1, totfilesNum.count == 1 {
            if version3ofrsync, let result {
                rsyncver3(result: result)
            } else if let result {
                rsyncver2(result: result)
            }
        }
    }
}

// swiftlint:enable cyclomatic_complexity
