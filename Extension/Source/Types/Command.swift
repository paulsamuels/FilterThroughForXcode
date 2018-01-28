//
//  Copyright © 2018 Paul Samuels. All rights reserved.
//

import Foundation

/// A `Command` breaks apart a commented line that contains a a shell command
/// into the relevant pieces required for invocation.
@objc final class Command: NSObject {
    private let requiredPrefix = "//"
    
    let arguments: [String]
    let launchPath: String
    
    init?(line: String) throws {
        let strippedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard strippedLine.hasPrefix(requiredPrefix) else {
            throw CommandError.missingPrefix
        }
        
        let command = String(strippedLine.dropFirst(requiredPrefix.count))
        
        arguments = [ "-c", command.trimmingCharacters(in: .whitespacesAndNewlines) ]
        launchPath = "/bin/bash"
    }
}
