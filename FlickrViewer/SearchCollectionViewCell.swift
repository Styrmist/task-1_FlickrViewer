import UIKit

class SearchCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: SearchImageView!

    override func prepareForReuse() {
        imageView.image = nil
    }
}
