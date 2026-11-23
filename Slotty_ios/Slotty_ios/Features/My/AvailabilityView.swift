//
//  AvailabilityView.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import SwiftUI

/// 6-3 가용시간 - 내 면을 비워 두는 시간 목록, 등록, 오늘만 빼기, 삭제
struct AvailabilityView: View {
    @State private var viewModel: AvailabilityViewModel
    @State private var isRegistering = false
    
    init(viewModel: AvailabilityViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        List {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(SlottyColor.secondary)
            }
            if let items = viewModel.items, items.isEmpty {
                Text("등록한 가용시간이 없어요")
                    .foregroundStyle(SlottyColor.secondary)
            }
            ForEach(viewModel.items ?? []) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(item.spotLabel) · \(item.summary)")
                        .font(SlottyFont.headline)
                    if !item.skippedDates.isEmpty {
                        Text("빼는 날: " + item.skippedDates.joined(separator: ", "))
                            .font(SlottyFont.caption)
                            .foregroundStyle(SlottyColor.secondary)
                    }
                }
                .swipeActions {
                    Button("삭제", role: .destructive) {
                        Task { await viewModel.delete(item) }
                    }
                    if item.isRecurring {
                        Button("오늘만 빼기") {
                            Task { await viewModel.skipToday(item) }
                        }
                    }
                }
            }
            Text("※ 가용시간에는 다른 세대가 내 면을 쓸 수 있어요. 왼쪽으로 밀어 삭제하거나 오늘만 뺄 수 있어요")
                .font(SlottyFont.caption)
                .foregroundStyle(SlottyColor.secondary)
        }
        .font(SlottyFont.body)
        .navigationTitle("가용시간")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("+ 등록") { isRegistering = true }
            }
        }
        .sheet(isPresented: $isRegistering) {
            AvailabilityFormView { await viewModel.register($0) }
        }
        .task { await viewModel.load() }
    }
}

/// 가용시간 등록 - 매주 반복(요일) 또는 하루만(날짜), 종일 또는 시간
struct AvailabilityFormView: View {
    /// 등록 - 성공하면 true
    let onRegister: (AvailabilityForm) async -> Bool
    
    @Environment(\.dismiss) private var dismiss
    @State private var form = AvailabilityForm()
    @State private var failed = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("매주 반복", isOn: $form.isRecurring)
                    if form.isRecurring {
                        HStack {
                            ForEach(Availability.allDays, id: \.self) { day in
                                Button(Availability.dayLabel(day)) {
                                    if form.days.contains(day) {
                                        form.days.remove(day)
                                    } else {
                                        form.days.insert(day)
                                    }
                                }
                                .buttonStyle(.borderless)
                                .fontWeight(form.days.contains(day) ? .bold : .regular)
                                .foregroundStyle(form.days.contains(day) ? SlottyColor.primary : SlottyColor.secondary)
                                .frame(maxWidth: .infinity)
                            }
                        }
                    } else {
                        DatePicker("날짜", selection: $form.date, in: Date()..., displayedComponents: .date)
                    }
                }
                Section {
                    Toggle("종일", isOn: $form.allDay)
                    if !form.allDay {
                        Picker("시작", selection: $form.startTime) {
                            ForEach(AvailabilityForm.times, id: \.self) { Text($0) }
                        }
                        Picker("끝", selection: $form.endTime) {
                            ForEach(AvailabilityForm.times, id: \.self) { Text($0) }
                        }
                    }
                }
                if let problem = form.problem {
                    Text(problem)
                        .foregroundStyle(SlottyColor.secondary)
                } else if failed {
                    Text("가용시간을 등록하지 못했어요")
                        .foregroundStyle(SlottyColor.secondary)
                }
            }
            .font(SlottyFont.body)
            .navigationTitle("가용시간 등록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("등록") {
                        Task {
                            if await onRegister(form) {
                                dismiss()
                            } else {
                                failed = true
                            }
                        }
                    }
                    .disabled(form.problem != nil)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AvailabilityView(viewModel: AvailabilityViewModel(repository: MockAvailabilityRepository(), spotNumber: 1))
    }
}
