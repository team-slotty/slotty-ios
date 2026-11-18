//
//  VisitFormView.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/18/26.
//

import SwiftUI

/// 방문차량 등록: 차량번호, 방문 일시, 주차면(선택)
struct VisitFormView: View {
    /// 지정할 수 있는 면 번호 - 공용 면과 가용시간 중인 면
    let spotOptions: [Int]
    /// 등록 - 성공하면 true
    let onRegister: (VisitForm) async -> Bool

    @Environment(\.dismiss) private var dismiss
    @State private var form = VisitForm()
    @State private var isRegistering = false
    @State private var failed = false

    var body: some View {
        NavigationStack {
            Form {
                Section("차량번호") {
                    TextField("예: 12가3456", text: $form.plateNumber)
                }
                Section("방문 일시") {
                    DatePicker("시작", selection: $form.startAt)
                    DatePicker("종료", selection: $form.endAt)
                }
                Section("주차면 (선택)") {
                    if spotOptions.isEmpty {
                        Text("지금 이용 가능한 면이 없어요")
                            .foregroundStyle(SlottyColor.secondary)
                    } else {
                        Picker("면 지정", selection: $form.spotNumber) {
                            Text("지정 안 함").tag(Int?.none)
                            ForEach(spotOptions, id: \.self) { number in
                                Text("\(number)번 면").tag(Int?.some(number))
                            }
                        }
                    }
                }
                if let problem = form.problem {
                    Text(problem)
                        .foregroundStyle(SlottyColor.secondary)
                } else if failed {
                    Text("방문을 등록하지 못했어요")
                        .foregroundStyle(SlottyColor.secondary)
                }
            }
            .font(SlottyFont.body)
            .navigationTitle("방문차량 등록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("등록") {
                        Task { await register() }
                    }
                    .disabled(form.problem != nil || isRegistering)
                }
            }
        }
    }

    /// 등록에 성공하면 닫고, 실패하면 안내 문구를 띄운다
    private func register() async {
        isRegistering = true
        if await onRegister(form) {
            dismiss()
        } else {
            failed = true
        }
        isRegistering = false
    }
}

#Preview {
    VisitFormView(spotOptions: [6, 7]) { _ in true }
}
