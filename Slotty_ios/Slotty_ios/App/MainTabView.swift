//
//  MainTabView.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/16/26.
//

import SwiftUI

/// 메인 화면 하단 탭
struct MainTabView: View {
    let parkingViewModel: ParkingHomeViewModel
    let searchRepository: any VehicleSearchRepository
    
    var body: some View {
        TabView {
            Tab("홈", systemImage: "house") {
                NavigationStack {
                    ParkingHomeView(viewModel: parkingViewModel, searchRepository: searchRepository)
                }
            }
            Tab("방문차량", systemImage: "car.2") {
                placeholder("방문차량")
            }
            Tab("마이", systemImage: "person") {
                NavigationStack {
                    MyHomeView(viewModel: parkingViewModel)
                }
            }
            Tab("관리", systemImage: "gearshape") {
                placeholder("관리")
            }
        }
        .tint(SlottyColor.primary)
    }
    
    /// 아직 만들지 않은 탭 - 임시 화면 생성
    private func placeholder(_ title: String) -> some View {
        Text("\(title) 준비 중")
            .font(SlottyFont.body)
            .foregroundStyle(SlottyColor.secondary)
    }
}

#Preview {
    MainTabView(
        parkingViewModel: ParkingHomeViewModel(repository: MockParkingRepository()),
        searchRepository: MockVehicleSearchRepository()
    )
}
