//
//  AdminHomeView.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import SwiftUI

/// 7-1 관리 홈 - 세대마다 초대 코드, 면, 차량, 세대원
struct AdminHomeView: View {
    @State private var viewModel: AdminHouseholdsViewModel
    /// [+ 세대] 입력창을 띄웠는지
    @State private var isAdding = false
    @State private var newUnitNumber = ""
    /// 확인을 받는 중인 동작, 없으면 nil
    @State private var pending: PendingAction?
    
    init(viewModel: AdminHouseholdsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        List {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(SlottyColor.secondary)
            }
            ForEach(viewModel.households ?? []) { household in
                section(household)
            }
        }
        .font(SlottyFont.body)
        .navigationTitle("관리")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("+ 세대") { isAdding = true }
            }
        }
        .alert("세대 추가", isPresented: $isAdding) {
            TextField("호수 (예: 401)", text: $newUnitNumber)
            Button("추가") {
                let unit = newUnitNumber
                newUnitNumber = ""
                Task { await viewModel.add(unitNumber: unit) }
            }
            Button("취소", role: .cancel) { newUnitNumber = "" }
        }
        .confirmationDialog(
            pending?.title ?? "",
            isPresented: Binding(get: { pending != nil }, set: { if !$0 { pending = nil } }),
            titleVisibility: .visible,
            presenting: pending
        ) { action in
            Button(action.buttonTitle, role: .destructive) {
                Task { await action.run() }
            }
        }
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }
    
    /// 세대 하나 - 초대 코드와 재발급, 세대원과 내보내기, 세대 삭제
    private func section(_ household: AdminHousehold) -> some View {
        Section {
            HStack {
                Text("초대 코드")
                Spacer()
                Text(household.inviteCode)
                    .textSelection(.enabled)
                    .foregroundStyle(SlottyColor.secondary)
                Button("재발급") {
                    pending = PendingAction(title: "\(household.unitNumber)호 초대 코드를 재발급할까요? 이전 코드는 쓸 수 없어요", buttonTitle: "재발급") {
                        await viewModel.reissueInviteCode(of: household)
                    }
                }
                .buttonStyle(.borderless)
            }
            ForEach(household.members) { member in
                HStack {
                    Text(member.isAdmin ? "\(member.name) (관리자)" : member.name)
                    Spacer()
                    if !member.isAdmin {
                        Button("내보내기") {
                            pending = PendingAction(title: "\(member.name) 님을 \(household.unitNumber)호에서 내보낼까요?", buttonTitle: "내보내기") {
                                await viewModel.remove(member, from: household)
                            }
                        }
                        .buttonStyle(.borderless)
                        .foregroundStyle(SlottyColor.secondary)
                    }
                }
            }
            Button("세대 삭제", role: .destructive) {
                pending = PendingAction(title: "\(household.unitNumber)호를 삭제할까요?", buttonTitle: "삭제") {
                    await viewModel.delete(household)
                }
            }
        } header: {
            Text("\(household.unitNumber)호 · 면 \(household.spotLabels.isEmpty ? "없음" : household.spotLabels.joined(separator: ", ")) · 차량 \(household.vehicleCount)대")
        }
    }
}

/// 확인창에 띄울 되돌릴 수 없는 동작 - 제목, 버튼 이름, 실행할 일
private struct PendingAction: Identifiable {
    let id = UUID()
    let title: String
    let buttonTitle: String
    let run: () async -> Void
}

#Preview {
    NavigationStack {
        AdminHomeView(viewModel: AdminHouseholdsViewModel(repository: MockAdminRepository()))
    }
}
