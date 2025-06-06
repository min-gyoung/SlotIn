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
    
    var body: some View {
        
        NavigationView{
            GeometryReader { geometry in
                ZStack{
                    
                    List{
                        ForEach(tasks){ task in
                            NavigationLink(destination: TaskDetailView(task: task)){
                                VStack(alignment:.leading){
                                    Text(task.title)
                                        .font(.system(size:17, weight: .semibold))
                                        .padding(.bottom,2)
                                    Text("마감기한: \(task.endDate.formatted(date:.long, time: .omitted))")
                                        .font(.system(size:16))
                                    
                                }
                                .padding(.horizontal,-10)
                            }
                            
                        }
                        .scrollContentBackground(.hidden)
                        .background(.clear)
                    }
                }
            }
        }
    }
   
}

#Preview {
    TaskView()
}
