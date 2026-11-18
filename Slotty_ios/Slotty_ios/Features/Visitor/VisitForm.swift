//
//  VisitForm.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/18/26.
//

import Foundation

/// 방문 등록 화면에서 입력 중인 값
struct VisitForm: Equatable {
    var plateNumber = ""
    var startAt: Date
    var endAt: Date
    /// 지정할 주차면 번호, 지정하지 않으면 nil
    var spotNumber: Int?
    
    /// 처음 값 - 지금부터 4시간
    init(now: Date = Date()) {
        startAt = now
        endAt = now.addingTimeInterval(4 * 60 * 60)
    }
    
    /// 공백을 뺀 차량번호
    var trimmedPlateNumber: String {
        plateNumber.filter{ !$0.isWhitespace }
    }
    
    /// 등록할 수 없는 이유, 문제 없으면 nil
    var problem: String? {
        if trimmedPlateNumber.isEmpty {
            return "차량번호를 입력해 주세요"
        }
        if endAt <= startAt {
            return "종료 시각은 시작 시각보다 늦어야 해요"
        }
        if endAt.timeIntervalSince(startAt) > 24 * 60 * 60 {
            return "방문은 최대 24시간까지 등록할 수 있어요"
        }
        return nil
    }
}
