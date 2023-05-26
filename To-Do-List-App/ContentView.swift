import SwiftUI
import UserNotifications
import ColorSync

enum Priority: String, Identifiable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var id: String { rawValue }
}

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
    let systemName: String
    let color: Color
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
            .navigationBarTitle("Tasks (\(username))", displayMode: .inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    NavigationLink(destination: StatisticsView().environmentObject(taskListViewModel)) {
                        Image(systemName: "chart.bar")
                    }
                    
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
            }
            .navigationBarColor(backgroundColor: UIColor(Color("PrimaryColor")), tintColor: Color.white)
        }
        .onAppear {
            taskListViewModel.requestNotificationPermission()
        }
    }
}

extension View {
    func navigationBarColor(backgroundColor: UIColor, tintColor: Color) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor, tintColor: tintColor))
    }
}

struct NavigationBarModifier: ViewModifier {
    
    init(backgroundColor: UIColor, tintColor: Color) {
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = backgroundColor
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        
        UINavigationBar.appearance().tintColor = UIColor(tintColor)
    }
    
    func body(content: Content) -> some View {
        content
    }
}

struct Tag: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var color: Color
}

