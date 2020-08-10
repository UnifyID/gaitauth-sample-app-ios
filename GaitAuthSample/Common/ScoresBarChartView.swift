//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import Charts

class ScoresBarChartView: Charts.BarChartView {
    typealias TimestampScore = (date: Date, value: Double)

    static let lowScore = UIColor(red: 1.0, green: 0.341, blue: 0.133, alpha: 1)
    static let mediumLowScore = UIColor(red: 1.0, green: 0.596, blue: 0, alpha: 1)
    static let mediumHighScore = UIColor(red: 1.0, green: 0.231, blue: 0, alpha: 1)
    static let highScore = UIColor(red: 0.298, green: 0.686, blue: 0.314, alpha: 1)

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    private func configure() {
        dispatchPrecondition(condition: .onQueue(.main))
        xAxis.labelTextColor = ColorCompatibility.label
        xAxis.spaceMin = 0.15
        leftAxis.labelTextColor = ColorCompatibility.label
        rightAxis.labelTextColor = ColorCompatibility.label
        legend.textColor = ColorCompatibility.label
        legend.enabled = false
        rightAxis.axisMaximum = -1
        rightAxis.axisMinimum = 1
        leftAxis.enabled = false
        xAxis.enabled = false
        noDataText = "No Walking Detected"
        noDataTextColor = ColorCompatibility.label
        noDataTextAlignment = .center
        backgroundColor = ColorCompatibility.systemBackground
    }

    func update(_ data: [TimestampScore]?) {
        dispatchPrecondition(condition: .onQueue(.main))
        guard let data = data, !data.isEmpty, let entries = Self.entriesForScores(data) else {
            self.data = nil
            notifyDataSetChanged()
            return
        }

        let dataSet = BarChartDataSet(entries: entries)
        dataSet.colors = entries.map { Self.colorForScore($0.y) }
        dataSet.axisDependency = .right
        dataSet.drawValuesEnabled = false
        self.data = BarChartData(dataSet: dataSet)
        rightAxis.axisMinimum = -1
        rightAxis.axisMaximum = 1
        notifyDataSetChanged()
    }

    private static func entriesForScores(_ scores: [TimestampScore]) -> [BarChartDataEntry]? {
        guard let firstDate = scores.first?.date else {
            return nil
        }

        var tsToScore = [Double: Double]()
        scores.forEach {
            let timeOffset = Double($0.date.timeIntervalSince(firstDate))
            var score = Double($0.value)
            let roundedTime = timeOffset.rounded(.toNearestOrEven)
            if let existingScore = tsToScore[roundedTime] {
                score = max(score, existingScore)
            }
            tsToScore[roundedTime] = score
        }
        return tsToScore.keys.sorted().map {
            // We've already ensured that every entry has at least one item.
            // swiftlint:disable force_unwrapping
            return BarChartDataEntry(x: $0, y: tsToScore[$0]!)
        }
    }

    private static func colorForScore(_ value: Double) -> UIColor {
        if value > 0.85 {
            return Self.highScore
        } else if value > 0 {
            return Self.mediumHighScore
        } else if value > -0.5 {
            return Self.mediumLowScore
        }
        return Self.lowScore
    }
}
