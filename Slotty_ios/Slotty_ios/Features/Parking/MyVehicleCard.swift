//
//  MyVehicleCard.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/16/26.
//

import SwiftUI

/// 우리 세대 차 한 대의 주차 상태와 입차/출차 버튼
struct MyVehicleCard: View {
    let vehicle: Vehicle
    let parkedSpot: ParkingSpot? // 이 차가 서있는 면, 주차 안 했으면 nil
    let onEnter: () -> Void
    let onExit: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text(vehicle.plateNumber)
                    .font(SlottyFont.headline)
                    .foregroundStyle(SlottyColor.primary)
                if let nickname = vehicle.nickname {
                    Text(nickname)
                        .font(SlottyFont.caption)
                        .foregroundStyle(SlottyColor.secondary)
                }
            }
            Text(statusText)
                .font(SlottyFont.body)
                .foregroundStyle(SlottyColor.secondary)
            HStack(spacing: 8) {
                Button("입차", action: onEnter)
                    .buttonStyle(.slottyPrimary)
                Button("출차", action: onExit)
                    .buttonStyle(.slottySecondary)
                    .disabled(parkedSpot == nil)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(SlottyColor.line)
        }
    }
    
    /// 예: "2번 면, 사용 중, 오후 7:12 입차 / 주차 안 함"
    private var statusText: String {
        guard let parkedSpot else { return "주차 안 함" }
        var text = "\(parkedSpot.number)번 면 |  \(parkedSpot.status.label)"
        if let enteredAt = parkedSpot.currentParking?.enteredAt {
            text += " | \(enteredAt.formatted(date: .omitted, time: .shortened)) 입차"
        }
        return text
    }
}

#Preview {
    let board = MockParkingData.board
    VStack(spacing: 12) {
        MyVehicleCard(vehicle: board.myVehicles[0], parkedSpot: board.spots[1], onEnter: {}, onExit: {})
        MyVehicleCard(vehicle: board.myVehicles[1], parkedSpot: nil, onEnter: {}, onExit: {})
    }
    .padding(20)
}
