//
//  TaskListViewModel.swift
//  To-Do-List-App
//
//  Created by Isaiah Ojo on 26/04/2023.
//

import Foundation
import SwiftUI

// ObservableObject
class TaskListViewModel: ObservableObject {
    @Published var tasks = [Task]()
    
    func addTask(_ task: Task) {
        tasks.append(task)
        if task.reminder != nil {
            scheduleNotification(for: task)
        }
    }
    
    func editTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            if tasks[index].reminder != task.reminder {
                cancelNotification(for: tasks[index])
                if task.reminder != nil {
                    scheduleNotification(for: task)
                }
            }
            tasks[index] = task
        }
    }
    
    func deleteTask(at offsets: IndexSet) {
        offsets.forEach { index in
            if tasks[index].reminder != nil {
                cancelNotification(for: tasks[index])
            }
        }
        tasks.remove(atOffsets: offsets)
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permissions: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotification(for task: Task) {
        guard let reminder = task.reminder else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = task.name
        content.sound = UNNotificationSound.default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminder)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: task.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelNotification(for task: Task) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.id.uuidString])
    }
    
    enum TaskSyncError: Error {
        case failedToFetchRecords(Error)
        case failedToSaveRecord(Error)
        case failedToDeleteRecord(Error)
    }
    
    // Calculate the completion rate of tasks
    var completionRate: Double {
        let completedTasks = tasks.filter { $0.isCompleted }.count
        let totalTasks = tasks.count
        
        guard totalTasks > 0 else { return 0.0 }
        return (Double(completedTasks) / Double(totalTasks)) * 100
    }
    
    // Calculate the number of tasks completed on time
    var completedOnTimeCount: Int {
        tasks.filter { $0.isCompleted && $0.dueDate >= ($0.reminder ?? $0.dueDate) }.count
    }
    
    @Published var tags: [Tag] = [
        Tag(name: "Urgent", color: .red),
        Tag(name: "Important", color: .orange),
        Tag(name: "Home", color: .blue),
        Tag(name: "Work", color: .green)
    ]
    
}
