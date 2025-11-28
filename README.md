## Hi there 👋

This package is code for parsing the text output from `rsync`, for extracting key numbers of the output for updating views and log in 

# ParseRsyncOutput

A Swift package for parsing rsync command output and extracting synchronization statistics, file counts, transfer sizes, and performance metrics.

## Features

- **Multi-Version Support**: Parse output from both rsync 3.x and rsync 2.x/openrsync
- **Comprehensive Statistics**: Extract file counts, sizes, transfer metrics, and sync status
- **Error Handling**: Robust error detection and reporting with detailed error messages
- **Warning System**: Non-fatal warnings for partial parsing issues
- **Formatted Output**: Pre-formatted strings ready for UI display
- **Type-Safe Parsing**: Strongly-typed data structures for parsed results
- **Performance Metrics**: Automatic calculation of transfer speed and duration

## Requirements

- Swift 5.9+
- macOS 13.0+ / iOS 16.0+
- Foundation framework
- OSLog for logging

## Usage

### Basic Parsing

```swift
import ParseRsyncOutput

// Sample rsync output lines
let rsyncOutput = [
    "Number of files: 1,234 (reg: 1,100, dir: 134)",
    "Number of created files: 42",
    "Number of deleted files: 15",
    "Total file size: 1,234,567,890 bytes",
    "Total transferred file size: 123,456,789 bytes",
    "files transferred: 42",
    "sent 123456 bytes  received 789012 bytes  45678.00 bytes/sec"
]

// Parse for rsync 3.x
let parser = ParseRsyncOutput(rsyncOutput, .ver3)

// Check parsing success
if parser.parseResult.isSuccess {
    print("✓ Parsing successful")
    
    if let numbers = parser.numbersonly {
        print("Files: \(numbers.numberoffiles)")
        print("Transferred: \(numbers.filestransferred)")
        print("Created: \(numbers.numberofcreatedfiles)")
        print("Deleted: \(numbers.numberofdeletedfiles)")
        print("Changes needed: \(numbers.datatosynchronize)")
    }
    
    if let stats = parser.stats {
        print("Summary: \(stats)")
        // Output: "42 files : 117.64 MB in 20.03 seconds"
    }
} else {
    print("✗ Parsing failed")
    for error in parser.parseResult.errors {
        print("Error: \(error.localizedDescription)")
    }
}
```

### Parsing OpenRsync Output

```swift
// For rsync 2.x or openrsync
let parser = ParseRsyncOutput(rsyncOutput, .openrsync)

if parser.parseResult.isSuccess {
    // Access parsed data
    if let numbers = parser.numbersonly {
        print("Synced \(numbers.filestransferred) files")
        print("Total size: \(numbers.totalfilesize) bytes")
    }
}
```

### Using Formatted Properties

The parser provides pre-formatted strings ideal for displaying in UIs:

```swift
let parser = ParseRsyncOutput(rsyncOutput, .ver3)

// Use formatted properties directly
print("Files: \(parser.formatted_numberoffiles)")
print("Directories: \(parser.formatted_totaldirectories)")
print("Total Size: \(parser.formatted_totalfilesize)")
print("Transferred: \(parser.formatted_filestransferred)")
print("Created: \(parser.formatted_numberofcreatedfiles)")
print("Deleted: \(parser.formatted_numberofdeletedfiles)")
print("Files + Dirs: \(parser.formatted_numberoffiles_totaldirectories)")
```

### SwiftUI Integration

