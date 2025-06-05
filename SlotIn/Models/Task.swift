//
//  Task.swift
//  SlotIn
//
//  Created by 윤보라 on 6/3/25.
//  보관함 관련 SwiftData
/*
 1. event 제목
 2. 소요시간
 3. 작업 가능 시작일
 4. 작업 마감일
 5. 하루 중 선호 시간대
 
 */
import Foundation
import SwiftData

@Model
class Task{
    var title: String
    var time: String
    var startDate: Date
    var endDate: Date
    var preferredTime: String
    
    init(title: String, time: String, startDate: Date, endDate: Date, preferredTime: String) {
        self.title = title
        self.time = time
        self.startDate = startDate
        self.endDate = endDate
        self.preferredTime = preferredTime
    }
    
}
