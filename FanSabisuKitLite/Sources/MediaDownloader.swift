import Foundation
import Photos

public enum MediaDownloaderError: Error {
    case invalidURL
    case requestFailed
    case tooManyRequests
}

public class MediaDownloader {
    
    let session: URLSession
    
    public init(session: URLSession) {
        self.session = session
    }
    
    public func downloadFile(with url: URL, completionHandler: @escaping (Result<URL>) -> Void) {
        let dataTask = session.downloadTask(with: url) { (location, response, error) in
            if let error = error {
                return completionHandler(Result.failure(error))
            }
            let temporaryDirectoryFilePath = URL(fileURLWithPath: NSTemporaryDirectory())
            guard let response = response else {
                return completionHandler(Result.failure(MediaDownloaderError.requestFailed))
            }
            guard let location = location else {
                return completionHandler(Result.failure(MediaDownloaderError.requestFailed))
            }
            let suggestedFilename: String
            if let value = response.suggestedFilename {
                suggestedFilename = value
            } else {
                suggestedFilename = url.lastPathComponent
            }
            let destinationUrl = temporaryDirectoryFilePath.appendingPathComponent(suggestedFilename)
            if FileManager().fileExists(atPath: destinationUrl.path) {
                print("MediaDownloader: The file \(suggestedFilename) already exists at path \(destinationUrl.path)")
            } else {
                let data = try? Data(contentsOf: location)
                try? data?.write(to: destinationUrl, options: Data.WritingOptions.atomic)
            }
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: destinationUrl)
            }) { (success, error) in
                let result: Result<URL>
                if let error = error {
                    result = Result.failure(error)
                } else {
                    result = Result.success(destinationUrl)
                }
                DispatchQueue.main.async { completionHandler(result) }
            }
        }
        dataTask.resume()
    }

}
