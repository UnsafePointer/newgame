import UIKit
import Photos
import FanSabisuKitLite

class ViewController: UIViewController {

    let numberOfImages = 20
    var progress = 0
    var progressView: UIProgressView?
    let fetcher = Fetcher(session: URLSession.shared)

    override func loadView() {
        self.view = UIView(frame: .zero)
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.backgroundColor = .white
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(progressView)
        self.view.centerXAnchor.constraint(equalTo: progressView.centerXAnchor).isActive = true
        self.view.centerYAnchor.constraint(equalTo: progressView.centerYAnchor).isActive = true
        progressView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
        progressView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16).isActive = true
        self.progressView = progressView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == .authorized {
                self.fetch(with: 0)
            }
        }
    }

    func fetch(with index: Int) {
        if index >= numberOfImages {
            return
        }
        self.fetcher.fetchResults(for: "anime", filetype: "gif", imageSize: .medium, index: index) { (result) in
            if let result = try? result.resolve() {
                let downloader = MediaDownloader(session: URLSession.shared)
                for url in result.results {
                    downloader.downloadFile(with: url, completionHandler: { (result) in
                        if let url = try? result.resolve() {
                            print("Download finished, file at \(url)")
                        } else {
                            print("Download failed, error \(result)")
                        }
                        DispatchQueue.main.async {
                            self.proccess(progress: 1)
                        }
                    })
                }
                self.fetch(with: result.nextIndex)
            } else {
                print("Fetch failed, error \(result)")
                let pageSize = 10
                DispatchQueue.main.async {
                    self.proccess(progress: pageSize)
                }
                self.fetch(with: index + pageSize)
            }
        }
    }

    func proccess(progress: Int) {
        self.progress += progress
        let totalProgress = Float(self.progress) / Float(self.numberOfImages)
        self.progressView?.progress = totalProgress
        if totalProgress == 1 {
            let controller = UIAlertController(title: "Done", message: "Operation completed", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(controller, animated: true, completion: nil)
        }
    }

}

