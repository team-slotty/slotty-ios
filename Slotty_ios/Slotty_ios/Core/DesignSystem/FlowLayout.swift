//
//  FlowLayout.swift
//  Slotty
//
//  Created by WuHeuiJeong on 11/14/26.
//

import SwiftUI

/// 자식 뷰를 가로로 놓다가 자리가 모자라면 다음 줄로 넘기는 배치 (칩 목록용)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = makeRows(subviews, maxWidth: proposal.width ?? .infinity)
        let width = rows.map { rowWidth($0, subviews) }.max() ?? 0
        let height = rows.map { rowHeight($0, subviews) }.reduce(0, +)
            + spacing * CGFloat(max(rows.count - 1, 0))
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in makeRows(subviews, maxWidth: bounds.width) {
            var x = bounds.minX
            for index in row {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += rowHeight(row, subviews) + spacing
        }
    }

    /// 줄마다 들어갈 자식 번호 목록
    private func makeRows(_ subviews: Subviews, maxWidth: CGFloat) -> [[Int]] {
        var rows: [[Int]] = [[]]
        var x: CGFloat = 0
        for index in subviews.indices {
            let width = subviews[index].sizeThatFits(.unspecified).width
            if x + width > maxWidth, !rows[rows.count - 1].isEmpty {
                rows.append([])
                x = 0
            }
            rows[rows.count - 1].append(index)
            x += width + spacing
        }
        return rows
    }

    private func rowWidth(_ row: [Int], _ subviews: Subviews) -> CGFloat {
        let widths = row.map { subviews[$0].sizeThatFits(.unspecified).width }
        return widths.reduce(0, +) + spacing * CGFloat(max(row.count - 1, 0))
    }

    private func rowHeight(_ row: [Int], _ subviews: Subviews) -> CGFloat {
        row.map { subviews[$0].sizeThatFits(.unspecified).height }.max() ?? 0
    }
}

#Preview {
    FlowLayout {
        ForEach(["사용 중", "빈 면", "비어 있음(가용)", "방문 중", "미확인", "공용", "확인 필요"], id: \.self) { text in
            Text(text)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .overlay { Capsule().strokeBorder(.gray) }
        }
    }
    .padding(20)
}
