//
//  JoinHouseholdView.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/22/26.
//

import SwiftUI

/// 초대 코드 입력 - 참여하면 "○○호로 가입되었어요" 안내 후 홈으로
struct JoinHouseholdView: View {
    @State private var viewModel: JoinHouseholdViewModel
    /// 안내를 확인했을 때
    let onJoined: () -> Void
    
    init(viewModel: JoinHouseholdViewModel, onJoined: @escaping () -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onJoined = onJoined
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("세대 관리자에게 받은 초대 코드를 입력해 주세요")
                .font(SlottyFont.body)
                .foregroundStyle(SlottyColor.secondary)
            LabeledInput(label: "초대 코드", placeholder: "예: SEED101AAAA", text: $viewModel.inviteCode)
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(SlottyFont.caption)
                    .foregroundStyle(SlottyColor.secondary)
            }
            Spacer()
            Button("참여하기") {
                Task { await viewModel.join() }
            }
            .buttonStyle(.slottyPrimary)
            .disabled(!viewModel.canJoin)
        }
        .padding(20)
        .background(SlottyColor.background)
        .navigationTitle("초대 코드로 참여")
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "\(viewModel.joinedUnit ?? "")호로 가입되었어요",
            isPresented: .constant(viewModel.joinedUnit != nil)
        ) {
            Button("확인", action: onJoined)
        }
    }
}

#Preview {
    NavigationStack {
        JoinHouseholdView(viewModel: JoinHouseholdViewModel(repository: MockHouseholdRepository(myUnit: nil))) {}
    }
}
