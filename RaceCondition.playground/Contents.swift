import UIKit

class BankAccount {
    var balance: Double
    let lock = NSLock()

    init(balance: Double) {
        self.balance = balance
    }

    func withdraw(_ amount: Double) -> Double? {
        if balance >= amount {
            let processingTime: UInt32 = .random(in: 1...3)
            print("Processing for \(processingTime) seconds")
            sleep(processingTime)
            print("Withdrawing \(amount) from account")
            balance -= amount
            print("New balance \(balance)")
            return amount
        }
        print("Cannot withdraw \(amount) since balance is \(balance)")
        return nil
    }

    func threadSafeWithdraw(_ amount: Double) -> Double? {
        // 3. Other way to solve the issue is by locking the thread to avoid the race condition
        lock.lock()
        if balance >= amount {
            let processingTime: UInt32 = .random(in: 1...3)
            print("Processing for \(processingTime) seconds")
            sleep(processingTime)
            print("Withdrawing \(amount) from account")
            balance -= amount
            print("New balance \(balance)")
            // 3. But always make sure you unlock the thread since you might need it next time
            lock.unlock()
            return amount
        }
        print("Cannot withdraw \(amount) since balance is \(balance)")
        lock.unlock()
        return nil
    }
}

let account = BankAccount(balance: 500)
/*
 1. The issue is that there's a race condition because they will pass the check as they went in at the same time but required diff amount of time to process ending up run both without checking again
let queue = DispatchQueue(label: "ConcurrentWithdrawingQueue", attributes: .concurrent)
 */

// 2. One way to avoid it is to have a serial queue that will ensure everything is in sequence but this might require more time
let queue = DispatchQueue(label: "SerialWithdrawingQueue")

queue.async {
    print(account.withdraw(500))
}

queue.async {
    print(account.withdraw(300))
}

// https://medium.com/swiftcairo/avoiding-race-conditions-in-swift-9ccef0ec0b26
