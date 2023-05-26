//
//  StatisticsView.swift
//  To-Do-List-App
//
//  Created by Isaiah Ojo on 26/04/2023.
//

import Foundation
import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var taskListViewModel: TaskListViewModel
    
    var completedTasks: Int {
        taskListViewModel.tasks.filter { $0.isCompleted }.count
    }
    
    var onTimeTasks: Int {
        taskListViewModel.tasks.filter { $0.isCompleted && $0.dueDate <= Date() }.count
    }
    
    var highPriorityTasks: Int {
        taskListViewModel.tasks.filter { $0.priority == .high }.count
    }
    
    var overdueTasks: Int {
        taskListViewModel.tasks.filter { !$0.isCompleted && $0.dueDate < Date() }.count
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Statistics")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Completed")
                        .font(.headline)
                    Text("\(completedTasks)")
                        .font(.title)
                        .fontWeight(.bold)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    Text("High Priority")
                        .font(.headline)
                    Text("\(highPriorityTasks)")
                        .font(.title)
                        .fontWeight(.bold)
                }
            }
            .padding()
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("On Time")
                        .font(.headline)
                    Text("\(onTimeTasks)")
                        .font(.title)
                        .fontWeight(.bold)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    Text("Overdue")
                        .font(.headline)
                    Text("\(overdueTasks)")
                        .font(.title)
                        .fontWeight(.bold)
                }
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}
