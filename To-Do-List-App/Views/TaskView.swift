//
//  TaskView.swift
//  To-Do-List-App
//
//  Created by Isaiah Ojo on 26/04/2023.
//

import Foundation
import SwiftUI
import UserNotifications

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .none
    return formatter
}()

private let dateTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

struct Checkbox: View {
    @Binding var isChecked: Bool
    var size: CGFloat
    
    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: size / 4)
                    .stroke(isChecked ? Color("PrimaryColor") : Color.gray, lineWidth: 2)
                    .frame(width: size, height: size)
                
                if isChecked {
                    Image(systemName: "checkmark")
                        .font(.system(size: size / 2, weight: .semibold))
                        .foregroundColor(.green) // Change the color to green
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TaskView: View {
    @Binding var task: Task
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    TextField("Task Name", text: $task.name)
                    
                    Spacer()
                    
                    Text(task.priority.rawValue)
                        .foregroundColor(.orange)
                        .font(.system(size: 14, weight: .semibold))
                }
                
                if let category = task.category {
                    HStack(spacing: 4) {
                        Image(systemName: category.systemName)
                            .foregroundColor(category.color)
                            .font(.system(size: 14, weight: .bold))
                        Text("\(category.name)")
                            .foregroundColor(category.color)
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
                
                HStack(spacing: 4) {
                    if let reminder = task.reminder {
                        Image(systemName: "alarm")
                            .foregroundColor(.red)
                            .font(.system(size: 14, weight: .bold))
                        Text("\(reminder, formatter: dateTimeFormatter)")
                            .foregroundColor(.red)
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
            }
            
            Spacer()
            
            Checkbox(isChecked: $task.isCompleted, size: 30)
                .padding(.leading, 8)
        }
        .padding(8)
        .background(Color("TaskBackgroundColor"))
        .cornerRadius(8)
    }
}
