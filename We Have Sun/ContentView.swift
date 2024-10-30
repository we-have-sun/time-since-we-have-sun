//
//  ContentView.swift
//  We Have Sun
//
//  Created by Natalia Terlecka on 18/10/2024.
//

import SwiftUI
import Combine

enum Title: String, Identifiable {
    var id: String { self.rawValue }

    case FirstMeeting = "🫂 First met"
    case DublinTrip = "🍻 Dublin trip"
    case BeatsMedicalStart = "🔵 BM project started"
    case WHSCreate = "📜 We Have Sun started"
    case PomodoroProject = "🍅 Pomodoro Project"
    case TimeToGoFirstMilestone = "🦾 Next milestone in"
}

struct ContentView: View {
    @State private var timeSinceFirstMeeting: TimeInterval = 0
    @State private var monthsAndYearsSinceFirstMeeting: String = ""
    @State private var timeSinceDublinTrip: TimeInterval = 0
    @State private var timeSinceBeatsMedicalStart: TimeInterval = 0
    @State private var timeSinceWHSCreate: TimeInterval = 0
    @State private var monthsAndYearsSinceWHSCreate: String = ""
    @State private var timeSincePomodoroProject: TimeInterval = 0
    @State private var timeToGoFirstMilestone: TimeInterval = 0

    private let startOfFirsMeetingString = "2014-07-23 10:00"
    private let startOfDublinTripDateString = "2015-11-02 00:00"
    private let startOfBeatsMedicalStartDateString = "2016-02-01 00:00"
    private let startOfWHSCreateDateString = "2016-12-06 18:00"
    private let startOfPomodoroProjectString = "2024-02-07 15:30"
    private let startOfFirstMilestoneDateString = "2024-10-01 00:00"
    
    @State private var weekTimer = Timer.publish(every: 0.001, on: .main, in: .common)  // Timer to update elapsed times
    @State private var weekCancellable: Cancellable?  // Cancellable for the timer

