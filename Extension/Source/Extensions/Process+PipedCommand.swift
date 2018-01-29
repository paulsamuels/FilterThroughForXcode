//
//  Copyright © 2018 Paul Samuels. All rights reserved.
//

import Foundation

extension Process {
    static func pipe(lines: [String], into command: Command, completion: @escaping (Result<[String]>) -> Void) {
        
        let userCommand = Process()
        userCommand.launchPath = command.launchPath
        userCommand.arguments  = command.arguments
        
        let (standardInputPipe, standardOutPipe, standardErrorPipe) = (Pipe(), Pipe(), Pipe())
        userCommand.standardInput  = standardInputPipe
        userCommand.standardOutput = standardOutPipe
        userCommand.standardError  = standardErrorPipe
        userCommand.terminationHandler = { process in
            guard process.terminationStatus == 0 else {
                let error = String(data: standardErrorPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
                return completion(.failure(PipeError.commandFailed(error)))
            }
            
            let standardOut = String(data: standardOutPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""

            completion(.success(standardOut.components(separatedBy: "\n").map { $0 + "\n" }))
        }
        userCommand.launch()
        
        let writeHandle = standardInputPipe.fileHandleForWriting
        lines.flatMap({ $0.data(using: .utf8)! }).forEach(writeHandle.write)
        writeHandle.closeFile()
    }
}
