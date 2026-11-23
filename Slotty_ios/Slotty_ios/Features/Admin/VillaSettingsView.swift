//
//  VillaSettingsView.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import SwiftUI

/// 7-2 빌라 정보 - 이름/주소 수정, 기준점 다시 잡기, 관리자 넘기기
struct VillaSettingsView: View {
    let repository: any VillaRepository
    /// 관리자로 넘길 수 있는 입주민 (관리자 본인 제외)
    let candidates: [AdminHousehold.Member]
    /// 면 배정에서 고를 수 있는 세대
    let households: [AdminHousehold]
    /// 관리자를 넘겼을 때 - 관리 탭을 닫는다
    let onAdminDelegated: () -> Void
    
    @State private var villa: VillaInfo?
    @State private var name = ""
    @State private var address = ""
    @State private var message: String?
    /// 관리자로 넘길 사람을 확인 중이면 그 사람
    @State private var delegatingTo: AdminHousehold.Member?
    
    var body: some View {
        Form {
            if let message {
                Text(message)
                    .foregroundStyle(SlottyColor.secondary)
            }
            if let villa {
                Section("빌라") {
                    TextField("이름", text: $name)
                    TextField("주소", text: $address)
                    Button("저장") {
                        Task { await save() }
                    }
                    .disabled(name.isEmpty || address.isEmpty || (name == villa.name && address == villa.address))
                }
                Section("기준점") {
                    LabeledContent("도착 알림 기준점", value: villa.hasAnchor ? "설정됨" : "없음")
                    Button("주소로 기준점 다시 잡기") {
                        Task { await resetAnchor() }
                    }
                }
                Section("관리자 넘기기") {
                    if candidates.isEmpty {
                        Text("넘길 수 있는 입주민이 없어요")
                            .foregroundStyle(SlottyColor.secondary)
                    }
                    ForEach(candidates) { member in
                        Button(member.name) {
                            delegatingTo = member
                        }
                    }
                }
                Section("주차장") {
                    LabeledContent("주차면", value: "\(villa.slotCount)면")
                    LabeledContent("세대", value: "\(villa.householdCount)세대")
                    NavigationLink("배치 변경") {
                        LayoutEditView(repository: repository, villa: villa) { await load() }
                    }
                    NavigationLink("면 배정") {
                        SlotAssignmentView(repository: repository, households: households)
                    }
                }
            }
        }
        .font(SlottyFont.body)
        .navigationTitle("빌라 정보")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "\(delegatingTo?.name ?? "") 님에게 관리자를 넘길까요?",
            isPresented: Binding(get: { delegatingTo != nil }, set: { if !$0 { delegatingTo = nil } }),
            titleVisibility: .visible,
            presenting: delegatingTo
        ) { member in
            Button("넘기기", role: .destructive) {
                Task { await delegate(to: member) }
            }
        } message: { _ in
            Text("넘기면 나는 관리 탭을 쓸 수 없어요")
        }
        .task { await load() }
    }
    
    private func load() async {
        do {
            let loaded = try await repository.fetchVilla()
            villa = loaded
            name = loaded.name
            address = loaded.address
        } catch {
            message = (error as? APIError)?.serverMessage ?? "빌라 정보를 불러오지 못했어요"
        }
    }
    
    /// 주소가 바뀌면 서버가 기준점도 다시 잡는다 - 좌표로 못 바꾸면 안내
    private func save() async {
        do {
            let geocodeFailed = try await repository.updateVilla(name: name, address: address)
            message = geocodeFailed ? "저장했지만 주소를 좌표로 바꾸지 못했어요" : "저장했어요"
            await load()
        } catch {
            message = (error as? APIError)?.serverMessage ?? "저장하지 못했어요"
        }
    }
    
    private func resetAnchor() async {
        do {
            let geocodeFailed = try await repository.resetAnchorFromAddress()
            message = geocodeFailed ? "주소를 좌표로 바꾸지 못했어요" : "기준점을 다시 잡았어요"
            await load()
        } catch {
            message = (error as? APIError)?.serverMessage ?? "기준점을 바꾸지 못했어요"
        }
    }
    
    private func delegate(to member: AdminHousehold.Member) async {
        do {
            try await repository.delegateAdmin(to: member.id)
            onAdminDelegated()
        } catch {
            message = (error as? APIError)?.serverMessage ?? "관리자를 넘기지 못했어요"
        }
    }
}

#Preview {
    NavigationStack {
        VillaSettingsView(repository: MockVillaRepository(), candidates: [.init(id: 2, name: "이서연", isAdmin: false)], households: []) {}
    }
}
