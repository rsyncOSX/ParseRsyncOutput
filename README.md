## Hi there 👋

This package is code for parsing the text output from `rsync`, for extracting key numbers of the output for updating views and log in RsyncUI. 

# RsyncProcess

A Swift package for executing and monitoring rsync processes with real-time output capture, error handling, and progress tracking.

## Features

- **Process Execution**: Execute rsync commands with custom arguments and environment variables
- **Real-time Output Capture**: Monitor rsync output as it happens with observable models
- **Error Detection**: Automatic error detection in rsync output with custom error handling
- **Version Support**: Compatible with both rsync 3.x and openrsync
- **Progress Tracking**: Track file synchronization progress with file handler callbacks
- **Thread-Safe**: Actor-based output capture for safe concurrent access
- **Logging**: Built-in logging support with OSLog integration

## Requirements

- Swift 5.9+
- macOS 13.0+ / iOS 16.0+
- Rsync binary installed on the system

## Installation

Add this package to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/RsyncProcess.git", from: "1.0.0")
]
```

## Usage

### Basic Example

```swift
import RsyncProcess

// Create process handlers
let handlers = ProcessHandlers(
    processtermination: { output, hiddenID in
        print("Process completed with \(output?.count ?? 0) lines")
    },
    filehandler: { count in
        print("Processed \(count) files")
    },
    rsyncpath: { "/usr/bin/rsync" },
    checklineforerror: { line in
        if line.contains("error") {
            throw NSError(domain: "rsync", code: 1)
        }
    },
    updateprocess: { process in
        // Store or update process reference
    },
    propogateerror: { error in
        print("Error: \(error)")
    },
    logger: { id, output in
        // Log output asynchronously
    },
    checkforerrorinrsyncoutput: true,
    rsyncversion3: true,
    environment: nil
)

// Create and execute rsync process
let rsyncProcess = RsyncProcess(
    arguments: ["-av", "/source/", "/destination/"],
    handlers: handlers,
    filehandler: true
)

try await rsyncProcess.executeProcess()
```

### With Real-time Output Capture

```swift
// Enable output capture
await RsyncOutputCapture.shared.enable()

// Create handlers with automatic output capture
let handlers = ProcessHandlers.withOutputCapture(
    processtermination: { output, hiddenID in
        print("Completed")
    },
    filehandler: { count in },
    rsyncpath: { "/usr/bin/rsync" },
    checklineforerror: { _ in },
    updateprocess: { _ in },
    propogateerror: { error in },
    logger: { _, _ in },
    checkforerrorinrsyncoutput: true,
    rsyncversion3: true,
    environment: nil
)

// Execute process
let rsyncProcess = RsyncProcess(
    arguments: ["-av", "/source/", "/destination/"],
    handlers: handlers,
    filehandler: true
)

try await rsyncProcess.executeProcess()

// Access captured output
let output = await RsyncOutputCapture.shared.getAllLines()
```

### Observing Output in SwiftUI

```swift
import SwiftUI
import RsyncProcess

