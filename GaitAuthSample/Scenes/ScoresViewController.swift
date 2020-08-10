//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation
import UIKit
import GaitAuth
import Charts

class ScoresViewController: UIViewController {
    @IBOutlet weak private var chartView: ScoresBarChartView!

    var scores = [(date: Date, score: Double)]() {
        didSet {
            dispatchPrecondition(condition: .onQueue(.main))
            updateScores()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateScores()
    }

    private func updateScores() {
        dispatchPrecondition(condition: .onQueue(.main))
        chartView?.update(scores.map { ($0.date, $0.score) })
    }

    @IBAction private func dismissPressed() {
        dismiss(animated: true)
    }
}