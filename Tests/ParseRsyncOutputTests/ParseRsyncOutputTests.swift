@testable import ParseRsyncOutput

import Foundation
import Testing

@MainActor
@Suite final class TestParseRsyncOutput {
    var parsersyncoutput: ParseRsyncOutput?
    
    var userHomeDirectoryURLPath: URL? {
        let pw = getpwuid(getuid())
        if let home = pw?.pointee.pw_dir {
            let homePath = FileManager.default.string(withFileSystemRepresentation: home, length: Int(strlen(home)))
            return URL(fileURLWithPath: homePath)
        } else {
            return nil
        }
    }
    
    func readloggfileV3() -> [String]? {
        if let homepath = userHomeDirectoryURLPath {
            let ver3 = "GitHub/ParseRsyncOutput/TestData/ver3.txt"
            let fileURL = homepath.appendingPathComponent(ver3)

            do {
                let data = try Data(contentsOf: fileURL)
                let filedata = String(data: data, encoding: .utf8)
                var logarray = [String]()
                if let line = filedata?.components(separatedBy: .newlines) {
                    for i in 0 ..< line.count {
                        logarray.append(line[i])
                    }
                }
                return logarray
            } catch  {
                return nil
            }
        }
        return nil
    }
    
    func readloggfileV2() -> [String]? {
        if let homepath = userHomeDirectoryURLPath {
            let ver2 = "GitHub/ParseRsyncOutput/TestData/ver2.txt"
            let fileURL = homepath.appendingPathComponent(ver2)

            do {
                let data = try Data(contentsOf: fileURL)
                let filedata = String(data: data, encoding: .utf8)
                var logarray = [String]()
                if let line = filedata?.components(separatedBy: .newlines) {
                    for i in 0 ..< line.count {
                        logarray.append(line[i])
                    }
                }
                return logarray
            } catch  {
                return nil
            }
        }
        return nil
    }

    @Test func executetestV3() {
        let array = readloggfileV3()
        if let array {
            let trimmedoutputfromrsync = TrimOutputFromRsync(array).trimmeddata
            let parsersyncoutput = ParseRsyncOutput(trimmedoutputfromrsync, true)
            print(parsersyncoutput.stats)
            print(parsersyncoutput.numbersonly?.transferNum)
            print(parsersyncoutput.numbersonly?.transferNumSize)
            print(parsersyncoutput.numbersonly?.deletefiles)
            print(parsersyncoutput.numbersonly?.newfiles)
            print(parsersyncoutput.numbersonly?.totDir)
            print(parsersyncoutput.numbersonly?.totNum)
            print(parsersyncoutput.numbersonly?.totNumSize)
        }
    }
    
    @Test func executetestV2() {
        let array = readloggfileV2()
        if let array {
            let trimmedoutputfromrsync = TrimOutputFromRsync(array).trimmeddata
            let parsersyncoutput = ParseRsyncOutput(trimmedoutputfromrsync, false)
            print(parsersyncoutput.stats)
            print(parsersyncoutput.numbersonly?.transferNum)
            print(parsersyncoutput.numbersonly?.transferNumSize)
            print(parsersyncoutput.numbersonly?.deletefiles)
            print(parsersyncoutput.numbersonly?.newfiles)
            print(parsersyncoutput.numbersonly?.totDir)
            print(parsersyncoutput.numbersonly?.totNum)
            print(parsersyncoutput.numbersonly?.totNumSize)
        }
    }
}
