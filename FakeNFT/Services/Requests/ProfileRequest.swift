import Foundation

struct ProfileRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }
}

struct ProfileDto: Dto {
    let name: String?
    let avatar: String?
    let description: String?
    let website: String?
    let nfts: [String]?
    let likes: [String]?

    func asDictionary() -> [String: String] {
        var dict: [String: String] = [:]
        if let name = name { dict["name"] = name }
        if let avatar = avatar { dict["avatar"] = avatar }
        if let description = description { dict["description"] = description }
        if let website = website { dict["website"] = website }
        if let nfts = nfts { dict["nfts"] = nfts.joined(separator: ",") }
        if let likes = likes { dict["likes"] = likes.joined(separator: ",") }
        return dict
    }
}

struct ProfilePutRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }
    var httpMethod: HttpMethod = .put
    var dto: Dto?

    init(dto: ProfileDto) {
        self.dto = dto
    }
}
