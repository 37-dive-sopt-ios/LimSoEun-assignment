//
//  ViewModelType.swift
//  LimSoEun_assignment
//
//  Created by 임소은 on 12/1/25.
//

import Foundation

public protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    func transform(_ input: Input) -> Output
}

