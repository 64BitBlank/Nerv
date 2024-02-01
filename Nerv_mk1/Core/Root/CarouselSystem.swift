//
//  RequestView2.swift
//  Nerv_mk1
//
//  Created by James Hallett on 21/11/2023.
//

import SwiftUI

struct CarouselConfig {
    var spacing: CGFloat
    var cardHeight: CGFloat
    var overlapSpacing: CGFloat

    var cardWidth: CGFloat { UIScreen.main.bounds.width - (overlapSpacing*2) - (spacing*2) }
    var leftPadding: CGFloat { overlapSpacing + spacing }
    var totalMovement: CGFloat { cardWidth + spacing }

    static let `default`: Self = CarouselConfig(spacing: 3, cardHeight: 750, overlapSpacing: 3)
}

public class CarouselModel: ObservableObject {
    @Published var activeCard: Int = 0
    @Published var screenDrag: Float = 0.0
}

struct Carousel<ItemView : View> : View {
    let viewForItem: (Int) -> ItemView
    let itemCount: Int
    let config: CarouselConfig
    @GestureState var isDetectingLongPress = false
    @ObservedObject var state: CarouselModel = CarouselModel()
    @State var isSelected: Bool = false

    @inlinable public init(items: Int,
                           _ config: CarouselConfig = .default,
                           @ViewBuilder _ viewForItem: @escaping (Int) -> ItemView) {
        self.viewForItem = viewForItem
        self.itemCount = items
        self.config = config
    }

    var body: some View {
        let totalSpacing = (CGFloat(itemCount) - 1) * config.spacing
        let totalCanvasWidth = (config.cardWidth * CGFloat(itemCount)) + totalSpacing
        let xOffsetToShift = (totalCanvasWidth - UIScreen.main.bounds.width) / 2

        let activeOffset = xOffsetToShift + (config.leftPadding) - (config.totalMovement * CGFloat(state.activeCard))
        let nextOffset = xOffsetToShift + (config.leftPadding) - (config.totalMovement * CGFloat(state.activeCard) + 1)

        let calcOffset = activeOffset != nextOffset ? activeOffset + CGFloat(state.screenDrag) : CGFloat(activeOffset)


        return HStack(alignment: .center, spacing: config.spacing) {
            ForEach((0..<itemCount), id: \.self) { i in
                viewForItem(i)
                    .scaleEffect(x: 1, y: scale(for: i))
                    .animation(.spring(), value: state.activeCard)
            }
        }
        .offset(x: calcOffset, y: 0)
        .gesture(DragGesture().updating($isDetectingLongPress) { currentState, gestureState, transaction in
            state.screenDrag = Float(currentState.translation.width)
        }.onEnded { value in
            state.screenDrag = 0

            if value.translation.width < -50 && state.activeCard < itemCount - 1 {
                state.activeCard += 1
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }

            if value.translation.width > 50 && state.activeCard > 0 {
                if state.activeCard - 1 < 0 { return }

                state.activeCard -= 1
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }
        })
    }
    private func scale(for index: Int) -> CGFloat {
        let itemOffset = CGFloat(index - state.activeCard)
        let scale = 1 - (1 * abs(itemOffset))
        return max(scale, 0.7)
    }
}

extension View {
    func carouselItem(_ config: CarouselConfig = .default) -> some View {
        return self
            .frame(width: UIScreen.main.bounds.width - (config.overlapSpacing*2) - (config.spacing*2),
                   height: config.cardHeight)
            .cornerRadius(5)
            .animation(.spring())
            .transition(.slide)
    }
}
