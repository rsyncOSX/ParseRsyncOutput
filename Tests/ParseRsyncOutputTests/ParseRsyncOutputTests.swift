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

    func readloggfileV3_ver2() -> [String]? {
        if let homepath = userHomeDirectoryURLPath {
            let ver3 = "GitHub/ParseRsyncOutput/TestData/ver3_ver2.txt"
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

    func readloggfileV3_ver3() -> [String]? {
        if let homepath = userHomeDirectoryURLPath {
            let ver3 = "GitHub/ParseRsyncOutput/TestData/ver3_ver3.txt"
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

    func readopenrsyncfile_ver2() -> [String]? {
        if let homepath = userHomeDirectoryURLPath {
            let ver2 = "GitHub/ParseRsyncOutput/TestData/openrsync_ver2.txt"
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

    func readopenrsyncfile_ver3() -> [String]? {
        if let homepath = userHomeDirectoryURLPath {
            let ver2 = "GitHub/ParseRsyncOutput/TestData/openrsync_ver3.txt"
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
        if let array {
            let trimmedoutputfromrsync = PrepareOutputFromRsync().prepareOutputFromRsync(array)
            let parsersyncoutput = ParseRsyncOutput(trimmedoutputfromrsync, .ver3)
            do {
                let stats = try parsersyncoutput.getstats()
                #expect(stats == "6846 files : 0.39 MB in 0.47 seconds")
                #expect(parsersyncoutput.numbersonly?.totaltransferredfilessize == 24_788_299.0)
                #expect(parsersyncoutput.numbersonly?.numberofdeletedfiles == 0)
                #expect(parsersyncoutput.numbersonly?.numberofcreatedfiles == 7191)
                #expect(parsersyncoutput.numbersonly?.totaldirectories == 346)
                #expect(parsersyncoutput.numbersonly?.numberoffiles == 6846)
                #expect(parsersyncoutput.numbersonly?.totalfilesize == 24_788_299.0)
                #expect(parsersyncoutput.numbersonly?.filestransferred == 6846)
                #expect(parsersyncoutput.numbersonly?.datatosynchronize == true)
            } catch {}
        }
    }

    @Test func executetestV2() {
        let array = readloggfileV2()
        if let array {
            let trimmedoutputfromrsync = PrepareOutputFromRsync().prepareOutputFromRsync(array)
            let parsersyncoutput = ParseRsyncOutput(trimmedoutputfromrsync, .openrsync)
            do {
                let stats = try parsersyncoutput.getstats()
                #expect(stats == "6846 files : 0.38 MB in 2.25 seconds")
                #expect(parsersyncoutput.numbersonly?.totaltransferredfilessize == 24_788_299.0)
                #expect(parsersyncoutput.numbersonly?.numberofdeletedfiles == 0)
                #expect(parsersyncoutput.numbersonly?.numberofcreatedfiles == 0)
                #expect(parsersyncoutput.numbersonly?.totaldirectories == 0)
                #expect(parsersyncoutput.numbersonly?.numberoffiles == 7192)
                #expect(parsersyncoutput.numbersonly?.totalfilesize == 24_788_299.0)
                #expect(parsersyncoutput.numbersonly?.filestransferred == 6846)
                #expect(parsersyncoutput.numbersonly?.datatosynchronize == true)
            } catch {}
        }
    }

    @Test func executetestopenrsync() {
        let array = readopenrsyncfile()
        if let array {
            let trimmedoutputfromrsync = PrepareOutputFromRsync().prepareOutputFromRsync(array)
            let parsersyncoutput = ParseRsyncOutput(trimmedoutputfromrsync, .openrsync)

            do {
                let stats = try parsersyncoutput.getstats()
                #expect(stats == "6966 files : 0.39 MB in 1.35 seconds")
                #expect(parsersyncoutput.numbersonly?.totaltransferredfilessize == 24_929_166.0)
                #expect(parsersyncoutput.numbersonly?.numberofdeletedfiles == 0)
                #expect(parsersyncoutput.numbersonly?.numberofcreatedfiles == 0)
                #expect(parsersyncoutput.numbersonly?.totaldirectories == 0)
                #expect(parsersyncoutput.numbersonly?.numberoffiles == 7312)
                #expect(parsersyncoutput.numbersonly?.totalfilesize == 24_929_166.0)
                #expect(parsersyncoutput.numbersonly?.filestransferred == 6966)
                #expect(parsersyncoutput.numbersonly?.datatosynchronize == true)
            } catch {}
        }
    }

    @Test func executetestV3_ver2() {
        let array = readloggfileV3_ver2()
        if let array {
            let trimmedoutputfromrsync = PrepareOutputFromRsync().prepareOutputFromRsync(array)
            let parsersyncoutput = ParseRsyncOutput(trimmedoutputfromrsync, .ver3)

            do {
                let stats = try parsersyncoutput.getstats()
                #expect(stats == "44 files : 1.81 MB in 1.49 seconds")
                #expect(parsersyncoutput.numbersonly?.totaltransferredfilessize == 254_016.0)
                #expect(parsersyncoutput.numbersonly?.numberofdeletedfiles == 0)
                #expect(parsersyncoutput.numbersonly?.numberofcreatedfiles == 24)
                #expect(parsersyncoutput.numbersonly?.totaldirectories == 7145)
                #expect(parsersyncoutput.numbersonly?.numberoffiles == 52854)
                #expect(parsersyncoutput.numbersonly?.totalfilesize == 870_769_866.0)
                #expect(parsersyncoutput.numbersonly?.filestransferred == 44)
                #expect(parsersyncoutput.numbersonly?.datatosynchronize == true)
            } catch {}
        }
    }

    @Test func executetestV3_ver3() {
        let array = readloggfileV3_ver3()
        if let array {
            let trimmedoutputfromrsync = PrepareOutputFromRsync().prepareOutputFromRsync(array)
            let parsersyncoutput = ParseRsyncOutput(trimmedoutputfromrsync, .ver3)

            do {
                let stats = try parsersyncoutput.getstats()
                #expect(stats == "3301 files : 0.19 MB in 1.42 seconds")
                #expect(parsersyncoutput.numbersonly?.totaltransferredfilessize == 27_747_677.0)
                #expect(parsersyncoutput.numbersonly?.numberofdeletedfiles == 0)
                #expect(parsersyncoutput.numbersonly?.numberofcreatedfiles == 3661)
                #expect(parsersyncoutput.numbersonly?.totaldirectories == 360)
                #expect(parsersyncoutput.numbersonly?.numberoffiles == 3301)
                #expect(parsersyncoutput.numbersonly?.totalfilesize == 27_747_677.0)
                #expect(parsersyncoutput.numbersonly?.filestransferred == 3301)
                #expect(parsersyncoutput.numbersonly?.datatosynchronize == true)
            } catch {}
        }
    }

    @Test func executetestopenrsync_ver2() {
        let array = readopenrsyncfile_ver2()
        if let array {
            let trimmedoutputfromrsync = PrepareOutputFromRsync().prepareOutputFromRsync(array)
            let parsersyncoutput = ParseRsyncOutput(trimmedoutputfromrsync, .openrsync)

            do {
                let stats = try parsersyncoutput.getstats()
                #expect(stats == "44 files : 1.50 MB in 1.50 seconds")
                #expect(parsersyncoutput.numbersonly?.totaltransferredfilessize == 254_016.0)
                #expect(parsersyncoutput.numbersonly?.numberofdeletedfiles == 0)
                #expect(parsersyncoutput.numbersonly?.numberofcreatedfiles == 0)
                #expect(parsersyncoutput.numbersonly?.totaldirectories == 0)
                #expect(parsersyncoutput.numbersonly?.numberoffiles == 60110)
                #expect(parsersyncoutput.numbersonly?.totalfilesize == 870_769_866.0)
                #expect(parsersyncoutput.numbersonly?.filestransferred == 44)
                #expect(parsersyncoutput.numbersonly?.datatosynchronize == true)
            } catch {}
        }
    }

    @Test func executetestopenrsync_ver3() {
        let array = readopenrsyncfile_ver3()
        if let array {
            let trimmedoutputfromrsync = PrepareOutputFromRsync().prepareOutputFromRsync(array)
            let parsersyncoutput = ParseRsyncOutput(trimmedoutputfromrsync, .openrsync)

            do {
                let stats = try parsersyncoutput.getstats()
                #expect(stats == "3301 files : 0.30 MB in 0.16 seconds")
                #expect(parsersyncoutput.numbersonly?.totaltransferredfilessize == 27_747_677.0)
                #expect(parsersyncoutput.numbersonly?.numberofdeletedfiles == 0)
                #expect(parsersyncoutput.numbersonly?.numberofcreatedfiles == 0)
                #expect(parsersyncoutput.numbersonly?.totaldirectories == 0)
                #expect(parsersyncoutput.numbersonly?.numberoffiles == 3661)
                #expect(parsersyncoutput.numbersonly?.totalfilesize == 27_747_677.0)
                #expect(parsersyncoutput.numbersonly?.filestransferred == 3301)
                #expect(parsersyncoutput.numbersonly?.datatosynchronize == true)
            } catch {}
        }
    }

    @Test("Parse valid rsync v3.x output")
    func rsyncVersion3ValidOutput() async throws {
        let output = [
            "sent 123,456 bytes  received 78,901 bytes  20,235.40 bytes/sec",
            "Number of files: 3,956 (reg: 3,197, dir: 758, link: 1)",
            "Number of regular files transferred: 24",
            "Total file size: 1,016,382,148 bytes",
            "Total transferred file size: 278,642 bytes",
            "Number of created files: 15",
            "Number of deleted files: 3",
        ]

        let parser = ParseRsyncOutput(output, .ver3)

        #expect(parser.numbersonly != nil)
        #expect(parser.numbersonly?.numberoffiles == 3197)
        #expect(parser.numbersonly?.totaldirectories == 758)
        #expect(parser.numbersonly?.totalfilesize == 1_016_382_148.0)
        #expect(parser.numbersonly?.filestransferred == 24)
        #expect(parser.numbersonly?.totaltransferredfilessize == 278_642.0)
        #expect(parser.numbersonly?.numberofcreatedfiles == 15)
        #expect(parser.numbersonly?.numberofdeletedfiles == 3)
        #expect(parser.numbersonly?.datatosynchronize == true)
    }

    @Test("Parse rsync v3.x with no files transferred")
    func rsyncVersion3NoFilesTransferred() async throws {
        let output = [
            "sent 1,234 bytes  received 567 bytes  180.10 bytes/sec",
            "Number of files: 1,000 (reg: 800, dir: 200)",
            "Number of regular files transferred: 0",
            "Total file size: 5,000,000 bytes",
            "Total transferred file size: 0 bytes",
            "Number of created files: 0",
            "Number of deleted files: 0",
        ]

        let parser = ParseRsyncOutput(output, .ver3)

        #expect(parser.numbersonly != nil)
        #expect(parser.numbersonly?.filestransferred == 0)
        #expect(parser.numbersonly?.datatosynchronize == false)
    }

    @Test("Parse rsync v3.x with data to synchronize - created files")
    func rsyncVersion3DataToSyncCreatedFiles() async throws {
        let output = [
            "sent 10,000 bytes  received 5,000 bytes  1,500.00 bytes/sec",
            "Number of files: 100 (reg: 80, dir: 20)",
            "Number of regular files transferred: 0",
            "Total file size: 1,000,000 bytes",
            "Total transferred file size: 0 bytes",
            "Number of created files: 5",
            "Number of deleted files: 0",
        ]

        let parser = ParseRsyncOutput(output, .ver3)

        #expect(parser.numbersonly?.datatosynchronize == true)
        #expect(parser.numbersonly?.numberofcreatedfiles == 5)
    }

    @Test("Parse rsync v3.x with data to synchronize - deleted files")
    func rsyncVersion3DataToSyncDeletedFiles() async throws {
        let output = [
            "sent 10,000 bytes  received 5,000 bytes  1,500.00 bytes/sec",
            "Number of files: 100 (reg: 80, dir: 20)",
            "Number of regular files transferred: 0",
            "Total file size: 1,000,000 bytes",
            "Total transferred file size: 0 bytes",
            "Number of created files: 0",
            "Number of deleted files: 8",
        ]

        let parser = ParseRsyncOutput(output, .ver3)

        #expect(parser.numbersonly?.datatosynchronize == true)
        #expect(parser.numbersonly?.numberofdeletedfiles == 8)
    }

    // MARK: - Rsync v2.x Tests

    @Test("Parse valid rsync v2.x output")
    func rsyncVersion2ValidOutput() async throws {
        let output = [
            "sent 123456 bytes  received 78901 bytes  20235.40 bytes/sec",
            "Number of files: 3956",
            "Number of files transferred: 24",
            "Total file size: 1016381703 bytes",
            "Total transferred file size: 278197 bytes",
        ]

        let parser = ParseRsyncOutput(output, .openrsync)

        #expect(parser.numbersonly != nil)
        #expect(parser.numbersonly?.numberoffiles == 3956)
        #expect(parser.numbersonly?.totaldirectories == 0)
        #expect(parser.numbersonly?.totalfilesize == 1_016_381_703.0)
        #expect(parser.numbersonly?.filestransferred == 24)
        #expect(parser.numbersonly?.totaltransferredfilessize == 278_197.0)
        #expect(parser.numbersonly?.numberofcreatedfiles == 0)
        #expect(parser.numbersonly?.numberofdeletedfiles == 0)
    }

    @Test("Parse rsync v2.x with no files transferred")
    func rsyncVersion2NoFilesTransferred() async throws {
        let output = [
            "sent 1234 bytes  received 567 bytes  180.10 bytes/sec",
            "Number of files: 1000",
            "Number of files transferred: 0",
            "Total file size: 5000000 bytes",
            "Total transferred file size: 0 bytes",
        ]

        let parser = ParseRsyncOutput(output, .openrsync)

        #expect(parser.numbersonly != nil)
        #expect(parser.numbersonly?.filestransferred == 0)
        #expect(parser.numbersonly?.datatosynchronize == false)
    }

    // MARK: - Edge Cases and Error Handling

    @Test("Parse incomplete rsync output")
    func incompleteOutput() async throws {
        let output = [
            "sent 123456 bytes  received 78901 bytes  20235.40 bytes/sec",
            "Number of files: 100",
            // Missing required fields
        ]

        let parser = ParseRsyncOutput(output, .ver3)

        #expect(parser.numbersonly == nil)
    }

    @Test("Parse empty rsync output")
    func emptyOutput() async throws {
        let output: [String] = []

        let parser = ParseRsyncOutput(output, .ver3)

        #expect(parser.numbersonly == nil)
    }

    @Test("Parse malformed bytes/sec line")
    func malformedBytesSecLine() async throws {
        let output = [
            "some random text without proper format",
            "Number of files: 100 (reg: 80, dir: 20)",
            "Number of regular files transferred: 5",
            "Total file size: 1,000,000 bytes",
            "Total transferred file size: 50,000 bytes",
            "Number of created files: 5",
            "Number of deleted files: 0",
        ]

        let parser = ParseRsyncOutput(output, .ver3)

        // Should fail to parse due to missing sent/received/bytes line
        #expect(parser.numbersonly == nil)
        #expect(parser.errors.count > 0)
        #expect(parser.errors.contains { error in
            if case let .missingRequiredField(field) = error {
                return field.contains("sent/received/bytes")
            }
            return false
        })
    }

    // MARK: - Helper Method Tests

    @Test("returnIntNumber extracts integers correctly")
    func testReturnIntNumber() async throws {
        let parser = ParseRsyncOutput([], .ver3)

        let result1 = parser.returnIntNumber("Number of files: 3,956 (reg: 3,197, dir: 758)")
        #expect(result1 == [3956, 3197, 758])

        let result2 = parser.returnIntNumber("No numbers here!")
        #expect(result2 == [0])

        let result3 = parser.returnIntNumber("123,456,789")
        #expect(result3 == [123_456_789])
    }

    @Test("returnDoubleNumber extracts doubles correctly")
    func testReturnDoubleNumber() async throws {
        let parser = ParseRsyncOutput([], .ver3)

        let result1 = parser.returnDoubleNumber("Total file size: 1,016,382,148 bytes")
        #expect(result1 == [1_016_382_148.0])

        let result2 = parser.returnDoubleNumber("No numbers here!")
        #expect(result2 == [0.0])

        let result3 = parser.returnDoubleNumber("123,456")
        #expect(result3 == [123_456.0])
    }

    // MARK: - Formatted String Tests

    @Test("Formatted strings return correct values")
    func formattedStrings() async throws {
        let output = [
            "sent 123,456 bytes  received 78,901 bytes  20,235.40 bytes/sec",
            "Number of files: 3,956 (reg: 3,197, dir: 758, link: 1)",
            "Number of regular files transferred: 24",
            "Total file size: 1,016,382,148 bytes",
            "Total transferred file size: 278,642 bytes",
            "Number of created files: 15",
            "Number of deleted files: 3",
        ]

        let parser = ParseRsyncOutput(output, .ver3)

        #expect(parser.formatted_filestransferred == "24")
        #expect(parser.formatted_numberofcreatedfiles == "15")
        #expect(parser.formatted_numberofdeletedfiles == "3")
        // Note: formatted values depend on locale, so exact string matching may vary
        #expect(parser.formatted_numberoffiles.count > 0)
    }

    // MARK: - Stats Calculation Tests

    @Test("Stats calculation produces valid output")
    func statsCalculation() async throws {
        let output = [
            "sent 500,000 bytes  received 100,000 bytes  10,000.00 bytes/sec",
            "Number of files: 100 (reg: 80, dir: 20)",
            "Number of regular files transferred: 10",
            "Total file size: 1,000,000 bytes",
            "Total transferred file size: 500,000 bytes",
            "Number of created files: 0",
            "Number of deleted files: 0",
        ]

        let parser = ParseRsyncOutput(output, .ver3)

        do {
            let stats = try parser.getstats()
            #expect(stats?.contains("files") == true)
            #expect(stats?.contains("MB") == true)
            #expect(stats?.contains("seconds") == true)
        } catch {}
    }

    // MARK: - Real-World Output Tests

    @Test("Parse real rsync v3.x output with large numbers")
    func realWorldLargeSync() async throws {
        let output = [
            "sent 15,234,567,890 bytes  received 1,234,567 bytes  125,456.78 bytes/sec",
            "Number of files: 125,456 (reg: 100,234, dir: 25,222)",
            "Number of regular files transferred: 1,234",
            "Total file size: 50,000,000,000 bytes",
            "Total transferred file size: 15,234,567,890 bytes",
            "Number of created files: 500",
            "Number of deleted files: 200",
        ]

        let parser = ParseRsyncOutput(output, .ver3)

        #expect(parser.numbersonly != nil)
        #expect(parser.numbersonly?.numberoffiles == 100_234)
        #expect(parser.numbersonly?.totaldirectories == 25222)
        #expect(parser.numbersonly?.filestransferred == 1234)
        #expect(parser.numbersonly?.datatosynchronize == true)
    }
}
