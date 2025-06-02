//
//  TimeTableView.swift
//  SlotIn
//
//  Created by 김민경 on 6/2/25.
//

import SwiftUI

struct TimeTableView: View {
  let selectedTask: String
  let startTime: Date
  let endTime: Date
  let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
  
  // 상위 뷰에서 주입받는 Date 기준으로 주간 날짜 계산
  var weekDates: [Date] {
    TimeTableModel.currentWeekDates(reference: startTime)
  }
  
  var body: some View {
    VStack {
      Text("시간 선택")
        .font(.title)
      
      Text(selectedTask)
      
      Text(TimeTableModel.durationText(start: startTime, end: endTime))
        .font(.subheadline)
        .foregroundColor(.gray)
      
      HStack {
        Button(action: {
          // 이전 주차 이동 처리 예정
        }) {
          Image(systemName: "chevron.left")
        }
        
        Spacer()
        Text(TimeTableModel.weekInfoText(from: startTime))
        Spacer()
        
        Button(action: {
          // 다음 주차 이동 처리 예정
        }) {
          Image(systemName: "chevron.right")
        }
      }
      
      HStack {
        ForEach(weekdays, id: \.self) { day in
          Text(day)
            .frame(maxWidth: .infinity)
        }
      }
      
      Divider()
      
      HStack {
        ForEach(weekDates, id: \.self) { date in
          Text("\(Calendar.current.component(.day, from: date))")
            .frame(maxWidth: .infinity)
        }
      }
      
      ScrollView {
        VStack(alignment: .leading) {
          ForEach(0..<24, id: \.self) { hour in
            Text(String(format: "%02d", hour))
              .padding(.vertical, 17)
          }
        }
      }
    }
    .padding()
  }
}

#Preview {
  TimeTableView(
    selectedTask: "서강대학교 홍보 영상 기획 회의",
    startTime: Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date())!,
    endTime: Calendar.current.date(bySettingHour: 11, minute: 15, second: 0, of: Date())!
  )
}
