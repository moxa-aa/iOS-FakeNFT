import Foundation

final class ObservableBox<Value> {
    private var listener: ((Value) -> Void)?

    var value: Value {
        didSet {
            listener?(value)
        }
    }

    init(_ value: Value) {
        self.value = value
    }

    func bind(listener: @escaping (Value) -> Void) {
        self.listener = listener
        listener(value)
    }
}
