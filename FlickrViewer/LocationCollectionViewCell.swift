import UIKit

class LocationCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: SearchImageView!
    
    override func prepareForReuse() {
        imageView.image = nil
    }
}
