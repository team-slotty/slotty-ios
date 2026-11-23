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
    /// 홈 카드와 방문차량 탭이 같은 방문 목록을 본다
    let visitViewModel: VisitListViewModel
    /// 마이 탭의 차량 등록에 쓰는 저장소
    let vehicleRepository: any VehicleRepository
    /// 마이 탭 설정의 로그아웃에 쓰는 저장소
    let authRepository: any AuthRepository
    /// 마이 탭 설정의 연락처 공개, 탈퇴에 쓰는 저장소
    let accountRepository: any AccountRepository
    /// 마이 탭의 입출차 이력, 미확인 기록에 쓰는 저장소
    let historyRepository: any HistoryRepository
    /// 관리 탭의 세대 관리에 쓰는 저장소
    let adminRepository: any AdminRepository
    /// 빌라 관리자인지 - 관리자에게만 관리 탭을 보인다
    @State private var isAdmin = false
    
    var body: some View {
        TabView {
            Tab("홈", systemImage: "house") {
                NavigationStack {
                    ParkingHomeView(
                        viewModel: parkingViewModel,
                        visitViewModel: visitViewModel,
                        searchRepository: searchRepository
                    )
                }
            }
            Tab("방문차량", systemImage: "car.2") {
                NavigationStack {
                    VisitListView(viewModel: visitViewModel)
                }
            }
            Tab("마이", systemImage: "person") {
                NavigationStack {
                    MyHomeView(
                        viewModel: parkingViewModel,
                        vehicleRepository: vehicleRepository, authRepository: authRepository,
                        accountRepository: accountRepository, historyRepository: historyRepository)
                }
            }
            if isAdmin {
                Tab("관리", systemImage: "gearshape") {
                    NavigationStack {
                        AdminHomeView(viewModel: AdminHouseholdsViewModel(repository: adminRepository))
                    }
                }
            }
        }
        .tint(SlottyColor.primary)
        .task {
            isAdmin = (try? await adminRepository.fetchIsAdmin()) ?? false
        }
    }
}

#Preview {
    MainTabView(
        parkingViewModel: ParkingHomeViewModel(repository: MockParkingRepository()),
        searchRepository: MockVehicleSearchRepository(),
        visitViewModel: VisitListViewModel(repository: MockVisitRepository()),
        vehicleRepository: MockVehicleRepository(),
        authRepository: MockAuthRepository(),
        accountRepository: MockAccountRepository(),
        historyRepository: MockHistoryRepository(),
        adminRepository: MockAdminRepository()
    )
}
