//
//  MockParkingData.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/13/26.
//

import Foundation

/// 서버 없이 화면을 만들기 위한 목 데이터 (디자인 홈 화면과 같은 상태)

enum MockParkingData {
    static let board = ParkingBoard(
        villaName: "역삼 그린빌",
        myUnit: "201",
        spots: [
            ParkingSpot(
                number: 1, assignedUnit: "101", status: .occupied,
                currentParking: ParkingRecord(plateNumber: "45라6789", enteredAt: today(8, 30), method: .manual)
            ),
            ParkingSpot(
                number: 2, assignedUnit: "201", status: .occupied,
                currentParking: ParkingRecord(plateNumber: "12가3456", enteredAt: today(19, 12), method: .arrivalNotification)
            ),
            ParkingSpot(number: 3, assignedUnit: "102", status: .empty),
            ParkingSpot(number: 4, assignedUnit: "202", status: .empty),
            ParkingSpot(
                number: 5, assignedUnit: "302", status: .visiting,
                currentParking: ParkingRecord(plateNumber: "34다1234", enteredAt: today(14, 0), method: .manual)
            ),
            ParkingSpot(
                number: 6, assignedUnit: "301", status: .unconfirmed,
                currentParking: ParkingRecord(plateNumber: nil, enteredAt: today(21, 10), method: .manual)
            ),
            ParkingSpot(number: 7, assignedUnit: nil, status: .empty),
        ],
        myVehicles: [
            Vehicle(id: "v1", plateNumber: "12가3456", nickname: "남편 차", unit: "201"),
            Vehicle(id: "v2", plateNumber: "34나5678", nickname: "내 차", unit: "201"),
        ]
    )

    /// 오늘 날짜의 특정 시각
    private static func today(_ hour: Int, _ minute: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }
}
