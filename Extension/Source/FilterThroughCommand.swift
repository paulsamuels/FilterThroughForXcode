//
//  Copyright © 2018 Paul Samuels. All rights reserved.
//

import Foundation
import XcodeKit
import ShellRunner

/// The `FilterThroughCommand` is used for processing lines through a command line tool.
///
/// This is achieved by taking the last line in the current selection, which should be a comment
/// with a valid shell command, and piping the proceeding lines through an invocation of this command.
class FilterThroughCommand: NSObject, XCSourceEditorCommand {
    
    private let connection: NSXPCConnection = {
        let connection = NSXPCConnection(serviceName: "com.paul-samuels.filter-through.shell-runner")
        connection.remoteObjectInterface = NSXPCInterface(with: Invoker.self)
        connection.resume()
        return connection
    }()
    
    deinit {
        connection.invalidate()
    }
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        guard let selection = invocation.buffer.selections.firstObject as? XCSourceTextRange else {
            return completionHandler(PipeError.noSelection)
        }
        
        var lines = invocation.buffer.lines
        
        invocation.cancellationHandler = {
            lines = NSMutableArray()
            completionHandler(nil)
        }
        
        // It appears that Xcode returns a selection that can possibly include the last line even if it's just a new line. This conflicts
        // with what `lines` actually returns as it appears to filter out the last new line. This is why there is a bounds check rather
        // than just indexing straigh into the collection.
        let range = NSRange(location: selection.start.line, length: min((selection.end.line - selection.start.line) + 1, lines.count))
        
        let selectedLines = lines.subarray(with: range).map { $0 as! String }
        
        do {
            guard let lastLine = selectedLines.last else {
                return completionHandler(FilterThroughCommandError.couldNotFindCommand)
            }
            
            guard let command = try Command(line: lastLine) else {
                fatalError("Command thows if it can't be created.")
            }
            
            execute(command: command, on: Array(selectedLines.dropLast())) { result in
                switch result {
                case .success(let replacementLines):
                    lines.removeObjects(in: range)
                    replacementLines.reversed().forEach { lines.insert($0, at: selection.start.line) }
                    completionHandler(nil)
                    
                case .failure(let error):
                    completionHandler(error)
                }
            }
            
        } catch {
            completionHandler(error)
        }
        
    }
    
}

private extension FilterThroughCommand {
    func execute(command: Command, on lines: [String], completion: @escaping (Result<[String]>) -> Void) {
        guard let shellRunner = connection.remoteObjectProxyWithErrorHandler({ error in print(error) }) as? Invoker else {
            return completion(.failure(FilterThroughCommandError.couldNotConnectToXPCService))
        }
        
        let (standardInput, standardOutput, standardError) = (Pipe(), Pipe(), Pipe())
        var (standardOutputBuffer, standardErrorBuffer) = (Data(), Data())
        
        standardOutput.fileHandleForReading.readabilityHandler = {
            standardOutputBuffer.append($0.availableData)
        }
        
        standardError.fileHandleForReading.readabilityHandler = {
            standardErrorBuffer.append($0.availableData)
        }
        
        shellRunner.pipe(
            standardInput: standardInput.fileHandleForReading,
            standardOutput: standardOutput.fileHandleForWriting,
            standardError: standardError.fileHandleForWriting,
            shell: command.launchPath,
            arguments: command.arguments) { success in
                if success {
                    standardOutput.fileHandleForWriting.closeFile()
                    if let replacement = String(data: standardOutputBuffer, encoding: .utf8) {
                        completion(.success(replacement.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "\n")))
                    }
                } else {
                    standardError.fileHandleForWriting.closeFile()
                    if let errorText = String(data: standardErrorBuffer, encoding: .utf8) {
                        completion(.failure(FilterThroughCommandError.shellError(errorText)))
                    }
                }
                
                completion(.failure(FilterThroughCommandError.noOutput))
        }
        
        let standardInWriterHandle = standardInput.fileHandleForWriting
        
        lines.flatMap({ $0.data(using: .utf8) }).forEach(standardInWriterHandle.write)
        
        standardInWriterHandle.closeFile()
    }
}
