//
//  VisitListView.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/18/26.
//

import SwiftUI

/// 방문차량 탭: 우리 세대 방문을 예정 / 방문 중 / 지난 방문으로 나눠 보기
struct VisitListView: View {
    @State private var viewModel: VisitListViewModel
    @State private var filter: VisitFilter = .scheduled
    
    init(viewModel: VisitListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Picker("구분", selection: $filter) {
                ForEach(VisitFilter.allCases) { filter in
                    Text(filter.label).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            content
            Spacer()
        }
        .padding(20)
        .background(SlottyColor.background)
        .navigationTitle("방문차량")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                // 등록 화면은 다음 이슈(#32)에서 연결
                Button("+ 등록") {}
                    .disabled(true)
            }
        }
        .task {
            await viewModel.load()
        }
    }
    
    /// 불러오는 중 / 오류 / 빈 목록 / 방문 카드
    @ViewBuilder
    private var content: some View {
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .font(SlottyFont.body)
                .foregroundStyle(SlottyColor.secondary)
        } else if viewModel.visits == nil {
            ProgressView()
        } else {
            let visits = viewModel.visits(in: filter)
            if visits.isEmpty {
                Text("방문 내역이 없어요")
                    .font(SlottyFont.body)
                    .foregroundStyle(SlottyColor.secondary)
                    .padding(.top, 40)
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(visits) { visit in
                            VisitRow(visit: visit)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        VisitListView(viewModel: VisitListViewModel(repository: MockVisitRepository()))
    }
}
