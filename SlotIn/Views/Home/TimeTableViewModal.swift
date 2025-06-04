//
//  TimeTableViewModal.swift
//  SlotIn
//
//  Created by 김민경 on 6/4/25.
//

import SwiftUI

struct TimeTableViewModal: View {
  @Environment(\.presentationMode) var presentation
  @State private var date = Date()

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
        presentation.wrappedValue.dismiss()
        
      }
    }
  }
}

#Preview {
  TimeTableViewModal(
    selectedTask: "서강대학교 홍보 영상 기획 회의",
    startTime: Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date())!,
    endTime: Calendar.current.date(bySettingHour: 11, minute: 15, second: 0, of: Date())!
  )
}
