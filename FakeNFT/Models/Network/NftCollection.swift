import Foundation

struct NftCollection: Decodable {
    let id: String
    let name: String
    let coverImageUrlString: String
    let description: String
    let author: String
    let websiteUrlString: String
    let nfts: [String]

    enum CodingKeys: String, CodingKey {
        case id, name, description, author, nfts
        case coverImageUrlString = "cover"
        case websiteUrlString = "website"
    }
}
