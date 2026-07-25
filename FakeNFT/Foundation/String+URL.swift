import Foundation

extension String {

    // API URL strings may contain Cyrillic, so fall back to percent encoding
    var asURL: URL? {
        if let url = URL(string: self) { return url }
        return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            .flatMap(URL.init(string:))
    }
}
