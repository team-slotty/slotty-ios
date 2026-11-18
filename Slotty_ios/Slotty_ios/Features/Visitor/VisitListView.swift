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
    @State private var isRegistering = false
    /// 상세 시트로 보고 있는 방문, 닫혀 있으면 nil
    @State private var selectedVisit: Visit?
    /// 방문 등록에서 지정할 수 있는 면 번호
    private let spotOptions: [Int]
    
    init(viewModel: VisitListViewModel, spotOptions: [Int]) {
        _viewModel = State(initialValue: viewModel)
        self.spotOptions = spotOptions
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
                Button("+ 등록") {
                    isRegistering = true
                }
            }
        }
        .sheet(isPresented: $isRegistering) {
            VisitFormView(spotOptions: spotOptions) { form in
                await viewModel.register(form)
            }
        }
        .sheet(item: $selectedVisit) { visit in
            VisitDetailView(
                visit: visit,
                onEnd: { await viewModel.end(visit) },
                onDelete: { await viewModel.delete(visit) }
            )
            .presentationDetents([.medium])
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
                            Button {
                                selectedVisit = visit
                            } label: {
                                VisitRow(visit: visit)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        VisitListView(viewModel: VisitListViewModel(repository: MockVisitRepository()), spotOptions: [6, 7])
    }
}