struct RsyncOutputView: View {
    @State private var printLines = PrintLines.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(printLines.output, id: \.self) { line in
                    Text(line)
                        .font(.system(.caption, design: .monospaced))
                }
            }
        }
        .onAppear {
            Task {
                await RsyncOutputCapture.shared.enable()
            }
        }
    }
}
```

## Core Components

### RsyncProcess

Main class for executing rsync commands. Handles process lifecycle, output streaming, and error detection.

**Key Methods:**
- `executeProcess()`: Launches the rsync process with configured arguments
- `init(arguments:hiddenID:handlers:usefilehandler:)`: Initialize with full configuration
- `init(arguments:handlers:filehandler:)`: Convenience initializer

### ProcessHandlers

Configuration struct containing all callback handlers for process events.

**Properties:**
- `processtermination`: Called when process completes
- `filehandler`: Called during file processing
- `rsyncpath`: Returns path to rsync executable
- `checklineforerror`: Validates output lines for errors
- `updateprocess`: Updates process reference
- `propogateerror`: Error propagation handler
- `logger`: Async logging handler
- `printlines`: Optional real-time output handler

### RsyncOutputCapture

Thread-safe actor for capturing and managing rsync output across the application.

**Key Methods:**
- `enable(writeToFile:)`: Enable output capture with optional file logging
- `disable()`: Disable output capture
- `captureLine(_:)`: Capture a single line
- `getAllLines()`: Retrieve all captured lines
- `getRecentLines(count:)`: Get the most recent N lines
- `clear()`: Clear captured output

### PrintLines

Observable model for SwiftUI integration, automatically updated by the output capture system.

### ParseRsyncOutput

Parser for rsync output that extracts statistics and metrics from completed rsync operations.

**Key Properties:**
- `numbersonly`: Parsed numerical statistics (files transferred, sizes, etc.)
- `stats`: Formatted statistics string
- `parseResult`: Complete result including errors and warnings
- Formatted properties for display (e.g., `formatted_filestransferred`, `formatted_totalfilesize`)

**Key Methods:**
- `init(_:_:)`: Initialize with rsync output lines and version type
- `rsyncver3(stringnumbersonly:)`: Parse rsync 3.x output
- `rsyncver2(stringnumbersonly:)`: Parse rsync 2.x/openrsync output

**Data Structures:**
- `NumbersOnly`: Structured numerical data from rsync output
- `ParseResult`: Complete parsing result with success/error status
- `VersionRsync`: Enum for rsync version (.ver3, .openrsync)

## Error Handling

The package defines custom errors through `RsyncError`:

- `executableNotFound`: Rsync binary not found
- `invalidExecutablePath`: Invalid path to rsync
- `processLaunchFailed`: Failed to launch process
- `outputEncodingFailed`: UTF-8 decoding failed

And `RsyncParseError` for output parsing:

- `missingRequiredField`: Required field missing from output
- `invalidNumberFormat`: Cannot parse number from field
- `invalidOutputFormat`: Malformed output
- `incompleteSummaryLine`: Incomplete sent/received/bytes line
- `divisionByZero`: Invalid bytes/sec value
- `unsupportedVersion`: Unknown rsync version format

## Advanced Features

### Dry Run Detection

The package automatically detects `--dry-run` arguments and adjusts progress reporting accordingly.

### Version Detection

Supports both rsync 3.x and openrsync with different output parsing strategies.

### Summary Detection

Automatically identifies the beginning of rsync's summary output to provide accurate progress reporting during real runs.

### File Output

Optionally write captured output to a file for debugging or audit purposes:

```swift
let logURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("rsync-output.log")
await RsyncOutputCapture.shared.enable(writeToFile: logURL)
```

### Parsing Rsync Output

After a sync completes, parse the output to extract statistics:

```swift
// Get the output from your completed rsync process
let output = rsyncProcess.output

// Parse for rsync 3.x
let parser = ParseRsyncOutput(output, .ver3)

// Check for parsing success
if parser.parseResult.isSuccess {
    // Access parsed statistics
    if let numbers = parser.numbersonly {
        print("Files transferred: \(numbers.filestransferred)")
        print("Total size: \(numbers.totalfilesize)")
        print("Created: \(numbers.numberofcreatedfiles)")
        print("Deleted: \(numbers.numberofdeletedfiles)")
        print("Data to sync: \(numbers.datatosynchronize)")
    }
    
    // Access formatted summary
    if let stats = parser.stats {
        print(stats) // e.g., "42 files : 15.23 MB in 3.45 seconds"
    }
    
    // Use pre-formatted properties for UI
    print("Files: \(parser.formatted_numberoffiles)")
    print("Size: \(parser.formatted_totalfilesize)")
} else {
    // Handle parsing errors
    for error in parser.parseResult.errors {
        print("Parse error: \(error.localizedDescription)")
    }
}

// Check for warnings (non-fatal issues)
if parser.parseResult.hasWarnings {
    for warning in parser.parseResult.warnings {
        print("Warning: \(warning)")
    }
}

// For openrsync or rsync 2.x
let parserV2 = ParseRsyncOutput(output, .openrsync)
```

### Using Parsed Data in SwiftUI

```swift
struct SyncResultView: View {
    let parser: ParseRsyncOutput
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let numbers = parser.numbersonly {
                LabeledContent("Files Transferred", value: parser.formatted_filestransferred)
                LabeledContent("Total Files", value: parser.formatted_numberoffiles)
                LabeledContent("Total Size", value: parser.formatted_totalfilesize)
                LabeledContent("Created", value: parser.formatted_numberofcreatedfiles)
                LabeledContent("Deleted", value: parser.formatted_numberofdeletedfiles)
                
                if let stats = parser.stats {
                    Text(stats)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if numbers.datatosynchronize {
                    Label("Changes detected", systemImage: "exclamationmark.circle")
                        .foregroundStyle(.orange)
                }
            }
            
            if parser.parseResult.hasWarnings {
                ForEach(parser.parseResult.warnings, id: \.self) { warning in
                    Text(warning)
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
        }
    }
}
```

## License

MIT

