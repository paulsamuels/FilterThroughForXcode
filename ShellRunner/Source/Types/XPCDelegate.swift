//
//  Copyright © 2018 Paul Samuels. All rights reserved.
//

import Foundation

class XPCDelegate: NSObject, NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: Invoker.self)
        newConnection.exportedObject    = ConcreteInvoker()
        newConnection.resume()
        return true
    }
}
