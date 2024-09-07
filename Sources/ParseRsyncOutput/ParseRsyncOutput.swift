// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

/*
// enum for returning what is asked for
public enum EnumNumbers {
    case totalNumber
    case totalDirs
    case totalNumber_totalDirs
    case totalNumberSizebytes
    case transferredNumber
    case transferredNumberSizebytes
    case new
    case delete
}
*/

@MainActor
public final class ParseRsyncOutput {
    // Second last String in Array rsync output of how much in what time
    public var resultRsync: String?
    // calculated number of files
    // output Array to keep output from rsync in
    public var output: [String]?
    // numbers after dryrun and stats
    public var totNum: Int?
    public var totDir: Int?
    public var totNumSize: Double?
    public var transferNum: Int?
    public var transferNumSize: Double?
    public var newfiles: Int?
    public var deletefiles: Int?
    // Temporary numbers
    // ver 3.x - [Number of regular files transferred: 24]
    // ver 2.x - [Number of files transferred: 24]
    public var files: [String]?
    // ver 3.x - [Total transferred file size: 278,642 bytes]
    // ver 2.x - [Total transferred file size: 278197 bytes]
    public var filesSize: [String]?
    // ver 3.x - [Total file size: 1,016,382,148 bytes]
    // ver 2.x - [Total file size: 1016381703 bytes]
    public var totfileSize: [String]?
    // ver 3.x - [Number of files: 3,956 (reg: 3,197, dir: 758, link: 1)]
    // ver 2.x - [Number of files: 3956]
    public var totfilesNum: [String]?
    // New files
    public var new: [String]?
    // Delete files
    public var delete: [String]?
    // version 2 or 3 of rsync
    public var version3ofrsync: Bool = true

