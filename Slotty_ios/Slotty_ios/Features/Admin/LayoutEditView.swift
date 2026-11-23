//
//  LayoutEditView.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import SwiftUI

/// 7-3 배치 변경 - 주차장 모양, 입구 방향, 면 수
struct LayoutEditView: View {
    let repository: any VillaRepository
    let villa: VillaInfo
    /// 바꾼 뒤 - 빌라 정보를 다시 불러온다
    let onChanged: () async -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var template: String
    @State private var entranceSide: String
    @State private var slotCount: Int
    @State private var isConfirming = false
    @State private var message: String?

    /// 서버 값과 화면 이름
    static let templates = [("LINE", "일렬"), ("DOUBLE", "2열"), ("L_SHAPE", "ㄱ자")]
    static let entranceSides = [("TOP", "위"), ("BOTTOM", "아래"), ("LEFT", "왼쪽"), ("RIGHT", "오른쪽")]

    init(repository: any VillaRepository, villa: VillaInfo, onChanged: @escaping () async -> Void) {
        self.repository = repository
        self.villa = villa
        self.onChanged = onChanged
        _template = State(initialValue: villa.layoutTemplate)
        _entranceSide = State(initialValue: villa.entranceSide)
        _slotCount = State(initialValue: villa.slotCount)
    }

    var body: some View {
        Form {
            Section {
                Picker("모양", selection: $template) {
                    ForEach(Self.templates, id: \.0) { Text($0.1).tag($0.0) }
                }
                Picker("입구 방향", selection: $entranceSide) {
                    ForEach(Self.entranceSides, id: \.0) { Text($0.1).tag($0.0) }
                }
                // 서버 규칙: 1~30면
                Stepper("면 수 \(slotCount)면", value: $slotCount, in: 1...30)
            } footer: {
                Text("남은 면의 배정은 그대로, 늘린 면은 공용으로 추가돼요. 줄일 때 기록이 남은 면은 지울 수 없어요.")
            }
            if let message {
                Text(message)
                    .foregroundStyle(SlottyColor.secondary)
            }
            Button("배치 바꾸기") {
                isConfirming = true
            }
            .disabled(template == villa.layoutTemplate && entranceSide == villa.entranceSide && slotCount == villa.slotCount)
        }
        .font(SlottyFont.body)
        .navigationTitle("배치 변경")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("주차장 배치를 바꿀까요?", isPresented: $isConfirming, titleVisibility: .visible) {
            Button("바꾸기", role: .destructive) {
                Task { await change() }
            }
        } message: {
            Text("모든 입주민의 현황판 모양이 바뀌어요")
        }
    }

    private func change() async {
        do {
            try await repository.changeLayout(template: template, entranceSide: entranceSide, slotCount: slotCount)
            await onChanged()
            dismiss()
        } catch {
            message = (error as? APIError)?.serverMessage ?? "배치를 바꾸지 못했어요"
        }
    }
}

/// 7-4 면 배정 - 면마다 세대 또는 공용
struct SlotAssignmentView: View {
    let repository: any VillaRepository
    /// 고를 수 있는 세대
    let households: [AdminHousehold]

    @Environment(\.dismiss) private var dismiss
    @State private var slots: [AdminSlot] = []
    /// 면 id -> 고른 세대 id (nil이면 공용)
    @State private var selection: [Int: Int?] = [:]
    @State private var message: String?

    var body: some View {
        Form {
            if let message {
                Text(message)
                    .foregroundStyle(SlottyColor.secondary)
            }
            ForEach(slots) { slot in
                Picker(slot.label, selection: binding(for: slot)) {
                    Text("공용").tag(Int?.none)
                    ForEach(households) { household in
                        Text("\(household.unitNumber)호").tag(Int?.some(household.id))
                    }
                }
            }
        }
        .font(SlottyFont.body)
        .navigationTitle("면 배정")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("저장") {
                    Task { await save() }
                }
                .disabled(slots.isEmpty)
            }
        }
        .task { await load() }
    }

    /// 면 하나의 고른 세대 - 처음에는 지금 배정된 세대
    private func binding(for slot: AdminSlot) -> Binding<Int?> {
        Binding(
            get: { selection[slot.id] ?? nil },
            set: { selection[slot.id] = $0 }
        )
    }

    /// 면 목록을 받고, 배정된 호수로 세대 id를 찾아 처음 값으로
    private func load() async {
        do {
            slots = try await repository.fetchSlots()
            for slot in slots {
                selection[slot.id] = households.first { $0.unitNumber == slot.unitNumber }?.id
            }
        } catch {
            message = (error as? APIError)?.serverMessage ?? "면 목록을 불러오지 못했어요"
        }
    }

    private func save() async {
        do {
            try await repository.assign(selection)
            dismiss()
        } catch {
            message = (error as? APIError)?.serverMessage ?? "면 배정을 저장하지 못했어요"
        }
    }
}

#Preview("배치 변경") {
    let villa = VillaInfo(name: "슬로티빌라", address: "주소", layoutTemplate: "DOUBLE", entranceSide: "BOTTOM", slotCount: 7, householdCount: 6, hasAnchor: true)
    NavigationStack {
        LayoutEditView(repository: MockVillaRepository(), villa: villa) {}
    }
}
