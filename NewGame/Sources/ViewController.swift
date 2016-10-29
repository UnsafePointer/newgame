import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let fetcher = Fetcher(session: URLSession.shared)
        fetcher.fetchResults(for: "anime", filetype: "gif", imageSize: .medium, index: nil) { (result) in
            print("\(result)")
        }
    }

}

