//
//  VisitFormView.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/18/26.
//

import SwiftUI

/// 방문차량 등록: 차량번호, 방문 일시, 주차면(선택)
struct VisitFormView: View {
    /// 그 시간에 지정할 수 있는 면 불러오기 - 공용 면과 가용시간이 겹치는 면
    let loadSpotOptions: (Date, Date) async -> [Int]
    /// 자주 오는 차량번호 불러오기
    let loadFrequentPlates: () async -> [String]
    /// 등록이 실패했을 때 보여 줄 서버 문구, 없으면 공통 문구
    var failureMessage: String? = nil
    /// 등록 - 성공하면 true
    let onRegister: (VisitForm) async -> Bool
    
    @Environment(\.dismiss) private var dismiss
    @State private var form = VisitForm()
    /// 지금 고른 시간에 지정할 수 있는 면 번호
    @State private var spotOptions: [Int] = []
    /// 자주 오는 차량번호 - 누르면 차량번호 칸을 채운다
    @State private var frequentPlates: [String] = []
    @State private var isRegistering = false
    @State private var failed = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("차량번호") {
                    TextField("예: 12가3456", text: $form.plateNumber)
                }
                if !frequentPlates.isEmpty {
                    Section("자주 오는 차") {
                        ForEach(frequentPlates, id: \.self) { plate in
                            Button(plate) {
                                form.plateNumber = plate
                            }
                        }
                    }
                }
                Section("방문 일시") {
                    DatePicker("시작", selection: $form.startAt)
                    DatePicker("종료", selection: $form.endAt)
                }
                Section("주차면 (선택)") {
                    if spotOptions.isEmpty {
                        Text("그 시간에 지정할 수 있는 면이 없어요")
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
                    Text(failureMessage ?? "방문을 등록하지 못했어요")
                        .foregroundStyle(SlottyColor.secondary)
                }
            }
            .font(SlottyFont.body)
            .task {
                frequentPlates = await loadFrequentPlates()
            }
            .task(id: [form.startAt, form.endAt]) {
                await reloadSpotOptions()
            }
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
    
    /// 시간을 바꿀 때마다 지정할 수 있는 면을 다시 받고, 고른 면이 빠졌으면 지정을 푼다
    private func reloadSpotOptions() async {
        guard form.startAt < form.endAt else {
            spotOptions = []
            return
        }
        spotOptions = await loadSpotOptions(form.startAt, form.endAt)
        if let spotNumber = form.spotNumber, !spotOptions.contains(spotNumber) {
            form.spotNumber = nil
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
    VisitFormView(loadSpotOptions: { _, _ in [6, 7] }, loadFrequentPlates: { ["78마3456"] }) { _ in true }
}
