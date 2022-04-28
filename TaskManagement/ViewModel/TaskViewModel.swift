//
//  TaskViewModel.swift
//  TaskManagement
//
//  Created by Vipin Saini on 27/04/22.
//
 
import SwiftUI

class TaskViewModel: ObservableObject {
  
    //current week day
    @Published var currentWeek: [Date] = []
    //current day
    @Published var currentDay: Date = Date()
    // Filtering today tasks
    @Published var filteredTasks: [Task]?
    
    // New task View
    @Published var addNewTask: Bool = false
    // Edit task
    @Published var editTask: Task?
    
    
    //MARK: - Init
    init() {
        fetchCurrentWeek()
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
        
        let currentHour = calendar.component(.hour, from: Date())
        let isToday = calendar.isDateInToday(date)
        
        return (hour == currentHour && isToday) 
    }
 }
