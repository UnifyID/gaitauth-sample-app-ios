//
// Copyright © 2020 UnifyID. All rights reserved.
// See LICENSE for additional details.
//

import Foundation

extension UnifyIDManager: ModelRefresher {
    func refreshModel() {
        dispatchPrecondition(condition: .onQueue(.main))
        guard let model = model else {
            interactor?.presentErrorAlert(
                title: "Failed refreshing model",
                message: "Model not set",
                completion: nil
            )
            return
        }

        model.refresh { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.interactor?.presentErrorAlert(
                        title: "Failed Refreshing Model",
                        message: error.localizedDescription,
                        completion: nil
                    )
                    return
                case .success(let changeType):
                    NotificationCenter.default.post(
                        ModelDidRefreshNotification(
                            sender: self,
                            date: Date(),
                            modelID: model.id,
                            status: model.status,
                            changeType: changeType
                        )
                    )
                }
                self.refreshCount += 1
            }
        }
    }
}
