//
//  MainViewController.swift
//  Assignment
//
//  Created by Sam.Lee on 8/7/24.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class MainViewController : BaseViewController {
    
    var profileImage : UIImageView!
    var logOutButton : UIButton!
    var WelcomeText: UILabel!
    var nickNameText: UILabel!
    var noticeLabel : UILabel!
    var user : User?
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
        
        profileImage = UIImageView(image: UIImage(systemName: "person.crop.circle"))
        profileImage.tintColor = .mainLight
        
        nickNameText = UILabel()
        nickNameText.text = "\(String(self.user?.nickName ?? ""))님"
        nickNameText.font = UIFont(name: "GyeonggiTitleM", size: 32)
        nickNameText.textColor = UIColor.mainLight
        nickNameText.textAlignment = .center
        
        WelcomeText = UILabel()
        WelcomeText.text = "반갑습니다!"
        WelcomeText.font = UIFont.systemFont(ofSize: 14,weight: .semibold)
        WelcomeText.textColor = .gray
        WelcomeText.textAlignment = .center
        
        logOutButton = UIButton()
        logOutButton.setTitle("로그아웃 하기", for: .normal)
        logOutButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        logOutButton.layer.cornerCurve = .continuous
        logOutButton.layer.cornerRadius = 23
        logOutButton.clipsToBounds = true
        logOutButton.backgroundColor = UIColor.mainLight
        
        configureNoticeLabel()
    }
    
    func configureNoticeLabel() {
        noticeLabel = UILabel()
        
        noticeLabel.isUserInteractionEnabled = true
        let text = "회원탈퇴"
        let attributedString = NSMutableAttributedString(string: text)
        
        let termsRange = (text as NSString).range(of: "회원탈퇴")
        
        let baselineOffset: CGFloat = 0
        
        attributedString.addAttributes([
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .baselineOffset: baselineOffset
        ], range: termsRange)
        
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
        [WelcomeText, nickNameText,profileImage,logOutButton,noticeLabel].forEach{
            self.view.addSubview($0!)
            $0?.translatesAutoresizingMaskIntoConstraints = false
        }
        logOutButton.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(84)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(66)
        }
        profileImage.snp.makeConstraints{
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(200)
            $0.size.equalTo(64)
            $0.centerX.equalToSuperview()
        }
        nickNameText.snp.makeConstraints{
            $0.top.equalTo(profileImage.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
        WelcomeText.snp.makeConstraints{
            $0.top.equalTo(nickNameText.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
        noticeLabel.snp.makeConstraints{
            $0.top.equalTo(logOutButton.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    override func configureUtil() {
        super.configureUtil()
        logOutButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.logout()
        }).disposed(by: disposeBag)
    }
    
    func logout() {
        user = nil
        clearLoginInfo {
            let startViewController = StartViewController()
            let navigationController = UINavigationController(rootViewController: startViewController)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
        }
    }

    @objc func handleTap(gesture: UITapGestureRecognizer) {
        guard let text = noticeLabel.attributedText?.string else { return }
        let termsRange = (text as NSString).range(of: "회원탈퇴")
        
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
            showDeleteAccountConfirmation()
        }
    }
    
    func showDeleteAccountConfirmation() {
        let alertController = UIAlertController(title: "회원탈퇴", message: "정말로 회원탈퇴하시겠습니까?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "탈퇴", style: .destructive) { _ in
            self.deleteAccount()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func deleteAccount() {
        guard let id = self.user?.id else {return}
        if CoreDataManager.shared.deleteUser(for: id) {
            clearLoginInfo {
                let startViewController = StartViewController()
                let navigationController = UINavigationController(rootViewController: startViewController)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true, completion: nil)
            }
        }
    }
}
