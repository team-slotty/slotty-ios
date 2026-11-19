//
//  SlottyLogo.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/19/26.
//

import SwiftUI

/// 슬로티 로고 - 위가 열린 주차면 안에 노란 차 한 대
struct SlottyLogo: View {
    /// 로고 너비, 높이는 너비에 맞춰 정해짐
    var width: CGFloat = 64
    
    var body: some View {
        let line = width * 0.14
        ZStack(alignment: .bottom) {
            // 주차면 테두리: 왼쪽/오른쪽/아래
            HStack {
                Rectangle().frame(width: line)
                Spacer()
                Rectangle().frame(width: line)
            }
            Rectangle().frame(height: line)
            // 주차면 안의 차
            RoundedRectangle(cornerRadius: width * 0.08)
                .fill(SlottyColor.accent)
                .frame(width: width * 0.4, height: width * 0.5)
                .padding(.bottom, line * 2)
        }
        .foregroundStyle(SlottyColor.primary)
        .frame(width: width, height: width * 1.35)
    }
}


#Preview {
    SlottyLogo()
}
