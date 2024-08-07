//
//  LoginViewController.swift
//  Assignment
//
//  Created by Sam.Lee on 8/7/24.
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
                } else if newValue.count < 5 || !self.isValidText(newValue) || self.isOnlyNumber(newValue){
                    self.warningLabel.text = "영어와 숫자 조합만 사용할 수 있어요. (최소 5자, 최대 12자)"
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


    
    override func configureUtil() {
        super.configureUtil()
        nextButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let id = self?.nickNameField.text else {return}
            var userModel = User(id: id, password: "", nickName: "")
            
            if !CoreDataManager.shared.isIdExists(id) {
                let nextVC = SignUpViewController()
                nextVC.user = userModel
                nextVC.modalPresentationStyle = .fullScreen
                self?.navigationController?.pushViewController(nextVC, animated: true)
            }else{
                let nextVC = LoginPasswordController()
                nextVC.user = userModel
                nextVC.modalPresentationStyle = .fullScreen
                self?.navigationController?.pushViewController(nextVC, animated: true)
            }
        }).disposed(by: disposeBag)
    }
}


extension LoginViewController : UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)

        if newText.count > 13{
            shakeTextField(self.nickNameField)
            self.warningLabel.text = "최대 12자까지만 입력 가능해요."
            return false
        }else if !isValidText(newText){
            shakeTextField(self.nickNameField)
            self.warningLabel.text = "영어와 숫자 조합만 사용할 수 있어요. (최소 5자, 최대 12자)"
            return false
        }else{
            return true
        }
    }
}
