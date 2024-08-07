
import UIKit

// BaseViewController
class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configureUI(){}
    func configureConstraint(){}
    func configureUtil(){}
    
    func configureBackButton() {
        let closeButton = UIBarButtonItem(image: UIImage.chevronLeft, style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func configureCloseButton() {
        let closeButton = UIBarButtonItem(image: UIImage.x, style: .plain, target: self, action: #selector(closeButtonTapped))
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    @objc func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
