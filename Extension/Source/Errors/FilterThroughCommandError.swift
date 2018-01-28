//
//  Copyright © 2018 Paul Samuels. All rights reserved.
//

import Foundation

enum FilterThroughCommandError: CustomNSError {
    case countNotFindCommand
    
    var errorUserInfo: [String : Any] {
        return [ NSLocalizedDescriptionKey : "The last line of the selection should be a comment with a command e.g. `// sort | uniq`" ]
    }
}