```swift
import SwiftUI
import ParseRsyncOutput

struct SyncResultView: View {
    let parser: ParseRsyncOutput
    
    var body: some View {
        Form {
            if parser.parseResult.isSuccess {
                Section("Transfer Summary") {
                    LabeledContent("Files Transferred", value: parser.formatted_filestransferred)
                    LabeledContent("Total Files", value: parser.formatted_numberoffiles)
                    LabeledContent("Directories", value: parser.formatted_totaldirectories)
                    LabeledContent("Total Size", value: parser.formatted_totalfilesize)
                }
                
                Section("Changes") {
                    LabeledContent("Created", value: parser.formatted_numberofcreatedfiles)
                    LabeledContent("Deleted", value: parser.formatted_numberofdeletedfiles)
                    
                    if let numbers = parser.numbersonly {
                        HStack {
                            Text("Sync Status")
                            Spacer()
                            if numbers.datatosynchronize {
                                Label("Changes Detected", systemImage: "exclamationmark.circle")
                                    .foregroundStyle(.orange)
                            } else {
                                Label("Up to Date", systemImage: "checkmark.circle")
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }
                
                if let stats = parser.stats {
                    Section("Performance") {
                        Text(stats)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Section("Errors") {
                    ForEach(parser.parseResult.errors, id: \.localizedDescription) { error in
                        Label(error.localizedDescription, systemImage: "xmark.circle")
                            .foregroundStyle(.red)
                    }
                }
            }
            
            if parser.parseResult.hasWarnings {
                Section("Warnings") {
                    ForEach(parser.parseResult.warnings, id: \.self) { warning in
                        Label(warning, systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.orange)
                            .font(.caption)
                    }
                }
            }
        }
    }
}
```

### Error Handling

```swift
let parser = ParseRsyncOutput(rsyncOutput, .ver3)

// Check for errors
if !parser.parseResult.isSuccess {
    for error in parser.parseResult.errors {
        switch error {
        case .missingRequiredField(let field):
            print("Missing: \(field)")
        case .invalidNumberFormat(let field, let value):
            print("Invalid number in \(field): \(value)")
        case .invalidOutputFormat(let details):
            print("Format error: \(details)")
        case .incompleteSummaryLine:
            print("Incomplete summary line")
        case .divisionByZero:
            print("Invalid bytes/sec value")
        case .unsupportedVersion:
            print("Unsupported rsync version")
        }
    }
}

// Check for warnings (non-fatal)
if parser.parseResult.hasWarnings {
    for warning in parser.parseResult.warnings {
        print("⚠️ \(warning)")
    }
}
```

## Data Structures

### NumbersOnly

Complete parsed statistics from rsync output:

```swift
public struct NumbersOnly {
    public var numberoffiles: Int              // Number of regular files
    public var totaldirectories: Int           // Number of directories
    public var totalfilesize: Double           // Total size in bytes
    public var filestransferred: Int           // Files actually transferred
    public var totaltransferredfilessize: Double // Size of transferred files
    public var numberofcreatedfiles: Int       // Newly created files
    public var numberofdeletedfiles: Int       // Deleted files
    public var datatosynchronize: Bool         // True if changes exist
}
```

### ParseResult

Wrapper containing parsing results and status:

```swift
public struct ParseResult {
    public let numbersonly: NumbersOnly?       // Parsed statistics
    public let stats: String?                  // Formatted summary
    public let errors: [RsyncParseError]       // Parsing errors
    public let warnings: [String]              // Non-fatal warnings
    
    public var isSuccess: Bool                 // True if no errors
    public var hasWarnings: Bool               // True if warnings exist
}
```

### VersionRsync

Enum for specifying rsync version:

```swift
public enum VersionRsync {
    case ver3        // rsync 3.x
    case openrsync   // rsync 2.x or openrsync
}
```

## Error Types

### RsyncParseError

```swift
public enum RsyncParseError: Error, LocalizedError {
    case missingRequiredField(String)          // Required field not found
    case invalidNumberFormat(field: String, value: String) // Cannot parse number
    case invalidOutputFormat(String)           // Malformed output
    case incompleteSummaryLine                 // Incomplete sent/received line
    case divisionByZero                        // Invalid bytes/sec
    case unsupportedVersion                    // Unknown rsync version
}
```

## API Reference

### ParseRsyncOutput

Main parser class (requires @MainActor):

#### Initialization

