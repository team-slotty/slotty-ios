//
//  Vehicle.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/13/26.
//

import Foundation

/// 세대에 등록된 차량
struct Vehicle: Identifiable, Equatable {
    
    let id: String
    /// 차량번호 (예: 12가3456)
    var plateNumber: String
    /// 별칭 (예: 남편 차). 없으면 nil
    var nickname: String?
    /// 소속 세대 호수 (예: 201)
    let unit: String

    /// 이웃에게 보여줄 가린 번호 (예: **가3456)
    var maskedPlateNumber: String {
        "**" + plateNumber.suffix(5)
    }
}
