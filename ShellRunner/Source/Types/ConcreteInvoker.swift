//
//  Copyright © 2018 Paul Samuels. All rights reserved.
//

import Foundation

class ConcreteInvoker: Invoker {
    func pipe(
        standardInput: FileHandle,
        standardOutput: FileHandle,
        standardError: FileHandle,
        shell: String,
        arguments: [String],
        reply: @escaping (Bool) -> Void
        ) {
        
        let subprocess = Process()
        subprocess.launchPath     = shell
        subprocess.arguments      = arguments
        subprocess.standardInput  = standardInput
        subprocess.standardOutput = standardOutput
        subprocess.standardError  = standardError
        subprocess.launch()
        subprocess.terminationHandler = {
            reply($0.terminationStatus == 0)
        }
    }
    
}
