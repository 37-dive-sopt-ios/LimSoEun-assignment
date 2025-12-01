//
//  WelcomViewModel.swift
//  LimSoEun_assignment
//
//  Created by 임소은 on 12/1/25.
//

import Foundation
import Combine

public final class WelcomeViewModel: ViewModelType {
    public struct Input { public init() {} }
    
    public struct Output {
        public let welcomeText: AnyPublisher<String, Never>
    }
    
    private let name: String
    
    public init(name: String) {
        self.name = name
    }
    
    public func transform(_ input: Input) -> Output {
        let text = Just("\(name)님 반가워요").eraseToAnyPublisher()
        return Output(welcomeText: text)
    }
}
