//
//  LoginViewController.swift
//  PetFitTemp
//
//  Created by Sam.Lee on 8/7/24.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class StartViewController : BaseViewController {
    
    var logoImage : UIImageView!
    var startButton : UIButton!
    var sloganText: UILabel!
    var logoText: UILabel!
    var noticeLabel : UILabel!
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureConstraint()
        configureUtil()
    }
    
    override func configureUI() {
        super.configureUI()
        self.view.backgroundColor = .systemBackground
        
        logoImage = UIImageView(image: .logo)
        
        logoText = UILabel()
        logoText.text = "아환커"
        logoText.font = UIFont(name: "GyeonggiTitleM", size: 32)
        logoText.textColor = UIColor.mainLight
        logoText.textAlignment = .center
        
        sloganText = UILabel()
        sloganText.text = "아토피 환자들을 위한 커뮤니티"
        sloganText.font = UIFont.systemFont(ofSize: 14,weight: .semibold)
        sloganText.textColor = .gray
        sloganText.textAlignment = .center
        
        startButton = UIButton()
        startButton.setTitle("아환커 시작하기", for: .normal)
        startButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        startButton.layer.cornerCurve = .continuous
        startButton.layer.cornerRadius = 23
        startButton.clipsToBounds = true
        startButton.backgroundColor = UIColor.mainLight
        
        configureNoticeLabel()
    }
    
    func configureNoticeLabel() {
        noticeLabel = UILabel()
        
        noticeLabel.isUserInteractionEnabled = true
        let text = "시작하면 서비스 이용약관, 개인정보 처리방침, \n그리고 위치정보 이용약관에 동의하게 됩니다."
        let attributedString = NSMutableAttributedString(string: text)
        
        let termsRange = (text as NSString).range(of: "서비스 이용약관")
        let privacyRange = (text as NSString).range(of: "개인정보 처리방침")
        let locationRange = (text as NSString).range(of: "위치정보 이용약관")
        
        let baselineOffset: CGFloat = 0

        attributedString.addAttributes([
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .baselineOffset: baselineOffset
        ], range: termsRange)
        
        attributedString.addAttributes([
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .baselineOffset: baselineOffset
        ], range: privacyRange)
        
        attributedString.addAttributes([
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .baselineOffset: baselineOffset
        ], range: locationRange)
        
        let paragraphStyle = NSMutableParagraphStyle()
        let desiredLineHeight: CGFloat = 17
        paragraphStyle.minimumLineHeight = desiredLineHeight
        paragraphStyle.maximumLineHeight = desiredLineHeight
        
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        noticeLabel.attributedText = attributedString
        noticeLabel.font = UIFont.systemFont(ofSize: 12)
        noticeLabel.textColor = .lightGray
        noticeLabel.numberOfLines = 0
        noticeLabel.textAlignment = .center
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        noticeLabel.addGestureRecognizer(tapGesture)
    }
    
    override func configureConstraint() {
        super.configureConstraint()
        [sloganText, logoText,logoImage,startButton,noticeLabel].forEach{
            self.view.addSubview($0!)
            $0?.translatesAutoresizingMaskIntoConstraints = false
        }
        startButton.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(84)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(66)
        }
        logoImage.snp.makeConstraints{
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(200)
            $0.size.equalTo(64)
            $0.centerX.equalToSuperview()
        }
        logoText.snp.makeConstraints{
            $0.top.equalTo(logoImage.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
        sloganText.snp.makeConstraints{
            $0.top.equalTo(logoText.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
        noticeLabel.snp.makeConstraints{
            $0.top.equalTo(startButton.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    override func configureUtil() {
        super.configureUtil()
        startButton.rx.tap.subscribe(onNext: { [weak self] in
            let nextVC = LoginViewController()
            let navVC = UINavigationController(rootViewController: nextVC)
            navVC.modalPresentationStyle = .fullScreen
            self?.present(navVC, animated: true)
        }).disposed(by: disposeBag)
    }
    @objc func handleTap(gesture: UITapGestureRecognizer) {
        guard let text = noticeLabel.attributedText?.string else { return }
        let termsRange = (text as NSString).range(of: "서비스 이용약관")
        let privacyRange = (text as NSString).range(of: "개인정보 처리방침")
        let locationRange = (text as NSString).range(of: "위치정보 이용약관")
        
        let tapLocation = gesture.location(in: noticeLabel)
        
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: noticeLabel.bounds.size)
        let textStorage = NSTextStorage(attributedString: noticeLabel.attributedText!)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = noticeLabel.lineBreakMode
        textContainer.maximumNumberOfLines = noticeLabel.numberOfLines
        
        let index = layoutManager.characterIndex(for: tapLocation, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        if NSLocationInRange(index, termsRange) {
            print("서비스 이용약관 클릭됨")
        } else if NSLocationInRange(index, privacyRange) {
            print("개인정보 처리방침 클릭됨")
        } else if NSLocationInRange(index, locationRange) {
            print("위치정보 이용약관 클릭됨")
        }
    }
}
