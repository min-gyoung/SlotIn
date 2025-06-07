//
//  ContentView.swift
//  SlotIn
//
//  Created by Bora Yun on 6/2/25.
//
/*
 1. TabView : 작업, 보관함 (완료)
 2. hifi 색상 반영 (완료)
 */
import SwiftUI
import EventKit

struct ContentView: View {
  var body: some View {
    
    TabView{
      Tab("작업", systemImage:"list.bullet"){
        SelectTaskView()
      }
      Tab("캘린더", systemImage: "calendar") {
        SelectedTaskCalendarView(
          currentWeekStartDate: Calendar.current.startOfDay(for: Date()),
          event: EKEvent(eventStore: EKEventStore())
        )
      }
      Tab("보관함", systemImage:"archivebox"){
        TaskView()
      }
    }
    .tint(.green300) //선택된 탭의 색상
    .onAppear{
      UITabBar.appearance().unselectedItemTintColor =  .gray300 //선택 안된 탭의 색상
      UITabBar.appearance().barTintColor = .gray700 //탭바 하단에 뷰가 존재하게 될때의 색상
      UITabBar.appearance().backgroundColor = .gray700 //탭바 하단에 뷰가 존재 하지 않을 때의 색상
    }
  }
}


#Preview {
  ContentView()
}
