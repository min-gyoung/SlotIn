//
//  SlotInApp.swift
//  SlotIn
//
//  Created by 김민경 on 6/2/25.
//

import SwiftUI

@main
struct SlotInApp: App {
    var body: some Scene {
        WindowGroup {
            DetailInputView(startDate: Date(), endDate: Date() + 3600, event: .init(eventStore: .init()))
        }
    }
}
