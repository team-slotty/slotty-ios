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
    
    @Environment(\.dismiss) private var dismiss
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
