//: [Previous](@previous)

import Foundation

class BitcoinPriceMonitor {
    var price: Double
    var timer: Timer?
    var priceHandler: (Double) -> Void

    init(
        price: Double = .zero,
        timer: Timer? = nil,
        priceHandler: @escaping (Double) -> Void = { _ in }
    ) {
        self.price = price
        self.timer = timer
        self.priceHandler = priceHandler
    }

    @objc func getPrice() {
        priceHandler(.random(in: 20000...400000))
    }

    func startUpdating() {
        timer = .scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(getPrice), userInfo: nil, repeats: true)
    }

    func stopUpdating() {
        timer?.invalidate()
    }
}

/*
let monitor = BitcoinPriceMonitor()
monitor.priceHandler = {
    print($0)
}

monitor.startUpdating()
 */

let priceStream = AsyncStream(Double.self) { continuation in
    let monitor = BitcoinPriceMonitor()
    monitor.priceHandler = {
        continuation.yield($0)
    }
    monitor.startUpdating()
}

Task {
    for await price in priceStream {
        print(price)
    }
}

//: [Next](@next)