    var titles = [Title.FirstMeeting, Title.DublinTrip, Title.BeatsMedicalStart, Title.WHSCreate, Title.PomodoroProject, Title.TimeToGoFirstMilestone]
    var textColor = Color(red: 0.27, green: 0.26, blue: 0.25, opacity: 1.00)
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 1.00, green: 0.98, blue: 0.82, opacity: 1.00)
                    .ignoresSafeArea()  // This makes the background color stretch everywhere
                VStack(spacing: 30) { // Increased spacing between sections
                    // Display time since being togather
                    VStack(spacing: 15) {
                        Text(Title.FirstMeeting.rawValue)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(textColor)
                        VStack(spacing: 5) {
                            Text(monthsAndYearsSinceFirstMeeting)
                                .font(.system(size: 20, weight: .medium, design: .monospaced))
                                .foregroundColor(textColor)
                            Text(timeStringWithDays(from: timeSinceFirstMeeting))
                                .font(.system(size: 20, weight: .medium, design: .monospaced))
                                .foregroundColor(textColor)
                        }
                    }
                    
                    VStack(spacing: 15) {
                        Text(Title.DublinTrip.rawValue)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(textColor)
                        Text(timeStringWithDays(from: timeSinceDublinTrip))
                            .font(.system(size: 20, weight: .medium, design: .monospaced))
                            .foregroundColor(textColor)
                    }

                    // Display time since the first video
                    VStack(spacing: 15) {
                        Text(Title.BeatsMedicalStart.rawValue)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(textColor)
                        Text(timeStringWithDays(from: timeSinceBeatsMedicalStart))
                            .font(.system(size: 20, weight: .medium, design: .monospaced))
                            .foregroundColor(textColor)
                    }

                    VStack(spacing: 15) {
                        Text(Title.WHSCreate.rawValue)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(textColor)
                        VStack(spacing: 5) {
                            Text(monthsAndYearsSinceWHSCreate)
                                .font(.system(size: 20, weight: .medium, design: .monospaced))
                                .foregroundColor(textColor)
                            Text(timeStringWithDays(from: timeSinceWHSCreate))
                                .font(.system(size: 20, weight: .medium, design: .monospaced))
                                .foregroundColor(textColor)
                        }
                    }

                    // Display time since start of the week
                    VStack(spacing: 15) {
                        Text(Title.PomodoroProject.rawValue)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(textColor)
                        Text(timeStringWithDays(from: timeSincePomodoroProject))
                            .font(.system(size: 20, weight: .medium, design: .monospaced))
                            .foregroundColor(textColor)
                    }

                    // Display time since start of the year
                    VStack(spacing: 15) {
                        Text(Title.TimeToGoFirstMilestone.rawValue)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(textColor)
                        Text(timeStringWithDays(from: timeToGoFirstMilestone))
                            .font(.system(size: 20, weight: .medium, design: .monospaced))
                            .foregroundColor(textColor)
                    }
                }
            }
            .onReceive(weekTimer) { _ in
                // Update times and handle week change
                let firstMet = calculateTimeAndMonthSinceFirstMet()
                timeSinceFirstMeeting = firstMet.0
                monthsAndYearsSinceFirstMeeting = firstMet.1
                
                timeSinceDublinTrip = calculateTimeSinceDublinTrip()
                timeSinceBeatsMedicalStart = calculateTimeSinceBeatsMedicalStart()
                
                let whsCreate = calculateTimeAndMonthSinceWHSCreate()
                timeSinceWHSCreate = whsCreate.0
                monthsAndYearsSinceWHSCreate = whsCreate.1

                timeSincePomodoroProject = calculateTimeSincePomodoroProjectStart()
                timeToGoFirstMilestone = calculateTimeToGoFirstMilestone()
            }
        }
        .onAppear {
            // Start the timer
            weekTimer = Timer.publish(every: 0.01, on: .main, in: .common)
            weekCancellable = weekTimer.connect()
        }
    }
    
    func monthsSince(date: Date) -> Int? {
        let calendar = Calendar.current
        let now = Date()

        // Calculate the number of months between the given date and the current date
        let components = calendar.dateComponents([.month], from: date, to: now)
        return components.month
    }

    private func calculateTimeAndMonthSinceFirstMet() -> (TimeInterval, String) {
        let now = Date()
        let startOfFirstMet = convertStringToDate(dateString: startOfFirsMeetingString) ?? Date()
        let monthsAndYears = calculateYearsAndMonths(from: startOfFirstMet)
        return (now.timeIntervalSince(startOfFirstMet), monthsAndYears)
    }
    
    private func calculateTimeSinceDublinTrip() -> TimeInterval {
        let now = Date()
        let startOfLiveTogather = convertStringToDate(dateString: startOfDublinTripDateString) ?? Date()
        return now.timeIntervalSince(startOfLiveTogather)
    }

    private func calculateTimeSinceBeatsMedicalStart() -> TimeInterval {
        let now = Date()
        let startOfLiveTogather = convertStringToDate(dateString: startOfBeatsMedicalStartDateString) ?? Date()
        return now.timeIntervalSince(startOfLiveTogather)
    }
    
    private func calculateTimeAndMonthSinceWHSCreate() -> (TimeInterval, String) {
        let now = Date()
        let startOfWHSCreate = convertStringToDate(dateString: startOfWHSCreateDateString) ?? Date()
        let monthsAndYears = calculateYearsAndMonths(from: startOfWHSCreate)
        return (now.timeIntervalSince(startOfWHSCreate), monthsAndYears)
    }
    
    private func calculateTimeSincePomodoroProjectStart() -> TimeInterval {
        let now = Date()
        let startOfLiveTogather = convertStringToDate(dateString: startOfPomodoroProjectString) ?? Date()
        return now.timeIntervalSince(startOfLiveTogather)
    }

    private func calculateTimeToGoFirstMilestone() -> TimeInterval {
        let now = Date()
        let startOfFirstMilestone = convertStringToDate(dateString: startOfFirstMilestoneDateString) ?? Date()
        let startOfFirstMilestonePlus6 = getDate6MonthsFrom(date: startOfFirstMilestone) ?? Date()
        return -now.timeIntervalSince(startOfFirstMilestonePlus6)
    }

    // Function to convert time interval to a formatted string
    private func timeString(from interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        let seconds = Int(interval) % 60
        let milliseconds = Int((interval - floor(interval)) * 1000)

        return String(format: "%02i:%02i:%02i:%03i", hours, minutes, seconds, milliseconds)
    }
    
    // Function to convert time interval to a formatted string with days
    private func timeStringWithDays(from interval: TimeInterval) -> String {
        let days = Int(interval) / (3600 * 24)
        let hours = (Int(interval) % (3600 * 24)) / 3600
        let minutes = (Int(interval) / 60) % 60
        let seconds = Int(interval) % 60
        let milliseconds = Int((interval - floor(interval)) * 1000)

        return String(format: "%02i days %02i:%02i:%02i:%03i", days, hours, minutes, seconds, milliseconds)
    }
    
    func getDate6MonthsFrom(date: Date) -> Date? {
        var dateComponent = DateComponents()
        dateComponent.month = 6  // Add 6 months
        
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: date)
        return futureDate
    }
    
    func getDate30YearsFrom(date: Date) -> Date? {
        var dateComponent = DateComponents()
        dateComponent.year = 30  // Add 30 years
        
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: date)
        return futureDate
    }
    
    func convertStringToDate(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"  // Set the format to match the string
        dateFormatter.timeZone = TimeZone.current      // Optionally set a timezone
        return dateFormatter.date(from: dateString)    // Convert string to Date
    }
    
    func calculateYearsAndMonths(from date: Date) -> String {
        let currentDate = Date()
        let calendar = Calendar.current

        let components = calendar.dateComponents([.year, .month], from: date, to: currentDate)
        
        if let years = components.year, let months = components.month {
            // Singular/plural logic
            let yearString = years == 1 ? "\(years) year" : "\(years) years"
            let monthString = months == 1 ? "\(months) month" : "\(months) months"
            
            // Handle cases where there are 0 years or 0 months
            if years == 0 {
                return "\(monthString)"
            } else if months == 0 {
                return "\(yearString)"
            } else {
                return "\(yearString) and \(monthString)"
            }
        } else {
            return "Invalid date"
        }
    }
}

#Preview {
    ContentView()
}
