//
//  VisitError.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/18/26.
//

import Foundation

/// 방문 등록/종료 중에 생길 수 있는 오류
enum VisitError: Error, Equatable {
    /// 해당 방문이 없음
    case visitNotFound
    /// 종료가 시작보다 빠르거나 24시간을 넘음
    case invalidPeriod
    /// 이미 시작한 방문은 삭제할 수 없음 ([방문 종료]를 써야 함)
    case alreadyStarted
    /// 아직 시작하지 않았거나 이미 끝난 방문
    case notVisiting
    /// 서버에 아직 없는 기능
    case notSupported
}
