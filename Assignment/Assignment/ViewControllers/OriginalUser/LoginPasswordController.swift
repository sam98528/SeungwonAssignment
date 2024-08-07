//
//  LoginPasswordController.swift
//  Assignment
//
//  Created by Sam.Lee on 8/7/24.
//
import UIKit
import SnapKit
import RxCocoa
import RxSwift

class LoginPasswordController : BaseViewController {
    var greetingLabelL : UILabel!
    var greetingLabelS : UILabel!
    var passwordField: UITextField!
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
        passwordField.becomeFirstResponder()
    }
    
    override func configureUI() {
        super.configureUI()
        
        self.view.backgroundColor = .systemBackground
        
        greetingLabelL = UILabel()
        let text = "반가워요! \n\(String(user?.id ?? ""))님!"
        let attributedString = NSMutableAttributedString(string: text)
        
        let paragraphStyle = NSMutableParagraphStyle()
        let desiredLineHeight: CGFloat = 36
        paragraphStyle.minimumLineHeight = desiredLineHeight
        paragraphStyle.maximumLineHeight = desiredLineHeight
        
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        greetingLabelL.attributedText = attributedString
        greetingLabelL.numberOfLines = 3
        greetingLabelL.textAlignment = .left
        greetingLabelL.lineBreakMode = .byWordWrapping
        greetingLabelL.font = UIFont.systemFont(ofSize: 24,weight: .semibold)
        
        greetingLabelS = UILabel()
        greetingLabelS.text = "비밀번호를 입력해주세요."
        greetingLabelS.textColor = .deHighLight
        greetingLabelS.font = UIFont.systemFont(ofSize: 14)
        
        passwordField = UITextField()
        passwordField.placeholder = "비밀번호"
        passwordField.delegate = self
        passwordField.keyboardType = .default
        passwordField.font = UIFont.systemFont(ofSize: 24,weight: .semibold)
        passwordField.clearButtonMode = .whileEditing
        passwordField.tintColor = .black
        passwordField.isSecureTextEntry = true
        passwordField.autocapitalizationType = .none
        passwordField.autocorrectionType = .no
        
        nextButton = UIButton()
        nextButton.setTitle("로그인 하기", for: .normal)
        nextButton.isEnabled = false
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        nextButton.layer.cornerCurve = .continuous
        nextButton.layer.cornerRadius = 23
        nextButton.clipsToBounds = true
        nextButton.backgroundColor = .gray
        
        warningLabel = UILabel()
        warningLabel.text = "영어와 숫자 조합만으로 구성되어 있어요. (최소 5자, 최대 12자)"
        warningLabel.font = UIFont.systemFont(ofSize: 14)
        warningLabel.textColor = UIColor(hexCode: "FF3B30")
        
    }
    
    
    override func configureConstraint() {
        super.configureConstraint()
        [greetingLabelL, greetingLabelS, passwordField, nextButton,warningLabel].forEach{
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
        passwordField.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(greetingLabelS.snp.bottom).offset(32)
            $0.height.equalTo(36)
        }
        warningLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.top.equalTo(passwordField.snp.bottom).offset(4)
            $0.height.equalTo(16)
        }
        nextButton.snp.makeConstraints{
            $0.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top).inset(-16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(66)
        }
        
    }
    
    func bindTextField() {
        passwordField.rx.text.orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] newValue in
                guard let self = self else { return }
                if newValue.count >= 13 {
                    self.shakeTextField(self.passwordField)
                    self.passwordField.text = String(newValue.prefix(13))
                    self.warningLabel.text = "최대 12자까지만 입력 가능해요."
                    self.nextButton.backgroundColor = .gray
                    nextButton.isEnabled = false
                } else if newValue.count < 5 || !self.isValidPassword(newValue) || self.isOnlyNumber(newValue){
                    self.warningLabel.text = "영어와 숫자 조합만으로 구성되어 있어요. (최소 5자, 최대 12자)"
                    self.nextButton.backgroundColor = .gray
                    nextButton.isEnabled = false
                }else {
                    self.warningLabel.text = ""
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
    
    override func configureUtil() {
        super.configureUtil()
        nextButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let password = self?.passwordField.text , let id = self?.user?.id, let textField = self?.passwordField else {return}
            
            if CoreDataManager.shared.isPasswordCorrect(for: id, password: password) {
                self?.user?.nickName = CoreDataManager.shared.getNickname(for: id) ?? ""
                self?.user?.password = password
                guard let user = self?.user else {return}
                
                self?.saveLoginInfo(user: user, completion: {
                    let nextVC = MainViewController()
                    nextVC.user = self?.user
                    let navVC = UINavigationController(rootViewController: nextVC)
                    navVC.modalPresentationStyle = .fullScreen
                    self?.present(navVC, animated: true)
                })
            }else{
                self?.warningLabel.text = "비밀번호가 틀렸어요!"
                self?.shakeTextField(textField)
            }
        }).disposed(by: disposeBag)
    }
}


extension LoginPasswordController : UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        if newText.count > 13{
            shakeTextField(textField)
            self.warningLabel.text = "최대 12자까지만 입력 가능해요."
            return false
        }else if !isValidPassword(newText){
            shakeTextField(textField)
            self.warningLabel.text = "영어와 숫자 조합만으로 구성되어 있어요. (최소 5자, 최대 12자)"
            return false
        }else{
            return true
        }
        
    }
}
