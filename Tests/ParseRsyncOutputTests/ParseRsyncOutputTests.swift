@testable import ParseRsyncOutput

import Testing
import Foundation

@MainActor
@Suite final class TestParseRsyncOutput {
    
    let rsyncver3: Bool = true
    var parsersyncoutput: ParseRsyncOutput?
    
    
    func processtermination(outputfromrsync: [String]) {
        
        let trimmedoutputfromrsync = TrimOutputFromRsync(outputfromrsync).trimmeddata
        parsersyncoutput = ParseRsyncOutput(trimmedoutputfromrsync,rsyncver3)
        let result = stats()
        print(result)
        
    }
    
    @Test func executetest() {
        
        let arguments = Arguments().nr4
        let process = RsyncProcess(arguments: arguments,
                                                processtermination: processtermination)
        process.executeProcess(rsyncver3)
    }
    
    func stats() -> String {
        let numberOfFiles = String(parsersyncoutput?.transferNum ?? 0)
        let sizeOfFiles = String(parsersyncoutput?.transferNumSize ?? 0)
        var numbers: String?
        var parts: [String]?
        guard parsersyncoutput?.resultRsync != nil else {
            let size = numberOfFiles + " files :" + sizeOfFiles + " KB" + " in just a few seconds"
            return size
        }
        if rsyncver3, let resultRsync = parsersyncoutput?.resultRsync {
            // ["sent", "409687", "bytes", "", "received", "5331", "bytes", "", "830036.00", "bytes/sec"]
            let newmessage = resultRsync.replacingOccurrences(of: ",", with: "")
            parts = newmessage.components(separatedBy: " ")
        } else {
            // ["sent", "262826", "bytes", "", "received", "2248", "bytes", "", "58905.33", "bytes/sec"]
            if let resultRsync = parsersyncoutput?.resultRsync {
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

    private func formatresult(numberOfFiles: String?, bytesTotal: Double, seconds: Double) -> String {
        // Dont have numbers of file as input
        if numberOfFiles == nil {
            String(parsersyncoutput?.output?.count ?? 0) + " files : " +
                String(format: "%.2f", (bytesTotal / 1000) / 1000) +
                " MB in " + String(format: "%.2f", seconds) + " seconds"
        } else {
            numberOfFiles! + " files : " +
                String(format: "%.2f", (bytesTotal / 1000) / 1000) +
                " MB in " + String(format: "%.2f", seconds) + " seconds"
        }
    }
    
}
