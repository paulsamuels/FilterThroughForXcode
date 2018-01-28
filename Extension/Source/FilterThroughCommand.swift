//
//  Copyright © 2018 Paul Samuels. All rights reserved.
//

import Foundation
import XcodeKit

/// The `FilterThroughCommand` is used for processing lines through a command line tool.
///
/// This is achieved by taking the last line in the current selection, which should be a comment
/// with a valid shell command, and piping the proceeding lines through an invocation of this command.
class FilterThroughCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        guard let selection = invocation.buffer.selections.firstObject as? XCSourceTextRange else {
            return completionHandler(PipeError.noSelection)
        }
        
        let lines = invocation.buffer.lines
        
        // It appears that Xcode returns a selection that can possibly include the last line even if it's just a new line. This conflicts
        // with what `lines` actually returns as it appears to filter out the last new line. This is why there is a bounds check rather
        // than just indexing straigh into the collection.
        let range = NSRange(location: selection.start.line, length: min((selection.end.line - selection.start.line) + 1, lines.count))
        
        let selectedLines = lines.subarray(with: range).map { $0 as! String }
        
        do {
            guard let command = try Command(line: selectedLines.last!) else {
                return completionHandler(nil)
            }
            
            Process.pipe(lines: Array(selectedLines.dropLast()), into: command) { result in
                switch result {
                case .success(let filteredLines):
                    lines.removeObjects(in: range)
                    filteredLines.dropLast().reversed().forEach { lines.insert($0, at: selection.start.line) }
                    completionHandler(nil)
                case .failure(let error):
                    completionHandler(error)
                }
            }
        } catch {
            return completionHandler(FilterThroughCommandError.countNotFindCommand)
        }
        
    }
    
}
