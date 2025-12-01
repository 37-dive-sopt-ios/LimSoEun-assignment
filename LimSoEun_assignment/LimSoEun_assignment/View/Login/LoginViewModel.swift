//
//  Untitled.swift
//  LimSoEun_assignment
//
//  Created by 임소은 on 12/1/25.
//

import Foundation
import Combine

public final class LoginViewModel: ViewModelType {
    
    //MARK: - I/O
    
    public struct Input {
        public let email: AnyPublisher<String, Never>
        public let password: AnyPublisher<String, Never>
        public let loginTap: AnyPublisher<Void, Never>
        public init(email: AnyPublisher<String, Never>, password: AnyPublisher<String, Never>, loginTap: AnyPublisher<Void, Never>) {
            self.email = email
            self.password = password
            self.loginTap = loginTap
        }
    }
    
    public struct Output {
        public  let isLoginEnabled: AnyPublisher<Bool, Never>
        public let showToast: AnyPublisher<String, Never>
        public let routeToWelcome: AnyPublisher<String, Never>
    }
    
    public init() {
        
    }
    
    public func transform(_ input: Input) -> Output {
        let creds = input.email.combineLatest(input.password).share()
        
        let isLoginEnable = creds
            .map { !$0.0.isEmpty && !$0.1.isEmpty }
            .removeDuplicates()
            .eraseToAnyPublisher()
        
        let latestEmailOnTap = input.loginTap
            .combineLatest(input.email)
            .map { _, email in email }
            .eraseToAnyPublisher()
        
        let routeToWelcome = latestEmailOnTap
            .filter { Validator.isValidEmail($0) }
            .eraseToAnyPublisher()
        
        let showToast = latestEmailOnTap
            .filter { !Validator.isValidEmail($0) }
            .map { _ in " 이메일 형식이 달라요" }
            .eraseToAnyPublisher()
        
        return Output(
            isLoginEnabled: isLoginEnable,
            showToast: showToast,
            routeToWelcome: routeToWelcome
        )
    }
}
