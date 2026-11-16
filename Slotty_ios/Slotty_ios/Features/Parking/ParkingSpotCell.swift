//
//  ParkingSpotCell.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/14/26.
//

import SwiftUI

/// 현황판의 주차면 칸 하나
struct ParkingSpotCell: View {
    let spot: ParkingSpot
    let isMine: Bool /// 내 세대 배정 면이면 굵은 테두리
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(spot.number)")
                .font(SlottyFont.headline)
            if let caption {
                Text(caption)
                    .font(SlottyFont.caption2)
            }
        }
        .foregroundStyle(foregroundColor)
        .frame(maxWidth: .infinity, minHeight: 64)
        .background(backgroundColor, in: RoundedRectangle(cornerRadius: 4))
        .overlay {
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(borderColor, lineWidth: isMine ? 2 : 1)
        }
    }
    
    /// 번호 아래 작은 글자 - 없으면 nil
    private var caption: String? {
        switch spot.status {
        case .occupied, .visiting, .unconfirmed, .needsCheck:
            spot.status.label
        case .available:
            "가용"
        case .empty:
            spot.isShared ? "공용" : nil
        }
    }
    
    private var backgroundColor: Color {
        switch spot.status {
        case .occupied, .visiting: SlottyColor.accent
        case .unconfirmed: SlottyColor.primary
        case .needsCheck, .available, .empty: SlottyColor.background
        }
    }
    
    private var foregroundColor: Color {
        spot.status == .unconfirmed ? .white : SlottyColor.primary
    }
    
    private var borderColor: Color {
        if isMine {
            return SlottyColor.primary
        }
        switch spot.status {
        case .occupied, .visiting, .unconfirmed: return .clear
        case .needsCheck, .available, .empty: return SlottyColor.line
        }
    }
}

#Preview {
    HStack {
        ForEach(MockParkingData.board.spots) { spot in
            ParkingSpotCell(spot: spot, isMine: spot.isAssigned(to: "201"))
        }
    }
    .padding()
}
