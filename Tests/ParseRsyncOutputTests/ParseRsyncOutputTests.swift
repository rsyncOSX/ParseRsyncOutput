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
            } catch {
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
            } catch {
                return nil
            }
        }
        return nil
    }

    func readopenrsyncfile() -> [String]? {
        if let homepath = userHomeDirectoryURLPath {
            let ver2 = "GitHub/ParseRsyncOutput/TestData/openrsync.txt"
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
            } catch {
                return nil
            }
        }
        return nil
    }

    @Test func executetestV3() {
        let array = readloggfileV3()
        if let array  {
            
            let trimmedoutputfromrsync = PrepareOutputFromRsync().prepareOutputFromRsync(array)
            let parsersyncoutput = ParseRsyncOutput(trimmedoutputfromrsync, true)
            
            #expect(parsersyncoutput.stats == "6846 files : 0.39 MB in 0.47 seconds")
            #expect(parsersyncoutput.numbersonly?.totaltransferredfilessize == 24788299.0)
            #expect(parsersyncoutput.numbersonly?.numberofdeletedfiles == 0)
            #expect(parsersyncoutput.numbersonly?.numberofcreatedfiles == 7191)
            #expect(parsersyncoutput.numbersonly?.totaldirectories == 346)
            #expect(parsersyncoutput.numbersonly?.numberoffiles == 6846)
            #expect(parsersyncoutput.numbersonly?.totalfilesize == 24788299.0)
            #expect(parsersyncoutput.numbersonly?.filestransferred == 6846)
            #expect(parsersyncoutput.numbersonly?.datatosynchronize == true)
        }
    }

    @Test func executetestV2() {
        let array = readloggfileV2()
        if let array  {
            
            let trimmedoutputfromrsync = PrepareOutputFromRsync().prepareOutputFromRsync(array)
            let parsersyncoutput = ParseRsyncOutput(trimmedoutputfromrsync, false)
            #expect(parsersyncoutput.stats == "6846 files : 0.38 MB in 2.25 seconds")
            #expect(parsersyncoutput.numbersonly?.totaltransferredfilessize == 24788299.0)
            #expect(parsersyncoutput.numbersonly?.numberofdeletedfiles == 0)
            #expect(parsersyncoutput.numbersonly?.numberofcreatedfiles == 0)
            #expect(parsersyncoutput.numbersonly?.totaldirectories == 0)
            #expect(parsersyncoutput.numbersonly?.numberoffiles == 7192)
            #expect(parsersyncoutput.numbersonly?.totalfilesize == 24788299.0)
            #expect(parsersyncoutput.numbersonly?.filestransferred == 6846)
            #expect(parsersyncoutput.numbersonly?.datatosynchronize == true)
        }
    }

    @Test func executetestopenrsync() {
        let array = readopenrsyncfile()
        if let array  {
            
            let trimmedoutputfromrsync = PrepareOutputFromRsync().prepareOutputFromRsync(array)
            let parsersyncoutput = ParseRsyncOutput(trimmedoutputfromrsync, false)
            #expect(parsersyncoutput.stats == "6966 files : 0.39 MB in 1.35 seconds")
            #expect(parsersyncoutput.numbersonly?.totaltransferredfilessize == 24929166.0)
            #expect(parsersyncoutput.numbersonly?.numberofdeletedfiles == 0)
            #expect(parsersyncoutput.numbersonly?.numberofcreatedfiles == 0)
            #expect(parsersyncoutput.numbersonly?.totaldirectories == 0)
            #expect(parsersyncoutput.numbersonly?.numberoffiles == 7312)
            #expect(parsersyncoutput.numbersonly?.totalfilesize == 24929166.0)
            #expect(parsersyncoutput.numbersonly?.filestransferred == 6966)
            #expect(parsersyncoutput.numbersonly?.datatosynchronize == true)
        }
    }
}
