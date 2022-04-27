//
//  TaskViewModel.swift
//  TaskManagement
//
//  Created by Vipin Saini on 27/04/22.
//

import Foundation
import SwiftUI

class TaskViewModel: ObservableObject {
    
    //Sample tasks
    @Published var storedTasks: [Task] = [
        Task(taskTitle: "Meeting", taskDescription: "Discuss team task for the day", taskDate: .init(timeIntervalSince1970: 1651084200)),
        Task(taskTitle: "Icon set", taskDescription: "Edit icons for team task for next week", taskDate: .init(timeIntervalSince1970: 1650912522)),
        Task(taskTitle: "Prototype", taskDescription: "Make and send prototype", taskDate: .init(timeIntervalSince1970: 1650926922)),
        Task(taskTitle: "Check asset", taskDescription: "Start checking the assets", taskDate: .init(timeIntervalSince1970: 1650865722)),
        Task(taskTitle: "Team party", taskDescription: "Make fun with team mates", taskDate: .init(timeIntervalSince1970: 1650966522)),
        Task(taskTitle: "Client Meeting", taskDescription: "Explain project to clinet", taskDate: .init(timeIntervalSince1970: 1651086042)),
        Task(taskTitle: "Next Project", taskDescription: "Discuss next project with team", taskDate: .init(timeIntervalSince1970: 1651089642)),
        Task(taskTitle: "App Proposal", taskDescription: "Meet client for next App Proposal", taskDate: .init(timeIntervalSince1970: 1651196922)),
    ]
    
    //current week day
    @Published var currentWeek: [Date] = []
    //current day
    @Published var currentDay: Date = Date()
    // Filtering today tasks
    @Published var filteredTasks: [Task]?
    
    
    //MARK: - Init
    init() {
        fetchCurrentWeek()
        filterTodayTasks()
    }
    
    //Fetch week
    func fetchCurrentWeek() {
        let today = Date()
        let calendar = Calendar.current
        let week = calendar.dateInterval(of: .weekOfMonth, for: today)
        
        guard let firstWeekDay = week?.start else { return }
        
        (1...7).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: firstWeekDay) {
                currentWeek.append(weekday)
            }
        }
    }
    
    //Filter Today Tasks
    func filterTodayTasks() {
        DispatchQueue.global(qos: .userInteractive).async {
            let calendar = Calendar.current
            let filtered = self.storedTasks.filter {
                return calendar.isDate($0.taskDate, inSameDayAs: self.currentDay)
            }
                .sorted { task1, task2 in
                    return task2.taskDate > task1.taskDate
                }
            
            DispatchQueue.main.async {
                withAnimation {
                    self.filteredTasks = filtered
                }
            }
        }
    }
    
    //Extracting Date
    func extractDate(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    //check today date
    func isToday(date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(currentDay, inSameDayAs: date)
    }
    
    //check current time is task time
    func isCurrentDateTime(date: Date) -> Bool {
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let todayDate = Date()
        let currentHour = calendar.component(.hour, from: todayDate)
        if hour == currentHour && calendar.isDate(todayDate, inSameDayAs: date) {
            return true
        }
        return false 
    }
 }