    public func rsyncver3() {
        guard files?.count ?? -1 > 0 else { return }
        guard filesSize?.count ?? -1 > 0 else { return }
        guard totfilesNum?.count ?? -1 > 0 else { return }
        guard totfileSize?.count ?? -1 > 0 else { return }
        guard new?.count ?? -1 > 0 else { return }
        guard delete?.count ?? -1 > 0 else { return }
        // Ver3 of rsync adds "," as 1000 mark, must replace it and then split numbers into components
        let filesPart = files?[0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        let filesPartSize = filesSize?[0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        let totfilesPart = totfilesNum?[0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        let totfilesPartSize = totfileSize?[0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        let newPart = new?[0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        let deletePart = delete?[0].replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        // ["Number", "of", "regular", "files", "transferred:", "24"]
        // ["Total", "transferred", "file", "size:", "281653", "bytes"]
        // ["Number", "of", "files:", "3956", "(reg:", "3197", "dir:", "758", "link:", "1)"]
        // ["Total", "file", "size:", "1016385159", "bytes"]
        // ["Number" "of" "created" "files:" "0"]
        // ["Number" "of" "deleted" "files:" "0"]
        if filesPart?.count ?? 0 > 5 { transferNum = Int(filesPart?[5] ?? "") } else { transferNum = 0 }
        if filesPartSize?.count ?? 0 > 4 { transferNumSize =
            Double(filesPartSize?[4] ?? "")
        } else { transferNumSize = 0 }
        if totfilesPart?.count ?? 0 > 5 { totNum = Int(totfilesPart?[5] ?? "") } else { totNum = 0 }
        if totfilesPartSize?.count ?? 0 > 3 { totNumSize =
            Double(totfilesPartSize?[3] ?? "")
        } else { totNumSize = 0 }
        if totfilesPart?.count ?? 0 > 7 {
            totDir = Int((totfilesPart?[7] ?? "").replacingOccurrences(of: ")", with: ""))
        } else {
            totDir = 0
        }
        if newPart?.count ?? 0 > 4 { newfiles = Int(newPart?[4] ?? "") } else { newfiles = 0 }
        if deletePart?.count ?? 0 > 4 { deletefiles = Int(deletePart?[4] ?? "") } else { deletefiles = 0 }
    }

    public func rsyncver2() {
        guard files?.count ?? -1 > 0 else { return }
        guard filesSize?.count ?? -1 > 0 else { return }
        guard totfilesNum?.count ?? -1 > 0 else { return }
        guard totfileSize?.count ?? -1 > 0 else { return }
        let filesPart = files?[0].components(separatedBy: " ")
        let filesPartSize = filesSize?[0].components(separatedBy: " ")
        let totfilesPart = totfilesNum?[0].components(separatedBy: " ")
        let totfilesPartSize = totfileSize?[0].components(separatedBy: " ")
        // ["Number", "of", "files", "transferred:", "24"]
        // ["Total", "transferred", "file", "size:", "281579", "bytes"]
        // ["Number", "of", "files:", "3956"]
        // ["Total", "file", "size:", "1016385085", "bytes"]
        if filesPart?.count ?? 0 > 4 { transferNum = Int(filesPart?[4] ?? "") } else { transferNum = 0 }
        if filesPartSize?.count ?? 0 > 4 { transferNumSize =
            Double(filesPartSize?[4] ?? "")
        } else { transferNumSize = 0 }
        if totfilesPart?.count ?? 0 > 3 { totNum = Int(totfilesPart?[3] ?? "") } else { totNum = 0 }
        if totfilesPartSize?.count ?? 0 > 3 { totNumSize =
            Double(totfilesPartSize?[3] ?? "")
        } else { totNumSize = 0 }
        // Rsync ver 2.x does not count directories, new files or deleted files
        totDir = 0
        newfiles = 0
        deletefiles = 0
    }

    public func stats() -> String {
        let numberOfFiles = String(transferNum ?? 0)
        let sizeOfFiles = String(transferNumSize ?? 0)
        var numbers: String?
        var parts: [String]?
        guard resultRsync != nil else {
            let size = numberOfFiles + " files :" + sizeOfFiles + " KB" + " in just a few seconds"
            return size
        }
        if version3ofrsync, let resultRsync {
            // ["sent", "409687", "bytes", "", "received", "5331", "bytes", "", "830036.00", "bytes/sec"]
            let newmessage = resultRsync.replacingOccurrences(of: ",", with: "")
            parts = newmessage.components(separatedBy: " ")
        } else {
            // ["sent", "262826", "bytes", "", "received", "2248", "bytes", "", "58905.33", "bytes/sec"]
            if let resultRsync {
                parts = resultRsync.components(separatedBy: " ")
            }
        }
        var bytesTotalsent: Double = 0
        var bytesTotalreceived: Double = 0
        var bytesTotal: Double = 0
        var bytesSec: Double = 0
        var seconds: Double = 0
        guard (parts?.count ?? 0) > 9 else { return "0" }
        // Sent and received
        bytesTotalsent = Double(parts?[1] ?? "0") ?? 0
        bytesTotalreceived = Double(parts?[5] ?? "0") ?? 0
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
        numbers = formatresult(numberOfFiles: numberOfFiles, bytesTotal: bytesTotal, seconds: seconds)
        return numbers ?? ""
    }

    public func formatresult(numberOfFiles: String?, bytesTotal: Double, seconds: Double) -> String {
        // Dont have numbers of file as input
        if numberOfFiles == nil {
            String(output?.count ?? 0) + " files : " +
                String(format: "%.2f", (bytesTotal / 1000) / 1000) +
                " MB in " + String(format: "%.2f", seconds) + " seconds"
        } else {
            numberOfFiles! + " files : " +
                String(format: "%.2f", (bytesTotal / 1000) / 1000) +
                " MB in " + String(format: "%.2f", seconds) + " seconds"
        }
    }

    // Input is TrimOutputFromRsync(myoutput).trimmeddata
    public init(_ myoutput: [String], _ myversion3ofrsync: Bool) {
        version3ofrsync = myversion3ofrsync
        guard myoutput.count > 0 else { return }
        // output = outputprocess?.trimoutput(trim: .two)
        output = myoutput
        // Getting the summarized output from output.
        if (output?.count ?? 0) > 2 {
            resultRsync = output?[(output?.count ?? 0) - 2]
        }
        files = output?.filter { $0.contains("files transferred:") }
        // ver 3.x - [Number of regular files transferred: 24]
        // ver 2.x - [Number of files transferred: 24]
        filesSize = output?.filter { $0.contains("Total transferred file size:") }
        // ver 3.x - [Total transferred file size: 278,642 bytes]
        // ver 2.x - [Total transferred file size: 278197 bytes]
        totfileSize = output?.filter { $0.contains("Total file size:") }
        // ver 3.x - [Total file size: 1,016,382,148 bytes]
        // ver 2.x - [Total file size: 1016381703 bytes]
        totfilesNum = output?.filter { $0.contains("Number of files:") }
        // ver 3.x - [Number of files: 3,956 (reg: 3,197, dir: 758, link: 1)]
        // ver 2.x - [Number of files: 3956]
        // New files
        new = output?.filter { $0.contains("Number of created files:") }
        // Delete files
        delete = output?.filter { $0.contains("Number of deleted files:") }
        if files?.count == 1, filesSize?.count == 1, totfileSize?.count == 1, totfilesNum?.count == 1 {
            if version3ofrsync {
                rsyncver3()
            } else {
                rsyncver2()
            }
        } else {
            // If it breaks set number of transferred files to size of output.
            transferNum = output?.count ?? 0
        }
    }
}

// swiftlint:enable cyclomatic_complexity
