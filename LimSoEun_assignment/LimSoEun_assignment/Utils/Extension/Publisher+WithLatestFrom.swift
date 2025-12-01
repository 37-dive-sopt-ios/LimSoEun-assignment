//
//  Publisher+WithLatestFrom.swift
//  LimSoEun_assignment
//
//  Created by 임소은 on 12/1/25.
//

import Combine

public extension Publisher where Failure == Never {
    /// Rx의 withLatestFrom 유사: `self` 이벤트가 올 때 `other`의 최신 값을 방출
    func withLatestFrom<P: Publisher>(_ other: P) -> AnyPublisher<P.Output, Never>
    where P.Failure == Never {
        other
            .flatMap { latest in self.map { _ in latest } }
            .eraseToAnyPublisher()
    }
}
