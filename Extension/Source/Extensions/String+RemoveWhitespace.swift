//
//  Copyright © 2018 Paul Samuels. All rights reserved.
//

import Foundation

extension String {
    func removingTrailingWhitespace() -> String {
        return replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
    }
}
