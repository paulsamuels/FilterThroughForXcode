//
//  Copyright © 2018 Paul Samuels. All rights reserved.
//

import Foundation

let listener = NSXPCListener.service()
let delegate = XPCDelegate()
listener.delegate = delegate
listener.resume()
