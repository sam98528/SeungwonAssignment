//
//  NickNameViewController.swift
//  Assignment
//
//  Created by Sam.Lee on 8/7/24.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

class NickNameViewController : BaseViewController {
    var greetingLabelL : UILabel!
    var greetingLabelS : UILabel!
    var nickNameField: UITextField!
    var warningLabel: UILabel!
    var nextButton : UIButton!
    var user : User?
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureConstraint()
        configureBackButton()
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
        let text = "마지막 단계이에요! \n사용하실 닉네임을 입력해주세요!"
        let attributedString = NSMutableAttributedString(string: text)
        
        let paragraphStyle = NSMutableParagraphStyle()
        let desiredLineHeight: CGFloat = 36
        paragraphStyle.minimumLineHeight = desiredLineHeight
        paragraphStyle.maximumLineHeight = desiredLineHeight

        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        greetingLabelL.attributedText = attributedString
        greetingLabelL.numberOfLines = 2
        greetingLabelL.textAlignment = .left
        greetingLabelL.lineBreakMode = .byWordWrapping
        greetingLabelL.font = UIFont.systemFont(ofSize: 24,weight: .semibold)
        
        greetingLabelS = UILabel()
        greetingLabelS.text = "닉네임은 언제든지 변경이 가능해요!"
        greetingLabelS.textColor = .deHighLight
        greetingLabelS.font = UIFont.systemFont(ofSize: 14)
        
        nickNameField = UITextField()
        nickNameField.delegate = self
        nickNameField.keyboardType = .default
        nickNameField.placeholder = "아토피완치기원1일차"
        nickNameField.font = UIFont.systemFont(ofSize: 24,weight: .semibold)
        nickNameField.clearButtonMode = .whileEditing
        nickNameField.tintColor = .black
        nickNameField.autocapitalizationType = .none
        nickNameField.autocorrectionType = .no
        
        nextButton = UIButton()
        nextButton.setTitle("회원가입 완료", for: .normal)
        nextButton.isEnabled = false
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        nextButton.layer.cornerCurve = .continuous
        nextButton.layer.cornerRadius = 23
        nextButton.clipsToBounds = true
        nextButton.backgroundColor = .gray
        
        warningLabel = UILabel()
        warningLabel.text = "한글, 영어, 숫자만 사용할 수 있어요. (최대 12자)"
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
            .debounce(.milliseconds(0), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] newValue in
                guard let self = self else { return }
                if newValue.count >= 13 {
                    self.shakeTextField(self.nickNameField)
                    self.nickNameField.text = String(newValue.prefix(13))
                    self.warningLabel.text = "최대 12자까지만 입력 가능해요."
                    self.nextButton.backgroundColor = .gray
                    nextButton.isEnabled = false
                } else if newValue.count < 3 || !self.isValidHangul(newValue) || !self.isValidNickname(newValue){
                    self.warningLabel.text = "한글, 영어, 숫자만 사용할 수 있어요. (완성된 한글만, 최대 12자)"
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
        let regex = "^[A-Za-z0-9가-힣]{3,12}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: nickname)
    }
    
    func isValidHangul(_ text: String) -> Bool {
        let pattern = "^[A-Za-z0-9가-힣ㄱ-ㅎㅏ-ㅣ]*$"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            let range = NSRange(location: 0, length: text.utf16.count)
            if regex.firstMatch(in: text, options: [], range: range) != nil {
                return true
            }
        }
        return false
    }
    
    override func configureUtil() {
        super.configureUtil()
        nextButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let nickName = self?.nickNameField.text else {return}
            self?.user?.nickName = nickName
            guard let user = self?.user else {return}
            if (CoreDataManager.shared.addUser(user: user)) {
                self?.saveLoginInfo(user: user, completion: {
                    let nextVC = MainViewController()
                    nextVC.user = self?.user
                    let navVC = UINavigationController(rootViewController: nextVC)
                    navVC.modalPresentationStyle = .fullScreen
                    self?.present(navVC, animated: true)
                })
            }else{
                print("사용자 저장실패")
            }
            
            
        }).disposed(by: disposeBag)
    }
}


extension NickNameViewController : UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        if newText.count > 13{
            shakeTextField(self.nickNameField)
            self.warningLabel.text = "최대 12자까지만 입력 가능해요."
            return false
        }else if !isValidHangul(newText){
            shakeTextField(self.nickNameField)
            self.warningLabel.text = "한글, 영어, 숫자만 사용할 수 있어요. (완성된 한글만, 최대 12자)"
            return false
        }else{
            return true
        }
    }
}
