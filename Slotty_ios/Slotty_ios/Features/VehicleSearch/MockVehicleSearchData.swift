//
//  MockVehicleSearchData.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/17/26.
//

import Foundation

/// 서버 없이 검색 화면을 만들기 위한 목 데이터
enum MockVehicleSearchData {
    static let vehicles = [
        VehicleSearchResult(
            id: "s1", maskedPlateNumber: "**가3456", unit: "201",
            kind: .resident, phoneNumber: "010-0000-0201"
        ),
        VehicleSearchResult(
            id: "s2", maskedPlateNumber: "**마3456", unit: "403",
            kind: .visitor(start: today(14, 0), end: today(18, 0)), phoneNumber: "010-0000-0403"
        ),
        VehicleSearchResult(
            id: "s3", maskedPlateNumber: "**라6789", unit: "101",
            kind: .resident, phoneNumber: nil
        ),
        VehicleSearchResult(
            id: "s4", maskedPlateNumber: "**다1234", unit: "302",
            kind: .visitor(start: today(13, 0), end: today(17, 0)), phoneNumber: "010-0000-0302"
        ),
    ]
    
    /// 오늘 날짜의 특정 시각
    private static func today(_ hour: Int, _ minute: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }
}
