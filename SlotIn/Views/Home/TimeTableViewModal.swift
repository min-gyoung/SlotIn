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
  @State private var startDate: Date
  @State private var showConfirmation = false
  
  var recommendedSlot: DateInterval?
  var existingEvent: EKEvent?
  var selectedTask: String
  var startTime: Date
  var endTime: Date
  var duration: TimeInterval  // 초 단위 소요시간 (1시간 30분 = 5400)
  
  init(
    recommendedSlot: DateInterval? = nil,
    existingEvent: EKEvent? = nil,
    selectedTask: String,
    startTime: Date,
    endTime: Date,
    duration: TimeInterval = 5400  // 소요시간 임의 설정
  ) {
    self.recommendedSlot = recommendedSlot
    self.existingEvent = existingEvent
    self.selectedTask = selectedTask
    self.startTime = startTime
    self.endTime = endTime
    self.duration = duration
    _startDate = State(initialValue: startTime)
  }
  
  var calculatedEndDate: Date {
    return startDate.addingTimeInterval(duration)
  }
  
  var body: some View {
    VStack {
      Text("세부 시작 시간 설정")
      // 선택 날짜
      Text("\(formatted(startDate, dateOnly: true))")
      
      // 소요 시간
      Text("소요 시간: \(formatted(duration))")
      
      HStack {
        Text("시작 시간")
        DatePicker(
          "",
          selection: $startDate,
          displayedComponents: [.hourAndMinute]
        )
        .datePickerStyle(.graphical)
                               
        .onAppear {
          UIDatePicker.appearance().minuteInterval = 15
        }
        .onDisappear {
          UIDatePicker.appearance().minuteInterval = 1
        }
      }
      HStack {
        Text("종료 시간")
        Text(formatted(calculatedEndDate, dateOnly: false))
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
  
  private func formatted(_ date: Date, dateOnly: Bool = false) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = dateOnly ? "yyyy.MM.dd (E)" : "HH:mm"
    return formatter.string(from: date)
  }
  
  private func formatted(_ interval: TimeInterval) -> String {
    let minutes = Int(interval / 60)
    return "\(minutes / 60)시간 \(minutes % 60)분"
  }
}

#Preview {
  TimeTableViewModal(
    selectedTask: "서강대학교 홍보 영상 기획 회의",
    startTime: Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date())!,
    endTime: Calendar.current.date(bySettingHour: 11, minute: 0, second: 0, of: Date())!,
    duration: 5400  // 1시간 30분
  )
}
