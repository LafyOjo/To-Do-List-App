//
//  To_Do_List_AppApp.swift
//  To-Do-List-App
//
//  Created by Isaiah Ojo on 24/04/2023.
//

import SwiftUI
import UserNotifications

@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var taskListViewModel = TaskListViewModel()

    init() {
        taskListViewModel.requestNotificationPermission()
        //UITabBar.appearance().barTintColor = UIColor(named: "LightBackground")

    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(taskListViewModel)
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }
}
