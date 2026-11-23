//
//  LayoutPreview.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import SwiftUI

/// 배치 미리보기 그림 - 면마다 번호를 붙이고, 입구 쪽에 "입구"를 표시한다
struct LayoutPreview: View {
    let title: String
    let template: String
    let entranceSide: String
    let slotCount: Int

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(SlottyFont.caption)
                .foregroundStyle(SlottyColor.secondary)
            GeometryReader { geometry in
                let size = geometry.size
                let slots = SlotLayout.calculate(template: template, entranceSide: entranceSide, count: slotCount)
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(SlottyColor.line)
                    ForEach(Array(slots.enumerated()), id: \.offset) { index, slot in
                        RoundedRectangle(cornerRadius: 3)
                            .strokeBorder(SlottyColor.primary, lineWidth: 1)
                            .overlay {
                                Text("\(index + 1)")
                                    .font(.system(size: 9))
                                    .foregroundStyle(SlottyColor.primary)
                            }
                            .frame(width: slot.width * size.width, height: slot.height * size.height)
                            .position(x: slot.x * size.width, y: slot.y * size.height)
                    }
                    entranceLabel
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: entranceAlignment)
                        .padding(4)
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
    }

    private var entranceLabel: some View {
        Text("입구")
            .font(.system(size: 9, weight: .semibold))
            .foregroundStyle(SlottyColor.secondary)
    }

    /// 입구 글자를 둘 쪽
    private var entranceAlignment: Alignment {
        switch entranceSide {
        case "TOP": .top
        case "LEFT": .leading
        case "RIGHT": .trailing
        default: .bottom
        }
    }
}

#Preview {
    HStack {
        LayoutPreview(title: "지금", template: "DOUBLE", entranceSide: "BOTTOM", slotCount: 7)
        LayoutPreview(title: "바뀔 배치", template: "L_SHAPE", entranceSide: "LEFT", slotCount: 9)
    }
    .padding(20)
}
