//
//  HistoryViews.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/23/26.
//

import SwiftUI

/// 입출차 이력 - 차량번호, 면, 입차/출차 시각과 방식
struct ParkingHistoryView: View {
    @State private var viewModel: HistoryViewModel
    
    init(viewModel: HistoryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        List {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(SlottyColor.secondary)
            }
            if let items = viewModel.parkingHistory, items.isEmpty {
                Text("입출차 기록이 없어요")
                    .foregroundStyle(SlottyColor.secondary)
            }
            ForEach(viewModel.parkingHistory ?? []) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(item.plateNumber) · \(item.spotLabel)")
                        .font(SlottyFont.headline)
                    Text("입차 \(time(item.enteredAt)) \(ParkingHistoryItem.methodLabel(item.enterMethod)) \(item.enteredBy ?? "")")
                    Text(item.exitedAt.map { "출차 \(time($0)) \(ParkingHistoryItem.methodLabel(item.exitMethod)) \(item.exitedBy ?? "")" } ?? "주차 중")
                }
                .font(SlottyFont.caption)
                .foregroundStyle(SlottyColor.primary)
            }
        }
        .navigationTitle("입출차 이력")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadParkingHistory()
        }
        .refreshable {
            await viewModel.loadParkingHistory()
        }
    }
}

/// 미확인 기록 - 면, 기록한 사람, 기록/해제 시각 (관리자)
struct UnidentifiedReportsView: View {
    @State private var viewModel: HistoryViewModel
    
    init(viewModel: HistoryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        List {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(SlottyColor.secondary)
            }
            if let items = viewModel.unidentifiedReports, items.isEmpty {
                Text("미확인 기록이 없어요")
                    .foregroundStyle(SlottyColor.secondary)
            }
            ForEach(viewModel.unidentifiedReports ?? []) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(item.spotLabel) · \(item.plateNumber ?? "번호 모름")")
                        .font(SlottyFont.headline)
                    Text("기록 \(time(item.reportedAt)) \(item.reportedBy ?? "")")
                    Text(item.resolvedAt.map { "\(item.resolveLabel) \(time($0))" } ?? item.resolveLabel)
                }
                .font(SlottyFont.caption)
                .foregroundStyle(SlottyColor.primary)
            }
        }
        .navigationTitle("미확인 기록")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadUnidentifiedReports()
        }
        .refreshable {
            await viewModel.loadUnidentifiedReports()
        }
    }
}

/// 예: 11/23 14:05
private func time(_ date: Date) -> String {
    date.formatted(.dateTime.month(.defaultDigits).day().hour().minute())
}

#Preview("입출차 이력") {
    NavigationStack {
        ParkingHistoryView(viewModel: HistoryViewModel(repository: MockHistoryRepository()))
    }
}

#Preview("미확인 기록") {
    NavigationStack {
        UnidentifiedReportsView(viewModel: HistoryViewModel(repository: MockHistoryRepository()))
    }
}
