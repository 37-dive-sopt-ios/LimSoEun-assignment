
//
//  LoginViewController.swift
//  LimSoEun_assignment
//
//  Created by 임소은 on 10/23/25.
//

import UIKit

import Combine
import Foundation
import SnapKit


final class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - MVVM + Combine
    private let loginViewModel = LoginViewModel()
    private var bag = Set<AnyCancellable>()
    private let emailSubject = PassthroughSubject<String, Never>()
    private let passwordSubject = PassthroughSubject<String, Never>()
    private let loginTapSubject = PassthroughSubject<Void, Never>()

    //MARK: - UI
    private let navigationView = CustomNavigationView(title: "이메일 또는 아이디로 계속")
    
    ///이메일 입력 필드
    private let emailField = FloatingLabelTextField(
        titleText: "이메일 아이디",
        activePlaceholder: "이메일 또는 아이디를 입력해주세요"
    )
    ///비밀번호 입력 필드
    private let passwordTextField = PasswordTextField(
        titleText: "비밀번호",
        activePlaceholder: "비밀번호를 입력해주세요"
    )
    ///로그인버튼
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.layer.backgroundColor = UIColor.baeminGray200.cgColor
        button.setTitle("로그인", for: .normal)
        button.titleLabel?.font = .font(.pretendardBold , ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.baeminGray200.cgColor
        button.addTarget(self, action: #selector(loginButtonDidTap), for: .touchUpInside)
        return button
    }()
    ///계정 찾기 버튼
    private lazy var findAccountButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "계정찾기"
        config.image = UIImage(
            systemName: "chevron.right",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)
        )
        config.imagePadding = 5
        config.baseForegroundColor = .baeminBlack
        config.contentInsets = .zero

        let button = UIButton(configuration: config)
        button.titleLabel?.font = .font(.pretendardRegular, ofSize: 14)
        button.semanticContentAttribute = .forceRightToLeft
        return button
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        self.view.backgroundColor = .white
        setupNavigation()
        setLayout()
        

        // UITextField → Subject
        emailField.textField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        passwordTextField.textField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)

        bind()
        
    }
    
    // MARK: - Bind
    private func bind() {
        let email = emailSubject
            .prepend(emailField.textField.text ?? "")
            .eraseToAnyPublisher()
        
        let password = passwordSubject
            .prepend(passwordTextField.textField.text ?? "")
            .eraseToAnyPublisher()
        
        let input = LoginViewModel.Input(
            email: email,
            password: password,
            loginTap: loginTapSubject.eraseToAnyPublisher()
        )
        let output = loginViewModel.transform(input)
        
        output.isLoginEnabled
            .receive(on: RunLoop.main)
            .sink { [weak self] enabled in
                guard let self = self else { return }
                let color = enabled ? UIColor.baeminMint500.cgColor : UIColor.baeminGray200.cgColor
                self.loginButton.layer.backgroundColor = color
                self.loginButton.layer.borderColor = color
                self.loginButton.isEnabled = enabled
            }
            .store(in: &bag)
        
        output.showToast
            .receive(on: RunLoop.main)
            .sink { [weak self] message in
                self?.showToast(message: message)
            }
            .store(in: &bag)
        
        output.routeToWelcome
            .receive(on: RunLoop.main)
            .sink { [weak self] email in
                self?.pushToWelcomeVC(with: email)
            }
            .store(in: &bag)
    }
    
    
    //MARK: - layout
    private func setLayout() {
        [emailField, passwordTextField, loginButton, findAccountButton].forEach {
            self.view.addSubview($0)
        }
        
        emailField.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(46)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(emailField.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(emailField)
            $0.height.equalTo(46)
           
        }
        
        loginButton.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(emailField)
            $0.height.equalTo(46)
          
        }
        
        findAccountButton.snp.makeConstraints {
            $0.top.equalTo(loginButton.snp.bottom).offset(32)
            $0.leading.trailing.equalTo(emailField)
          
        }
    }
    //MARK: - navigation 설정
    private func setupNavigation() {
        view.addSubview(navigationView)
        navigationView.onBackButtonTap = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(45)
        }
    }
    
    // MARK: - Actions
    @objc private func textFieldChanged(_ tf: UITextField) {
        if tf === emailField.textField { emailSubject.send(tf.text ?? "") }
        if tf === passwordTextField.textField { passwordSubject.send(tf.text ?? "") }
    }
    
    ///뒤로가기 액션
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }
    ///로그인버튼 클릭 시 액션
    @objc
    private func loginButtonDidTap() {
        loginTapSubject.send(())
    }
    
    // MARK: - Routing
    private func pushToWelcomeVC(with email: String) {
        let vm = WelcomeViewModel(name: email)
        let vc = WelcomeViewController(viewModel: vm)
        navigationController?.pushViewController(vc, animated: true)
    }
}
