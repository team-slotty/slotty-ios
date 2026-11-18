//
//  SlottyFont.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/14/26.
//

import SwiftUI

/// 글자 스타일
/// 임시 값, figma 값 추후 확인 후 조정 예쩡
enum SlottyFont {
    /// 화면 큰 제목 (Figma 확정: Bold 24)
        static let largeTitle = Font.custom("NotoSansKR-Bold", size: 24)
        /// 홈 상단 빌라 이름
        static let title = Font.custom("NotoSansKR-Bold", size: 20)
        /// 카드/목록 제목, 그리드 칸 번호
        static let headline = Font.custom("NotoSansKR-Bold", size: 16)
        /// 부제 (Figma 확정: Medium 14)
        static let subtitle = Font.custom("NotoSansKR-Medium", size: 14)
        /// 본문
        static let body = Font.custom("NotoSansKR-Regular", size: 14)
        /// 작은 안내, 범례 칩, 카드 소제목
        static let caption = Font.custom("NotoSansKR-Regular", size: 12)
        /// 그리드 칸 안의 상태 글자
        static let caption2 = Font.custom("NotoSansKR-Regular", size: 11)
        /// 버튼 글자
        static let button = Font.custom("NotoSansKR-Bold", size: 16)
}
