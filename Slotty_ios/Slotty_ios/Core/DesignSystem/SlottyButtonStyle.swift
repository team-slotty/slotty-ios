//
//  SlottyButtonStyle.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/16/26.
//

import SwiftUI

/// 기본 버튼 : 진한 배경 + 흰 글자
struct SlottyPrimaryButtonStyle: ButtonStyle { /// 버튼 모양만 정의하는 틀, 눌렀을 때 하는 일은 Button이 따로 정한다
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label /// 버튼 안의 글자
            .font(SlottyFont.button)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 46)
            .background(isEnabled ? SlottyColor.primary : SlottyColor.line,
                        in: RoundedRectangle(cornerRadius: 8))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

/// 보조 버튼 : 흰 배경 + 회색 테두리
struct SlottySecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(SlottyFont.button)
            .foregroundStyle(isEnabled ? SlottyColor.primary : SlottyColor.secondary)
            .frame(maxWidth: .infinity, minHeight: 46)
            .background(SlottyColor.background, in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(SlottyColor.line)
            }
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

extension ButtonStyle where Self == SlottyPrimaryButtonStyle {
    static var slottyPrimary: Self { SlottyPrimaryButtonStyle() }
}

extension ButtonStyle where Self == SlottySecondaryButtonStyle {
    static var slottySecondary: Self { SlottySecondaryButtonStyle() }
}

#Preview {
    VStack(spacing: 12) {
        Button("입차") {}
            .buttonStyle(.slottyPrimary)
        Button("출차") {}
            .buttonStyle(.slottySecondary)
        Button("입차( (비활성)") {}
            .buttonStyle(.slottyPrimary)
            .disabled(true)
        Button("출차 (비활성)") {}
            .buttonStyle(.slottySecondary)
            .disabled(true)
    }
    .padding(20)
}
