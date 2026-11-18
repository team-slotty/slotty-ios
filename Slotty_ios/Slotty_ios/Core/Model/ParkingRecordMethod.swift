//
//  ParkingRecordMethod.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/13/26.
//

import Foundation

/// 입차를 어떻게 기록했는지
enum ParkingRecordMethod: Equatable {
    /// 앱에서 직접 [입차하기]를 눌러 기록
    case manual
    /// 도착 알림을 눌러 기록
    case arrivalNotification
    /// 잘못 기록된 미확인 차량을 [내 차예요]로 바로잡음
    case correction

    /// 화면에 보여줄 이름
    var label: String {
        switch self {
        case .manual: "직접 기록"
        case .arrivalNotification: "도착 알림"
        case .correction: "정정"
        }
    }
}
