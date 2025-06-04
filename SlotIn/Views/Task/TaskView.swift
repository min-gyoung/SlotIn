//
//  TaskView.swift
//  SlotIn
//
//  Created by 김민경 on 6/2/25.
//

import SwiftUI

struct TaskView: View {
 
    var body: some View {
        
        NavigationView{
            ZStack{
                
                Color.gray700.ignoresSafeArea()
                
                
                VStack{
                    HStack{
                        Text("보관함")
                            .font(.system(size:28, weight:.semibold))
                            .foregroundColor(.gray100)
                        
                        Spacer()
                    }
                    .padding(.horizontal,16)
                    .padding(.top,55)
                      
                    
                    List{
                        
                        NavigationLink(destination: TaskDetailView()){
                            //eventTitle
                            //text("마감기한: \(endDate)"
                            VStack(alignment:.leading){
                                Text("서강대학교 홍보 영상 기획 회의")
                                    .font(.system(size:17, weight: .semibold))
                                    .padding(.bottom,2)
                                Text("마감 기한: June 5, 2025")
                                    .font(.system(size:16))
                            }
                            .padding(.horizontal,-10)
                            
                            
                        }
                        .padding(.horizontal,28)
                        .frame(width:361, height: 77)
                        .listRowBackground(Color.gray600)
                        .foregroundColor(.gray100)
                        
                    }
                    .scrollContentBackground(.hidden)
                    .background(.clear)
                }
            }
        }
    }
   
}

#Preview {
    TaskView()
}
