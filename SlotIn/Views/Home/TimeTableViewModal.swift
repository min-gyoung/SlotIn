//
//  TimeTableViewModal.swift
//  SlotIn
//
//  Created by 김민경 on 6/4/25.
//

import SwiftUI
import EventKit

struct TimeTableViewModal: View {
  @Environment(\.presentationMode) var presentation
  @Environment(\.openURL) private var openURL
  @Environment(\.dismiss) private var dismiss
  @State private var date = Date()
  @State private var showConfirmation = false
  
  var recommendedSlot: DateInterval?
  var existingEvent: EKEvent?
  var selectedTask: String
  var startTime: Date
  var endTime: Date
  
  var body: some View {
    
    VStack {
      Text("세부 시작 시간 설정")
      Text("선택 날짜")
      Text("선택 시간 (소요 시간)")
      HStack {
        Text("시작 시간")
        DatePicker(
          "",
          selection: $date,
          displayedComponents: [.hourAndMinute]
        )
      }
      HStack {
        Text("종료 시간")
        DatePicker(
          "",
          selection: $date,
          displayedComponents: [.hourAndMinute]
        )
      }
      Button("이 시간으로 확정하기") {
        showConfirmation = true
      }
      // 애플캘린더에서 보기
      .alert("캘린더에 반영되었습니다.", isPresented: $showConfirmation) {
        Button("캘린더 열기") {
          // 애플 캘린더 앱 열기
          if let url = URL(string: "calshow://") {
            openURL(url)
          }
        }
        Button("작업 선택으로 돌아가기", role: .cancel) {
          dismiss()
        }
      } message: {
        if let slot = recommendedSlot {
          Text("확정된 일정: \(formatted(slot.start)) ~ \(formatted(slot.end))")
        } else {
          Text("추천 일정 정보가 없습니다.")
        }
      }
    }
  }
  
  private func formatted(_ date: Date?) -> String {
    guard let date = date else { return "--:--" }
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd HH:mm"
    return formatter.string(from: date)
  }
}

#Preview {
  TimeTableViewModal(
    selectedTask: "서강대학교 홍보 영상 기획 회의",
    startTime: Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date())!,
    endTime: Calendar.current.date(bySettingHour: 11, minute: 15, second: 0, of: Date())!
  )
}
