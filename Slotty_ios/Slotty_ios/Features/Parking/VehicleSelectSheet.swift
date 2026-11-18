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
    /// 지금 골라져 있는 차, 없으면 nil
    let selected: Vehicle?
    /// 주차 중인 차도 고를 수 있는지 - 운행 중인 차가 0대일 때만 true
    var includesParked = false
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
                    SelectableRow(title: vehicle.plateNumber, subtitle: parkedSpot.map { "\($0.number)번 면에 주차 중" } ?? vehicle.nickname ?? "주차 안 함", isSelected: vehicle == selected
                    )
                }
                .buttonStyle(.plain)
                .disabled(parkedSpot != nil && !includesParked)
            }
            Spacer()
        }
        .padding(20)
    }
}

#Preview {
    let board = MockParkingData.board
    VehicleSelectSheet(board: board, selected: board.myVehicles[1]) { _ in }
}
