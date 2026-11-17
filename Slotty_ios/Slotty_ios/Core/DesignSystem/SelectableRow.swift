//
//  SelectableRow.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/17/26.
//

import SwiftUI

/// 선택 시트 목록의 한 줄 - 고른 줄은 체크와 굵은 테두리, 막힌 줄(.disabled)은 회색

struct SelectableRow: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    
    @Environment(\.isEnabled) private var isEnabled
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(SlottyFont.headline)
                Text(subtitle)
                    .font(SlottyFont.caption)
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
            }
        }
        .foregroundStyle(isEnabled ? SlottyColor.primary : SlottyColor.secondary)
        .padding(16)
        .contentShape(Rectangle())
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(isSelected ? SlottyColor.primary : SlottyColor.line, lineWidth: isSelected ? 2 : 1)
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        SelectableRow(title: "34나 5678", subtitle: "내 차", isSelected: true)
        SelectableRow(title: "56다 7890", subtitle: "주차 안 함", isSelected: false)
        SelectableRow(title: "12가 3456", subtitle: "2번 면에 주차 중", isSelected: false)
            .disabled(true)
    }
    .padding(20)
}
