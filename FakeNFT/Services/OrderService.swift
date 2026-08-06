import Foundation

// stub for the cart, replaced by the shared OrderService from the Cart epic
protocol OrderService {
    func loadOrder(completion: @escaping (Result<[String], Error>) -> Void)
    func updateOrder(_ nftIds: [String], completion: @escaping (Result<[String], Error>) -> Void)
}

final class OrderServiceStub: OrderService {

    private var nftIds: Set<String> = []

    func loadOrder(completion: @escaping (Result<[String], Error>) -> Void) {
        DispatchQueue.main.async { completion(.success(Array(self.nftIds))) }
    }

    func updateOrder(_ nftIds: [String], completion: @escaping (Result<[String], Error>) -> Void) {
        DispatchQueue.main.async {
            self.nftIds = Set(nftIds)
            completion(.success(Array(self.nftIds)))
        }
    }
}
