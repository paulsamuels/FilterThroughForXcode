//
//  Copyright © 2018 Paul Samuels. All rights reserved.
//

import Foundation

enum FilterThroughCommandError: CustomNSError {
    case couldNotFindCommand
    case couldNotConnectToXPCService
    case noOutput
    case shellError(String)
    
    var errorUserInfo: [String : Any] {
        let description: String
        
        switch self {
        case .couldNotFindCommand:
            description = "The last line of the selection should be a comment with a command e.g. `// sort | uniq`."
        case .couldNotConnectToXPCService:
            description = "Issue with XPC connection - not something that is user resolveable - sorry."
        case .noOutput:
            description = "Shell command had no output"
        case .shellError(let error):
            description = error
        }
        
        return [ NSLocalizedDescriptionKey : description ]
    }
}
