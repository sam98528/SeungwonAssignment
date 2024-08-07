//
//  SignUpViewController.swift
//  Assignment
//
//  Created by Sam.Lee on 8/7/24.
//
import UIKit
import SnapKit
import RxCocoa
import RxSwift

class SignUpViewController : BaseViewController {
    var greetingLabelL : UILabel!
    var greetingLabelS : UILabel!
    var passwordFieldFirst: UITextField!
    var passwordFieldSecond: UITextField!
    var warningLabelFirst: UILabel!
    var warningLabelSecond: UILabel!
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
        passwordFieldFirst.becomeFirstResponder()
    }
    
    override func configureUI() {
        super.configureUI()
        
        self.view.backgroundColor = .systemBackground
        
        greetingLabelL = UILabel()
        let text = "새로운 회원이시네요! \n비밀번호를 설정해주세요!"
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
        greetingLabelS.text = "앞으로도 사용할 비밀번호이니 꼭 기억해주세요."
        greetingLabelS.textColor = .deHighLight
        greetingLabelS.font = UIFont.systemFont(ofSize: 14)
        
        passwordFieldFirst = UITextField()
        passwordFieldFirst.placeholder = "비밀번호"
        passwordFieldSecond = UITextField()
        passwordFieldSecond.placeholder = "비밀번호 확인"
        
        [passwordFieldFirst, passwordFieldSecond].forEach{
            $0.delegate = self
            $0.keyboardType = .default
            $0.font = UIFont.systemFont(ofSize: 24,weight: .semibold)
            $0.clearButtonMode = .whileEditing
            $0.tintColor = .black
            $0.isSecureTextEntry = true
            $0.autocapitalizationType = .none
            $0.autocorrectionType = .no
        }
        
        nextButton = UIButton()
        nextButton.setTitle("회원가입 하기", for: .normal)
        nextButton.isEnabled = false
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        nextButton.layer.cornerCurve = .continuous
        nextButton.layer.cornerRadius = 23
        nextButton.clipsToBounds = true
        nextButton.backgroundColor = .gray
        
        warningLabelFirst = UILabel()
        warningLabelSecond = UILabel()
        warningLabelFirst.text = "영어와 숫자 조합만 사용할 수 있어요. (최소 5자, 최대 12자)"
        [warningLabelFirst,warningLabelSecond].forEach{
            $0.font = UIFont.systemFont(ofSize: 14)
            $0.textColor = UIColor(hexCode: "FF3B30")
        }
        
    }
    
    
    override func configureConstraint() {
        super.configureConstraint()
        [greetingLabelL, greetingLabelS, passwordFieldFirst,passwordFieldSecond, nextButton,warningLabelFirst,warningLabelSecond].forEach{
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
        passwordFieldFirst.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(greetingLabelS.snp.bottom).offset(32)
            $0.height.equalTo(36)
        }
        warningLabelFirst.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.top.equalTo(passwordFieldFirst.snp.bottom).offset(4)
            $0.height.equalTo(16)
        }
        passwordFieldSecond.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(warningLabelFirst.snp.bottom).offset(4)
            $0.height.equalTo(36)
        }
        warningLabelSecond.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.top.equalTo(passwordFieldSecond.snp.bottom).offset(4)
            $0.height.equalTo(16)
        }
        nextButton.snp.makeConstraints{
            $0.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top).inset(-16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(66)
        }
    }
    
    func bindTextField() {
        passwordFieldFirst.rx.text.orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] newValue in
                guard let self = self else { return }
                if newValue.count >= 13 {
                    self.shakeTextField(self.passwordFieldFirst)
                    self.passwordFieldFirst.text = String(newValue.prefix(13))
                    self.warningLabelFirst.text = "최대 12자까지만 입력 가능해요."
                    self.nextButton.backgroundColor = .gray
                    nextButton.isEnabled = false
                } else if newValue.count < 5 || !self.isValidPassword(newValue) || self.isOnlyNumber(newValue) || self.isOnlyLetter(newValue){
                    self.warningLabelFirst.text = "영어와 숫자 조합만 사용할 수 있어요. (최소 5자, 최대 12자)"
                    self.nextButton.backgroundColor = .gray
                    nextButton.isEnabled = false
                }else {
                    self.warningLabelFirst.text = ""
                }
                
                if !self.checkPassword(){
                    if self.passwordFieldSecond.text == "" {
                        self.warningLabelSecond.text = ""
                    }else{
                        self.warningLabelSecond.text = "비밀번호가 일치하지 않아요!"
                    }
                    self.warningLabelSecond.textColor = UIColor(hexCode: "FF3B30")
                    self.nextButton.backgroundColor = .gray
                    self.nextButton.isEnabled = false
                } else {
                    self.warningLabelSecond.text = "비밀번호가 일치해요!"
                    self.warningLabelSecond.textColor = .systemGreen
                    self.nextButton.backgroundColor = .mainLight
                    self.nextButton.isEnabled = true
                }
            })
            .disposed(by: disposeBag)
        
        passwordFieldSecond.rx.text.orEmpty
            .debounce(.milliseconds(0), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] newValue in
                guard let self = self else { return }
                
                if newValue.isEmpty {
                    self.warningLabelSecond.text = ""
                    self.nextButton.backgroundColor = .gray
                    self.nextButton.isEnabled = false
                    return
                }
                if newValue.count >= 13 {
                    self.shakeTextField(self.passwordFieldSecond)
                    self.passwordFieldFirst.text = String(newValue.prefix(13))
                    self.warningLabelSecond.textColor = UIColor(hexCode: "FF3B30")
                    self.warningLabelFirst.text = "최대 12자까지만 입력 가능해요."
                    self.nextButton.backgroundColor = .gray
                    nextButton.isEnabled = false
                } else if !self.checkPassword() || newValue.count < 5{
                    self.warningLabelSecond.textColor = UIColor(hexCode: "FF3B30")
                    self.warningLabelSecond.text = "비밀번호가 일치하지 않아요!"
                    self.nextButton.backgroundColor = .gray
                    nextButton.isEnabled = false
                }else{
                    self.warningLabelSecond.text = "비밀번호가 일치해요!"
                    self.warningLabelSecond.textColor = .systemGreen
                    self.nextButton.backgroundColor = .mainLight
                    nextButton.isEnabled = true
                }
                
            })
            .disposed(by: disposeBag)
    }
    
    func isValidPassword(_ nickname: String) -> Bool {
        let regex = "^[a-z0-9]*$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: nickname)
    }
    
    
    func checkPassword() -> Bool{
        guard let firstPassword = passwordFieldFirst.text, let secondPassword = passwordFieldSecond.text else {return false}
        
        if self.isValidPassword(firstPassword) && firstPassword == secondPassword && firstPassword != "" {
            return true
        }else{
            return false
        }
    }
    
    override func configureUtil() {
        super.configureUtil()
        nextButton.rx.tap.subscribe(onNext: { [weak self] in
            let nextVC = NickNameViewController()
            guard let password = self?.passwordFieldFirst.text else {return}
            self?.user?.password = password
            nextVC.modalPresentationStyle = .fullScreen
            nextVC.user = self?.user
            self?.navigationController?.pushViewController(nextVC, animated: true)
        }).disposed(by: disposeBag)
    }
}


extension SignUpViewController : UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        if textField == passwordFieldFirst {
            if newText.count > 13{
                shakeTextField(textField)
                self.warningLabelFirst.text = "최대 12자까지만 입력 가능해요."
                return false
            }else if !isValidPassword(newText){
                shakeTextField(textField)
                self.warningLabelFirst.text = "영어와 숫자 조합만 사용할 수 있어요. (최소 5자, 최대 12자)"
                return false
            }else{
                return true
            }
        }else{
            if newText.count > 13{
                shakeTextField(textField)
                self.warningLabelSecond.text = "최대 12자까지만 입력 가능해요."
                return false
            }
            return true
        }
        
    }
}
