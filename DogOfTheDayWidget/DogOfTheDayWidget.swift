//
//  DogOfTheDayWidget.swift
//  DogOfTheDayWidget
//
//  Created by Frank Aceves on 9/30/20.
//  Copyright © 2020 Frank Aceves. All rights reserved.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct DogOfTheDayWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            //Text(entry.date, style: .time)
                //.foregroundColor(.blue)
            //padding()
            Image("springer-english")
                .resizable()
                .blur(radius: 4.0)
            Image("springer-english")
                .resizable()
                .aspectRatio(contentMode: .fit)
//            Text("This is some text")
//                .foregroundColor(.white)
//                .background(Color.gray)
        }
    }
}

@main
struct DogOfTheDayWidget: Widget {
    let kind: String = "DogOfTheDayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DogOfTheDayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget")
        .supportedFamilies([.systemSmall,.systemMedium])
    }
}

struct DogOfTheDayWidget_Previews: PreviewProvider {
    static var previews: some View {
        DogOfTheDayWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        DogOfTheDayWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
