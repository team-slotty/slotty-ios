//
//  VehicleRegisterView.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/22/26.
//

import SwiftUI

/// 차량 등록 - 차량번호를 입력하고 [등록하기], 등록하면 이전 화면으로
struct VehicleRegisterView: View {
    @State private var viewModel: VehicleRegisterViewModel
    /// 등록에 성공했을 때 - 현황판의 내 차량을 다시 불러온다
    let onRegistered: () async -> Void
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: VehicleRegisterViewModel, onRegistered: @escaping () async -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onRegistered = onRegistered
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            LabeledInput(label: "차량번호", placeholder: "예: 12가3456", text: $viewModel.plateNumber)
            if let message = viewModel.errorMessage ?? formatNotice {
                Text(message)
                    .font(SlottyFont.caption)
                    .foregroundStyle(SlottyColor.secondary)
            }
            Spacer()
            Button("등록하기") {
                Task {
                    if await viewModel.register() {
                        await onRegistered()
                        dismiss()
                    }
                }
            }
            .buttonStyle(.slottyPrimary)
            .disabled(!viewModel.canRegister)
        }
        .padding(20)
        .background(SlottyColor.background)
        .navigationTitle("차량 등록")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    /// 입력했는데 형식이 맞지 않을 때 안내
    private var formatNotice: String? {
        guard !viewModel.plateNumber.isEmpty, !viewModel.isValidPlateNumber else { return nil }
        return "차량번호 형식을 확인해 주세요 (예: 12가3456, 서울12가3456)"
    }
}

#Preview {
    NavigationStack {
        VehicleRegisterView(viewModel: VehicleRegisterViewModel(repository: MockVehicleRepository())) {}
    }
}
