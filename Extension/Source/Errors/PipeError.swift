//
//  Copyright © 2018 Paul Samuels. All rights reserved.
//

import Foundation

enum PipeError: CustomNSError {
    case commandFailed(String)
    case noSelection
        
    var errorUserInfo: [String : Any] {
        let description: String
        
        switch self {
        case .commandFailed(let error):
            description = "The command failed with error: \(error)"
        case .noSelection:
            description = "No text is selected"
        }
        
        return [ NSLocalizedDescriptionKey : description ]
    }
}
