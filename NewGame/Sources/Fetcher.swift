import Foundation
import FanSabisuKitLite

enum ImageSize: String {
    case icon = "icon"
    case small = "small"
    case medium = "medium"
    case large = "large"
    case xlarge = "xlarge"
    case xxlarge = "xxlarge"
    case huge = "huge"
}

enum FetcherError: Error {
    case CouldNotBuildURL
    case RequestFailed
    case CouldNotParseResponse
}

struct FetchResult {
    let totalResults: Int
    let nextIndex: Int
    let results: [URL]

    init?(response: Data) {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: response, options: .allowFragments) as? Dictionary<String, Any> else {
            return nil
        }
        let queries = jsonObject?["queries"] as? Dictionary<String, Any>
        guard let nextPage = queries?["nextPage"] as? Array<Dictionary<String, Any>> else {
            return nil
        }
        guard let totalResults = nextPage.first?["totalResults"] as? String,
            let nextIndex = nextPage.first?["startIndex"] as? Int else {
            return nil
        }

        guard let total = Int(totalResults) else {
            return nil
        }

        self.totalResults = total
        self.nextIndex = nextIndex

        guard let items = jsonObject?["items"] as? Array<Dictionary<String, Any>> else {
            return nil
        }

        var results = [URL]()

        for item in items {
            guard let result = item["link"] as? String else {
                return nil
            }
            guard let url = URL(string: result) else {
                return nil
            }
            results.append(url)
        }

        self.results = results
    }
}

class Fetcher {

    let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func fetchResults(for searchTerm: String, filetype: String, imageSize: ImageSize, index: Int?, completionHandler: @escaping (Result<FetchResult>) -> Void) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.googleapis.com"
        components.path = "/customsearch/v1"
        var query = [URLQueryItem]()
        query.append(URLQueryItem(name: "q", value: searchTerm))
        query.append(URLQueryItem(name: "cx", value: GoogleCustomSearchCredentials.engineId))
        query.append(URLQueryItem(name: "fileType", value: filetype))
        query.append(URLQueryItem(name: "imageSize", value: imageSize.rawValue))
        query.append(URLQueryItem(name: "searchType", value: "image"))
        query.append(URLQueryItem(name: "key", value: GoogleCustomSearchCredentials.key))
        if let index = index {
            if index != 0 {
                query.append(URLQueryItem(name: "start", value: String(index)))
            }
        }
        components.queryItems = query
        guard let url = components.url else {
            return completionHandler(Result.failure(FetcherError.CouldNotBuildURL))
        }
        let task = session.dataTask(with: url) { (data, response, error) in
            if (response as? HTTPURLResponse)?.statusCode != 200 {
                print("\(String(data: data!, encoding: .utf8))")
                return completionHandler(Result.failure(FetcherError.RequestFailed))
            }
            if let error = error {
                return completionHandler(Result.failure(error))
            }
            guard let data = data else {
                return completionHandler(Result.failure(FetcherError.RequestFailed))
            }
            if let results = FetchResult(response: data) {
                return completionHandler(Result.success(results))
            } else {
                return completionHandler(Result.failure(FetcherError.CouldNotParseResponse))
            }

        }
        task.resume()
    }

}
