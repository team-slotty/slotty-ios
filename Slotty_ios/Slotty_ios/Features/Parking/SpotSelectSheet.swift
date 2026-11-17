//
//  SpotSelectSheet.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/17/26.
//

import SwiftUI

/// [변경] - 입차할 주차면 고르기 (사용 중인 면은 선택 불가)
struct SpotSelectSheet: View {
    let board: ParkingBoard
    /// 지금 골라져 있는 면 번호, 없으면 nil
    let selectedNumber: Int?
    let onSelect: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("주차면 선택")
                .font(SlottyFont.title)
                .foregroundStyle(SlottyColor.primary)
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(board.spots) { spot in
                        Button {
                            onSelect(spot.number)
                        } label: {
                            SelectableRow(title: "\(spot.number)번",
                                          subtitle: "\(owner(of: spot)) · \(spot.status.label)",
                                          isSelected: spot.number == selectedNumber
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(spot.status.isOccupied)
                    }
                }
            }
        }
        .padding(20)
    }
    
    /// 예: "내 면", "102호", "공용"
    private func owner(of spot: ParkingSpot) -> String {
        if spot.isAssigned(to: board.myUnit) {
            return "내 면"
        }
        return spot.assignedUnit.map { "\($0)호" } ?? "공용"
    }
}

#Preview {
    SpotSelectSheet(board: MockParkingData.board, selectedNumber: 3) { _ in }
}
