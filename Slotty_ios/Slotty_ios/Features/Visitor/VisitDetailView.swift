//
//  VisitDetailView.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/18/26.
//

import SwiftUI

/// 방문 상세: 차량번호, 일시, 지정 면 + 시작 전 [삭제] / 시작 후 [방문 종료]
struct VisitDetailView: View {
    let visit: Visit
    /// [방문 종료] - 성공하면 true
    let onEnd: () async -> Bool
    /// [방문 삭제] - 성공하면 true
    let onDelete: () async -> Bool
    /// 처리가 실패했을 때 보여 줄 서버 문구, 없으면 공통 문구
    var failureMessage: String? = nil
    /// 등록한 사람과 연락처 불러오기
    var loadDetail: () async -> VisitDetail? = { nil }
    /// 시작 전 방문 수정 - 성공하면 true, nil이면 [방문 수정]을 보이지 않는다
    var onUpdate: ((VisitForm) async -> Bool)? = nil
    /// 수정할 때 그 시간에 지정할 수 있는 면 불러오기
    var loadSpotOptions: (Date, Date) async -> [Int] = { _, _ in [] }
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var detail: VisitDetail?
    @State private var isEditing = false
    /// 수정에 성공했는지 - 수정 화면이 닫히면 상세도 닫는다 (바뀐 방문은 목록에서 다시 보기)
    @State private var didUpdate = false
    @State private var isWorking = false
    @State private var failed = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("차량번호", value: visit.plateNumber)
                    LabeledContent("상태", value: visit.status().label)
                    LabeledContent("시작", value: visit.startAt.formatted(date: .abbreviated, time: .shortened))
                    LabeledContent("종료", value: visit.endAt.formatted(date: .abbreviated, time: .shortened))
                    LabeledContent("주차면", value: visit.spotNumber.map { "\($0)번 면" } ?? "지정 안 함")
                    if let registeredBy = detail?.registeredBy {
                        LabeledContent("등록한 사람", value: registeredBy)
                    }
                }
                if let phoneNumber = detail?.phoneNumber, let url = URL(string: "tel:" + phoneNumber.filter(\.isNumber)) {
                    Button("등록한 사람에게 전화") {
                        openURL(url)
                    }
                }
                if visit.canDelete(), onUpdate != nil {
                    Button("방문 수정") {
                        isEditing = true
                    }
                }
                if visit.canEnd() {
                    Button("방문 종료") {
                        Task { await run(onEnd) }
                    }
                    .disabled(isWorking)
                }
                if visit.canDelete() {
                    Button("방문 삭제", role: .destructive) {
                        Task { await run(onDelete) }
                    }
                    .disabled(isWorking)
                }
                if failed {
                    Text(failureMessage ?? "처리하지 못했어요")
                        .foregroundStyle(SlottyColor.secondary)
                }
            }
            .font(SlottyFont.body)
            .task {
                detail = await loadDetail()
            }
            .sheet(isPresented: $isEditing, onDismiss: { if didUpdate { dismiss() } }) {
                VisitFormView(
                    loadSpotOptions: loadSpotOptions,
                    loadFrequentPlates: { [] },
                    failureMessage: failureMessage,
                    initialForm: VisitForm(visit: visit),
                    title: "방문 수정",
                    submitTitle: "저장"
                ) { form in
                    let isUpdated = await onUpdate?(form) ?? false
                    didUpdate = isUpdated
                    return isUpdated
                }
            }
            .navigationTitle("방문 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { dismiss() }
                }
            }
        }
    }
    
    /// 성공하면 닫고, 실패하면 안내 문구를 띄운다
    private func run(_ action: () async -> Bool) async {
        isWorking = true
        if await action() {
            dismiss()
        } else {
            failed = true
        }
        isWorking = false
    }
}

#Preview {
    VisitDetailView(visit: MockVisitData.visits[0], onEnd: { true }, onDelete: { true })
}
