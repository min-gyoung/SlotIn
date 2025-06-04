//
//  RecommendView.swift
//  SlotIn
//
//  Created by 김민경 on 6/2/25.
//

import SwiftUI

struct RecommendView: View {
    @State var taskTitle: String
    @State var startTime: Date
    @State var endTime: Date
    @State var startHour: Date
    @State var endHour: Date
    
    var body: some View {
        Text(taskTitle)
        Text(formattedDate(startTime))
        Text(formattedDate(endTime))
        Text(formattedTime(startHour))
        Text(formattedTime(endHour))
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_KR")
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
    
    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_KR")
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    RecommendView(taskTitle: "TestTask1", startTime: Date(), endTime: Date() + 86400, startHour: Date(), endHour: Date() + 3600)
}
