//
//  Copyright © 2018 Paul Samuels. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T)
    case failure(Error)
}