```swift
public init(_ preparedoutputfromrsync: [String], _ rsyncversion: VersionRsync)
```

#### Properties

- `numbersonly: NumbersOnly?` - Parsed numerical statistics
- `stats: String?` - Formatted performance summary
- `errors: [RsyncParseError]` - Array of parsing errors
- `warnings: [String]` - Array of warning messages
- `parseResult: ParseResult` - Complete result with status

#### Formatted Properties

All properties return localized, formatted strings:

- `formatted_filestransferred: String`
- `formatted_numberoffiles: String`
- `formatted_totalfilesize: String`
- `formatted_totaldirectories: String`
- `formatted_numberoffiles_totaldirectories: String`
- `formatted_numberofcreatedfiles: String`
- `formatted_numberofdeletedfiles: String`

#### Methods

- `rsyncver3(stringnumbersonly:)` - Parse rsync 3.x output
- `rsyncver2(stringnumbersonly:)` - Parse rsync 2.x/openrsync output
- `returnIntNumber(_:) -> [Int]` - Extract integers from string
- `returnDoubleNumber(_:) -> [Double]` - Extract doubles from string

## Parsing Details

### Rsync 3.x Output Format

The parser expects these lines in rsync 3.x output:

```
Number of files: 1,234 (reg: 1,100, dir: 134)
Number of created files: 42
Number of deleted files: 15
Total file size: 1,234,567,890 bytes
Total transferred file size: 123,456,789 bytes
files transferred: 42
sent 123456 bytes  received 789012 bytes  45678.00 bytes/sec
```

### Rsync 2.x/OpenRsync Format

For older versions:

```
Number of files: 1,234
Total file size: 1,234,567,890 bytes
Total transferred file size: 123,456,789 bytes
files transferred: 42
sent 123456 bytes  received 789012 bytes  45678.00 bytes/sec
```

### Statistics Calculation

The `stats` property provides a formatted summary:

```
"42 files : 117.64 MB in 20.03 seconds"
```

Calculated as:
- Files: Number of transferred files
- Size: Total bytes sent / 1,000,000 (converted to MB)
- Time: Total bytes sent / bytes per second

## Best Practices

1. **Always check `parseResult.isSuccess`** before accessing `numbersonly`
2. **Handle warnings** - they indicate partial parsing issues but don't prevent use
3. **Use formatted properties** for display to ensure proper localization
4. **Specify correct version** - use `.ver3` for modern rsync, `.openrsync` for older versions
5. **Log errors** - parsing errors are automatically logged via OSLog

## Example: Complete Workflow

```swift
import ParseRsyncOutput

@MainActor
func processSyncResults(_ output: [String]) {
    let parser = ParseRsyncOutput(output, .ver3)
    
    guard parser.parseResult.isSuccess else {
        print("Parsing failed:")
        parser.parseResult.errors.forEach { print("  - \($0.localizedDescription)") }
        return
    }
    
    guard let numbers = parser.numbersonly else {
        print("No statistics available")
        return
    }
    
    // Display results
    print("=== Sync Results ===")
    print("Files: \(parser.formatted_numberoffiles)")
    print("Directories: \(parser.formatted_totaldirectories)")
    print("Total Size: \(parser.formatted_totalfilesize)")
    print()
    print("Transferred: \(parser.formatted_filestransferred)")
    print("Created: \(parser.formatted_numberofcreatedfiles)")
    print("Deleted: \(parser.formatted_numberofdeletedfiles)")
    print()
    
    if let stats = parser.stats {
        print("Performance: \(stats)")
    }
    
    print()
    if numbers.datatosynchronize {
        print("⚠️  Changes detected - sync needed")
    } else {
        print("✓ Everything up to date")
    }
    
    // Show warnings if any
    if parser.parseResult.hasWarnings {
        print("\nWarnings:")
        parser.parseResult.warnings.forEach { print("  - \($0)") }
    }
}
```

## License

MIT

## Author

Thomas Evensen