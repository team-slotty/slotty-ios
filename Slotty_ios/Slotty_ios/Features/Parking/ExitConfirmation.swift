//
//  ExitConfirmation.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/16/26.
//

import SwiftUI

extension View {
    /// 출차 확인 팝업 - [출차]를 누르면 onConfirm 실행
    func exitConfirmation(_ title: String, isPresented: Binding<Bool>, onConfirm: @escaping () -> Void) -> some View {
        alert(title, isPresented: isPresented) {
            Button("취소", role: .cancel) {}
            Button("출차", role: .destructive, action: onConfirm)
        } message: {
            Text("현황판에서 빈 면으로 바뀌어요.")
        }
    }
}
