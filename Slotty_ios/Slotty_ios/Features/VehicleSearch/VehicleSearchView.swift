//
//  VehicleSearchView.swift
//  SlottyTests
//
//  Created by WuHeuiJeong on 11/17/26.
//

import SwiftUI

/// 차량 검색: 차량번호 뒤 4자리로 누구 차인지 찾기
struct VehicleSearchView: View {
    @State private var viewModel: VehicleSearchViewModel
    
    init(viewModel: VehicleSearchViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            searchBar
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(SlottyFont.caption)
                    .foregroundStyle(SlottyColor.secondary)
            }
            if let results = viewModel.results {
                resultList(results)
            }
            Spacer()
            notice
        }
        .padding(20)
        .background(SlottyColor.background)
        .navigationTitle("차량 검색")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    /// 숫자 입력칸과 [검색] 버튼
    private var searchBar: some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(SlottyColor.secondary)
                TextField("차량번호 뒤 4자리 검색", text: $viewModel.query)
                    .font(SlottyFont.body)
                    .keyboardType(.numberPad)
            }
            .padding(.horizontal, 12)
            .frame(minHeight: 46)
            .background(SlottyColor.fill, in: RoundedRectangle(cornerRadius: 8))
            Button("검색") {
                Task { await viewModel.search() }
            }
            .buttonStyle(.slottyPrimary)
            .frame(width: 72)
            .disabled(!viewModel.canSearch)
        }
    }
    
    /// "검색 결과 N건"과 결과 목록
    private func resultList(_ results: [VehicleSearchResult]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("검색 결과 \(results.count)건")
                .font(SlottyFont.caption)
                .foregroundStyle(SlottyColor.secondary)
            if results.isEmpty {
                Text("일치하는 차량이 없어요")
                    .font(SlottyFont.body)
                    .foregroundStyle(SlottyColor.primary)
            }
            ForEach(results) { result in
                VehicleSearchRow(result: result)
            }
        }
    }
    
    /// 화면 아래 안내 - 남은 검색 횟수는 한 번 검색한 뒤부터 보인다
    private var notice: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let remainingCount = viewModel.remainingCount {
                Text("※ 오늘 남은 검색 \(remainingCount)회 · 전체 목록 조회는 제공하지 않아요")
            }
            Text("※ [전화 걸기]는 연락처 공개에 동의한 세대만 보여요")
        }
        .font(SlottyFont.caption)
        .foregroundStyle(SlottyColor.secondary)
    }
}

#Preview {
    NavigationStack {
        VehicleSearchView(viewModel: VehicleSearchViewModel(repository: MockVehicleSearchRepository()))
    }
}
