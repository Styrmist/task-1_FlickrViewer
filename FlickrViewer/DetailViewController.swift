import UIKit

class DetailViewController: UIViewController, UIScrollViewDelegate {
    
    var imageLink = ""

    @IBOutlet weak var detailScrollView: UIScrollView!
    @IBOutlet weak var detailImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailScrollView.delegate = self
        detailScrollView.minimumZoomScale = 1.0
        detailScrollView.maximumZoomScale = 4.0
        detailScrollView.contentSize = .init(width: 2000, height: 2000)
        updateZoomFor(size: view.bounds.size)
        detailImageView.load(url: URL(string: imageLink)!)
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return detailImageView
    }
    
    func updateZoomFor(size: CGSize){
        let widthScale = size.width / detailImageView.bounds.width
        let heightScale = size.height / detailImageView.bounds.height
        let scale = min(widthScale,heightScale)
        detailScrollView.minimumZoomScale = scale
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
