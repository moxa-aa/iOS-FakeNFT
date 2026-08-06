import Foundation

struct Nft: Decodable {
    let id: String
    let name: String
    let images: [URL]
    let rating: Int
    let description: String
    let price: Double
    let author: URL

    var imagesUrls: [URL] {
        return images
    }

    enum CodingKeys: String, CodingKey {
        case id, name, images, rating, description, price, author
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "NFT"
        images = (try? container.decode([URL].self, forKey: .images)) ?? []
        rating = try container.decodeIfPresent(Int.self, forKey: .rating) ?? 0
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        price = try container.decodeIfPresent(Double.self, forKey: .price) ?? 0.0

        if let authorUrl = try? container.decode(URL.self, forKey: .author) {
            author = authorUrl
        } else if let authorString = try? container.decode(String.self, forKey: .author),
                  let authorUrl = URL(string: authorString) {
            author = authorUrl
        } else {
            author = URL(string: "https://yandex.ru")!
        }
    }

    init(id: String, name: String, images: [URL], rating: Int, description: String, price: Double, author: URL) {
        self.id = id
        self.name = name
        self.images = images
        self.rating = rating
        self.description = description
        self.price = price
        self.author = author
    }
}
