//
//  Task.swift
//  TaskManagement
//
//  Created by Vipin Saini on 27/04/22.
//

import Foundation

struct Task: Identifiable {
    var id = UUID().uuidString
    var taskTitle: String
    var taskDescription: String
    var taskDate: Date
}
