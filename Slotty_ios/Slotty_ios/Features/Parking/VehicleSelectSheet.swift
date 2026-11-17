//
//  VehicleSelectSheet.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/17/26.
//

import SwiftUI

/// [다른 차량] - 입차할 우리 세대 차 고르기
struct VehicleSelectSheet: View {
    let board: ParkingBoard
    /// 지금 골라져 있는 차
    let selected: Vehicle
    let onSelect: (Vehicle) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("차량 선택")
                .font(SlottyFont.title)
                .foregroundStyle(SlottyColor.primary)
            ForEach(board.myVehicles) { vehicle in
                let parkedSpot = board.spot(parkedBy: vehicle)
                Button {
                    onSelect(vehicle)
                } label: {
                    row(vehicle, parkedSpot: parkedSpot)
                }
                .buttonStyle(.plain)
                .disabled(parkedSpot != nil)
            }
            Spacer()
        }
        .padding(20)
    }
    
    /// 차 한 대 - 이미 주차 중이면 흐리게
    private func row(_ vehicle: Vehicle, parkedSpot: ParkingSpot?) -> some View {
        let isSelected = vehicle == selected
        return HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(vehicle.plateNumber)
                    .font(SlottyFont.headline)
                Text(parkedSpot.map { "\($0.number)번 면에 주차 중" } ?? vehicle.nickname ?? "주차 안 함")
                    .font(SlottyFont.caption)
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
            }
        }
        .foregroundStyle(parkedSpot == nil ? SlottyColor.primary : SlottyColor.secondary)
        .padding(16)
        .contentShape(Rectangle())
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(isSelected ? SlottyColor.primary : SlottyColor.line, lineWidth: isSelected ? 2 : 1)
        }
    }
}

#Preview {
    let board = MockParkingData.board
    VehicleSelectSheet(board: board, selected: board.myVehicles[1]) { _ in }
}
