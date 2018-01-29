//
//  Copyright © 2018 Paul Samuels. All rights reserved.
//

import Foundation

@objc
public protocol Invoker {
    func pipe(
        standardInput: FileHandle,
        standardOutput: FileHandle,
        standardError: FileHandle,
        shell: String,
        arguments: [String],
        reply: @escaping (Bool) -> Void
    )
}
