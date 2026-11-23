//
//  VillaCreateView.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import SwiftUI

/// 1-1 빌라 만들기 - 이름, 주소, 배치, 세대 호수, 내 호수 → 세대별 초대 코드 안내
struct VillaCreateView: View {
    let repository: any HouseholdRepository
    /// 만든 뒤 초대 코드를 확인했을 때 - 홈으로 들어간다
    let onCreated: () -> Void

    @State private var form = VillaCreateForm()
    @State private var isCreating = false
    @State private var errorMessage: String?
    /// 만든 결과 - 있으면 초대 코드 화면을 띄운다
    @State private var result: VillaCreateResult?

    var body: some View {
        Form {
            Section("빌라") {
                TextField("빌라 이름", text: $form.name)
                TextField("주소 (도착 알림 기준점으로 써요)", text: $form.address)
            }
            Section("주차장") {
                Picker("모양", selection: $form.layoutTemplate) {
                    ForEach(LayoutEditView.templates, id: \.0) { Text($0.1).tag($0.0) }
                }
                Picker("입구 방향", selection: $form.entranceSide) {
                    ForEach(LayoutEditView.entranceSides, id: \.0) { Text($0.1).tag($0.0) }
                }
                Stepper("면 수 \(form.slotCount)면", value: $form.slotCount, in: 1...30)
            }
            Section {
                TextField("세대 호수 (예: 101, 102, 201)", text: $form.unitsText)
                Picker("내 호수", selection: $form.myUnitNumber) {
                    Text("선택").tag("")
                    ForEach(form.unitNumbers, id: \.self) { Text("\($0)호").tag($0) }
                }
            } header: {
                Text("세대")
            } footer: {
                Text("면 배정은 만든 뒤 관리 탭에서 할 수 있어요")
            }
            if let message = errorMessage ?? form.problem {
                Text(message)
                    .foregroundStyle(SlottyColor.secondary)
            }
        }
        .font(SlottyFont.body)
        .navigationTitle("빌라 만들기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("만들기") {
                    Task { await create() }
                }
                .disabled(form.problem != nil || isCreating)
            }
        }
        // 만들면 초대 코드 화면 - [시작하기]로만 닫는다
        .sheet(isPresented: .constant(result != nil)) {
            if let result {
                inviteCodes(result)
                    .interactiveDismissDisabled()
            }
        }
    }

    private func create() async {
        isCreating = true
        defer { isCreating = false }
        do {
            result = try await repository.createVilla(form.request)
            errorMessage = nil
        } catch {
            errorMessage = (error as? APIError)?.serverMessage ?? "빌라를 만들지 못했어요"
        }
    }

    /// 1-6 초대 코드 공유 - 세대원에게 알려 줄 코드
    private func inviteCodes(_ result: VillaCreateResult) -> some View {
        NavigationStack {
            List {
                if result.geocodeFailed {
                    Text("주소를 좌표로 바꾸지 못해 도착 알림 기준점이 없어요. 관리 탭 빌라 정보에서 다시 잡을 수 있어요")
                        .foregroundStyle(SlottyColor.secondary)
                }
                Section("세대원에게 초대 코드를 알려 주세요") {
                    ForEach(result.inviteCodes) { invite in
                        LabeledContent("\(invite.unitNumber)호") {
                            Text(invite.code)
                                .textSelection(.enabled)
                        }
                    }
                }
            }
            .font(SlottyFont.body)
            .navigationTitle("빌라를 만들었어요")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("시작하기", action: onCreated)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        VillaCreateView(repository: MockHouseholdRepository(myUnit: nil)) {}
    }
}
