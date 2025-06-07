//
//  TaskView.swift
//  SlotIn
//
//  Created by 김민경 on 6/2/25.
//

import SwiftUI
import SwiftData

struct TaskView: View {
  
  @Query(sort: \Task.startDate, order: .reverse) var tasks: [Task]
  @Environment(\.modelContext) private var context
  
  var body: some View {
    NavigationView {
      ZStack {
        Color.gray700.ignoresSafeArea()
        
        VStack {
          HStack {
            Text("보관함")
              .font(.system(size: 28, weight: .semibold))
              .foregroundColor(Color.gray100)
            Spacer()
          }
          .padding(.horizontal, 16)
          .padding(.top, 55)
          
          List {
            ForEach(tasks) { task in
              NavigationLink(destination: TaskDetailView(task: task)) {
                VStack(alignment: .leading) {
                  Text(task.title)
                    .font(.system(size: 17, weight: .semibold))
                    .padding(.bottom, 2)
                  Text("마감기한: \(task.endDate.formatted(date: .long, time: .omitted))")
                    .font(.system(size: 16))
                }
                .padding(.horizontal, -10)
              }
            }
            .onDelete { indexSet in
              for index in indexSet {
                let task = tasks[index]
                context.delete(task)
              }
            }
            .listRowBackground(Color.gray600)
            .foregroundColor(Color.gray100)
          }
          .scrollContentBackground(.hidden)
          .background(Color.clear)
        }
        .padding(.horizontal, 16)
      }
    }
  }
}

#Preview {
  TaskView()
}
