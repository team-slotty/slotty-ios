//
//  StartChoiceView.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/22/26.
//

import SwiftUI

/// 0-4 시작 방법 선택 - 세대에 소속되기 전에 보는 화면
struct StartChoiceView: View {
    let householdRepository: any HouseholdRepository
    /// 초대 코드로 참여를 마쳤을 때
    let onJoined: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("어떻게 시작할까요?")
                .font(SlottyFont.largeTitle)
                .foregroundStyle(SlottyColor.primary)
                .padding(.bottom, 8)
            NavigationLink {
                JoinHouseholdView(viewModel: JoinHouseholdViewModel(repository: householdRepository), onJoined: onJoined)
            } label: {
                choiceRow(title: "초대 코드로 참여", subtitle: "이미 등록된 빌라의 세대원이에요")
            }
            .buttonStyle(.plain)
            choiceRow(title: "빌라 만들기", subtitle: "준비 중이에요")
                .opacity(0.4)
            Spacer()
        }
        .padding(20)
        .background(SlottyColor.background)
    }
    
    /// 제목/설명 + 오른쪽 화살표 한 줄
    private func choiceRow(title: String, subtitle: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(SlottyFont.headline)
                    .foregroundStyle(SlottyColor.primary)
                Text(subtitle)
                    .font(SlottyFont.caption)
                    .foregroundStyle(SlottyColor.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(SlottyColor.secondary)
        }
        .padding(16)
        .contentShape(Rectangle())
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(SlottyColor.line)
        }
    }
}

#Preview {
    NavigationStack {
        StartChoiceView(householdRepository: MockHouseholdRepository(myUnit: nil)) {}
    }
}
