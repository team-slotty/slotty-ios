//
//  SplashView.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/19/26.
//

import SwiftUI

/// 0-1 스플래시: 로고, 앱 이름, 한 줄 소개
struct SplashView: View {
    var body: some View {
        VStack(spacing: 0) {
            SlottyLogo()
                .padding(.bottom, 20)
            Text("Slotty")
                .font(.custom("NotoSansKR-Bold", size: 40))
                .foregroundStyle(SlottyColor.primary)
                .padding(.bottom, 8)
            Text("방문 차량 등록부터 주차 현황 확인까지")
                .font(SlottyFont.subtitle)
                .foregroundStyle(SlottyColor.primary)
                .padding(.bottom, 12)
            Text("자동 로그인 확인 중…")
                .font(SlottyFont.caption)
                .foregroundStyle(SlottyColor.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SlottyColor.background)
    }
}

#Preview {
    SplashView()
}
