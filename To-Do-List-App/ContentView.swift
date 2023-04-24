import SwiftUI
import UserNotifications

enum Priority: String, Identifiable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var id: String { rawValue }
}


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

struct Task: Identifiable {
    let id = UUID()
    var name: String
    var isCompleted: Bool
    var dueDate: Date
    var reminder: Date?
    var category: Category?
    var priority: Priority
    
    var tags: [Tag] = []
}

struct Category: Identifiable, Equatable {
    let id = UUID()
    var name: String
}


struct ContentView: View {
    
    @State private var searchText = ""
    @EnvironmentObject var taskListViewModel: TaskListViewModel
    @AppStorage("username") var username: String = "User"
    
    @State private var newTaskName = ""
    @State private var selectedFilter = 0
    private var filteredTasks: [Task] {
        var tasksToDisplay = taskListViewModel.tasks
        
        switch selectedFilter {
        case 0:
            // tasksToDisplay is already set to the original tasks array
            break
        case 1:
            tasksToDisplay = tasksToDisplay.filter { !$0.isCompleted }
        case 2:
            tasksToDisplay = tasksToDisplay.filter { $0.isCompleted }
        case 3:
            tasksToDisplay = tasksToDisplay.filter { $0.priority == .high }
        default:
            // tasksToDisplay is already set to the original tasks array
            break
        }
        
        if !searchText.isEmpty {
            tasksToDisplay = tasksToDisplay.filter { task in
                task.tags.contains { tag in
                    tag.name.lowercased().contains(searchText.lowercased())
                }
            }
        }
        
        return tasksToDisplay
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                    .padding(.top)
                List {
                    ForEach(filteredTasks.filter { task in
                        if searchText.isEmpty {
                            return true
                        } else {
                            return task.tags.contains { tag in
                                tag.name.localizedCaseInsensitiveContains(searchText)
                            }
                        }
                    }, id: \.id) { task in
                        if let index = taskListViewModel.tasks.firstIndex(where: { $0.id == task.id }) {
                            NavigationLink(destination: TaskDetailsView(task: $taskListViewModel.tasks[index])) {
                                TaskView(task: $taskListViewModel.tasks[index])
                            }
                        }
                    }
                    .onDelete(perform: taskListViewModel.deleteTask)
                }
                TextField("New Task", text: $newTaskName, onCommit: {
                    if !newTaskName.isEmpty {
                        taskListViewModel.addTask(Task(name: newTaskName, isCompleted: false, dueDate: Date.now, reminder: nil, category: nil, priority: .medium))
                        newTaskName = ""
                    }
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                
                Picker("", selection: $selectedFilter) {
                    Text("All").tag(0)
                    Text("Active").tag(1)
                    Text("Completed").tag(2)
                    Text("High Priority").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
            }
            .navigationTitle("Tasks (\(username))")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: StatisticsView().environmentObject(taskListViewModel)) {
                        Image(systemName: "chart.bar")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        .onAppear {
            taskListViewModel.requestNotificationPermission()
        }
    }
}

struct TaskView: View {
    @Binding var task: Task
    
    var body: some View {
        HStack {
            TextField("Task Name", text: $task.name)
            
            Spacer()
            
            Text(task.priority.rawValue)
                .foregroundColor(.orange)
                .font(.footnote)
            
            if let reminder = task.reminder {
                Text("\(reminder, formatter: dateTimeFormatter)")
                    .foregroundColor(.red)
                    .font(.footnote)
            }
            
            if let category = task.category {
                Text("\(category.name)")
                    .foregroundColor(.blue)
                    .font(.footnote)
            }
            Toggle("", isOn: $task.isCompleted)
        }
        .background(Color("TaskBackgroundColor"))
    }
}



struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("username") var username: String = "User"
    @AppStorage("theme") var theme: String = "light"
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true
    @AppStorage("fontSize") var fontSize: Int = 16
    
    @State private var newUsername = ""
    @State private var selectedThemeIndex = 0
    
    let themes = ["Light", "Dark"]
    let fontSizes = 14...22
    
    var body: some View {
        VStack {
            TextField("New Username", text: $newUsername)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Picker(selection: $selectedThemeIndex, label: Text("Theme")) {
                ForEach(themes.indices) { index in
                    Text(themes[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Toggle("Notifications", isOn: $notificationsEnabled)
                .padding()
            
            Stepper(value: $fontSize, in: fontSizes) {
                Text("Font Size: \(fontSize)")
            }
            .padding()
            
            Button(action: {
                if !newUsername.isEmpty {
                    username = newUsername
                }
                
                if selectedThemeIndex == 0 {
                    theme = "light"
                } else {
                    theme = "dark"
                }
                
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .navigationTitle("Settings")
    }
}

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
            Text("Completed Tasks: \(completedTasks)")
                .font(.title)
                .padding()
            
            Text("Tasks Completed On Time: \(onTimeTasks)")
                .font(.title)
                .padding()
            
            Text("High Priority Tasks: \(highPriorityTasks)")
                .font(.title)
                .padding()
            
            Text("Overdue Tasks: \(overdueTasks)")
                .font(.title)
                .padding()
            
            // Add more statistics here as needed
            
            Spacer()
        }
        .padding()
        .navigationTitle("Statistics")
    }
}

struct TaskDetailsView: View {
    @Binding var task: Task
    
    @State private var showingTagSelection = false
    @State private var showingCategorySelection = false
    
    private var selectedTagsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(task.tags) { tag in
                    Text(tag.name)
                        .padding(4)
                        .background(tag.color.opacity(0.2))
                        .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(tag.color, lineWidth: 1)
                        )
                }
                Button(action: {
                    showingTagSelection = true
                }) {
                    Image(systemName: "tag")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.2))
                        .cornerRadius(4)
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            TextField("Task Name", text: $task.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .font(.largeTitle)
            
            Toggle(isOn: $task.isCompleted){
                Text("Completed")
                    .font(.title)
            }
            .padding()
            
            DatePicker("Due Date", selection: $task.dueDate, displayedComponents: [.date])
                .padding()
                .datePickerStyle(CompactDatePickerStyle())
            
            DatePicker("Reminder", selection: Binding<Date>(
                get: { task.reminder ?? Date() },
                set: { newValue in task.reminder = newValue }),
                       displayedComponents: [.date, .hourAndMinute])
            .padding()
            .datePickerStyle(CompactDatePickerStyle())
            
            Button(action: {
                showingCategorySelection = true
            }) {
                HStack {
                    Text("Category")
                    Spacer()
                    if let category = task.category {
                        Text(category.name)
                    }
                }
            }
            .sheet(isPresented: $showingCategorySelection) {
                CategorySelectionView(selectedCategory: $task.category)
            }
            .padding()
            
            Spacer()
        }
        Picker("Priority", selection: $task.priority) {
            ForEach(Priority.allCases) { priority in
                Text(priority.rawValue).tag(priority)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .padding()
        
        .navigationTitle("Task Details")
        
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    showingTagSelection = true
                }) {
                    Text("Edit Tags")
                }
            }
        }
        .sheet(isPresented: $showingTagSelection) {
            TagSelectionView(selectedTags: $task.tags)
        }
        .padding()
        
        selectedTagsView
            .padding(.horizontal)
    }
}
struct CategorySelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var selectedCategory: Category?
    
    let categories: [Category] = [
        Category(name: "Personal"),
        Category(name: "Work"),
        Category(name: "Family"),
        Category(name: "Shopping")
    ]
    
    var body: some View {
        NavigationView {
            List(categories) { category in
                Button(action: {
                    selectedCategory = category
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Text(category.name)
                        Spacer()
                        if category == selectedCategory {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Categories")
        }
    }
}

struct Tag: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var color: Color
}

struct TagSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var taskListViewModel: TaskListViewModel
    
    @Binding var selectedTags: [Tag]
    
    @State private var newTagName = ""
    @State private var newTagColor = Color.red
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Create New Tag")) {
                        HStack {
                            TextField("Tag Name", text: $newTagName)
                            
                            Spacer()
                            
                            ColorPicker("Tag Color", selection: $newTagColor)
                                .labelsHidden()
                        }
                        Button(action: {
                            if !newTagName.isEmpty {
                                let newTag = Tag(name: newTagName, color: newTagColor)
                                taskListViewModel.tags.append(newTag)
                                newTagName = ""
                                newTagColor = .red
                            }
                        }) {
                            Text("Add Tag")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    
                    Section(header: Text("Available Tags")) {
                        ForEach(taskListViewModel.tags) { tag in
                            Button(action: {
                                if let index = selectedTags.firstIndex(of: tag) {
                                    selectedTags.remove(at: index)
                                } else {
                                    selectedTags.append(tag)
                                }
                            }) {
                                HStack {
                                    Text(tag.name)
                                    Spacer()
                                    Circle()
                                        .fill(selectedTags.contains(tag) ? Color.clear : tag.color)
                                        .frame(width: 16, height: 16)
                                    if selectedTags.contains(tag) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .navigationTitle("Tags")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if isEditing {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .onTapGesture {
                    self.isEditing = true
                }
            
            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
    }
}
