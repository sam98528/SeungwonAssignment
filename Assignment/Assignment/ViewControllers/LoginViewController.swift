//
//  PersonalAuthViewController.swift
//  PetFitTemp
//
//  Created by Sam.Lee on 7/30/24.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class LoginViewController : BaseViewController {
    var greetingLabelL : UILabel!
    var greetingLabelS : UILabel!
    var nickNameField: UITextField!
    var warningLabel: UILabel!
    var nextButton : UIButton!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureConstraint()
        configureCloseButton()
        bindTextField()
        configureUtil()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nickNameField.becomeFirstResponder()
    }
    
    override func configureUI() {
        super.configureUI()
        
        self.view.backgroundColor = .systemBackground
        
        greetingLabelL = UILabel()
        let text = "안녕하세요! \n아이디를 입력해주세요."
        let attributedString = NSMutableAttributedString(string: text)
        
        let paragraphStyle = NSMutableParagraphStyle()
        let desiredLineHeight: CGFloat = 36 // 원하는 라인 높이 설정
        paragraphStyle.minimumLineHeight = desiredLineHeight
        paragraphStyle.maximumLineHeight = desiredLineHeight
        
        // 전체 텍스트에 대한 스타일 적용
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        greetingLabelL.attributedText = attributedString
        greetingLabelL.numberOfLines = 2
        greetingLabelL.textAlignment = .left
        greetingLabelL.lineBreakMode = .byWordWrapping
        greetingLabelL.font = UIFont.systemFont(ofSize: 24,weight: .semibold)
        
        greetingLabelS = UILabel()
        greetingLabelS.text = "가입을 한적이 없으시다면, 가입할 아이디를 입력해주세요."
        greetingLabelS.textColor = .deHighLight
        greetingLabelS.font = UIFont.systemFont(ofSize: 14)
        
        nickNameField = UITextField()
        nickNameField.delegate = self
        nickNameField.keyboardType = .default
        nickNameField.placeholder = "아이디"
        nickNameField.font = UIFont.systemFont(ofSize: 24,weight: .semibold)
        nickNameField.clearButtonMode = .whileEditing
        nickNameField.tintColor = .black
        nickNameField.autocapitalizationType = .none
        nickNameField.autocorrectionType = .no
        
        nextButton = UIButton()
        nextButton.setTitle("아이디 로그인하기", for: .normal)
        nextButton.isEnabled = false
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        nextButton.layer.cornerCurve = .continuous
        nextButton.layer.cornerRadius = 23
        nextButton.clipsToBounds = true
        nextButton.backgroundColor = .gray
        
        warningLabel = UILabel()
        warningLabel.text = "영어와 숫자 조합만 사용할 수 있어요. (최소 5자, 최대 12자)"
        warningLabel.font = UIFont.systemFont(ofSize: 14)
        warningLabel.textColor = UIColor(hexCode: "FF3B30")
    }
    
    
    override func configureConstraint() {
        super.configureConstraint()
        [greetingLabelL, greetingLabelS, nickNameField, nextButton,warningLabel].forEach{
            self.view.addSubview($0!)
            $0?.translatesAutoresizingMaskIntoConstraints = false
        }
        
        greetingLabelL.snp.makeConstraints{
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(72)
        }
        
        greetingLabelS.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(greetingLabelL.snp.bottom).offset(6)
        }
        nickNameField.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(greetingLabelS.snp.bottom).offset(32)
            $0.height.equalTo(36)
        }
        warningLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.top.equalTo(nickNameField.snp.bottom).offset(4)
        }
        nextButton.snp.makeConstraints{
            $0.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top).inset(-16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(66)
        }
    }
    
    func bindTextField() {
        nickNameField.rx.text.orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance) // 1초 동안 텍스트 변경 없을 시
            .distinctUntilChanged() // 중복된 텍스트 무시
            .subscribe(onNext: { [weak self] newValue in
                guard let self = self else { return }
                
                // 닉네임 길이 검사
                if newValue.count >= 13 {
                    self.shakeTextField()
                    self.nickNameField.text = String(newValue.prefix(13))
                    self.warningLabel.text = "최대 12자까지만 입력 가능해요."
                    self.nextButton.backgroundColor = .gray
                    nextButton.isEnabled = false
                } else if newValue.count < 5 || !self.isValidNickname(newValue) || self.isOnlyNumber(newValue){
                    self.warningLabel.text = "영어와 숫자 조합만 사용할 수 있어요. (최소 5자, 최대 12자)"
                    self.warningLabel.textColor = UIColor(hexCode: "FF3B30")
                    self.nextButton.backgroundColor = .gray
                    nextButton.isEnabled = false
                }else {
                    self.warningLabel.text = ""
                    self.nextButton.backgroundColor = .mainLight
                    self.nextButton.isEnabled = true
                }
            })
            .disposed(by: disposeBag)
    }
    
    func isValidNickname(_ nickname: String) -> Bool {
        let regex = "^[a-z0-9]*$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: nickname)
    }
    
    func isOnlyNumber(_ nickname: String) -> Bool {
        let regex = "^[0-9]*$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: nickname)
    }
    
    func checkNicknameAvailability(_ nickname: String) -> Observable<Bool> {
        // 서버와 통신하여 닉네임 사용 가능 여부 확인
        return Observable<Bool>.just(true).delay(.milliseconds(500), scheduler: MainScheduler.instance)
    }
    

    func shakeTextField() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.duration = 0.1
        animation.values = [
            NSValue(cgPoint: CGPoint(x: nickNameField.center.x, y: nickNameField.center.y-5)),
            NSValue(cgPoint: CGPoint(x: nickNameField.center.x, y: nickNameField.center.y+5))
        ]
        animation.autoreverses = true
        animation.repeatCount = 1
        nickNameField.layer.add(animation, forKey: "position")
    }
    
    override func configureUtil() {
        super.configureUtil()
        nextButton.rx.tap.subscribe(onNext: { [weak self] in
//            let nextVC = AuthViewController()
//            nextVC.modalPresentationStyle = .fullScreen
//            nextVC.phoneNumber = String(self?.telNumField.text ?? "")
//            self?.navigationController?.pushViewController(nextVC, animated: true)
        }).disposed(by: disposeBag)
    }
}


extension LoginViewController : UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 현재 텍스트와 새로운 텍스트 결합
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        // 12자 초과 시 흔들림 효과 및 입력 방지
        if newText.count > 13{
            shakeTextField()
            self.warningLabel.text = "최대 12자까지만 입력 가능해요."
            self.warningLabel.textColor = UIColor(hexCode: "FF3B30")
            return false
        }else if !isValidNickname(newText){
            shakeTextField()
            self.warningLabel.text = "영어와 숫자 조합만 사용할 수 있어요. (최소 5자, 최대 12자)"
            self.warningLabel.textColor = UIColor(hexCode: "FF3B30")
            return false
        }else{
            return true
        }
    }
}
