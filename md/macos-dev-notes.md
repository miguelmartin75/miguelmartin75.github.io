---
title: MacOS Dev Notes
---

MVC

-   Model
-   View (NSView)
    -   NSView inherits from NSResponder
    -   NSResponder handles events
-   Controller (NSViewController)

# xi editor

<https://github.com/xi-editor/xi-mac>

EditView, inherits from:

-   NSView
-   [NSTextInputClient](https://developer.apple.com/documentation/appkit/nstextinputclient?language=objc)

# NSViewController

Controls many views

# EventKit

<https://developer.apple.com/documentation/eventkit/ekevent?language=objc>

``` swift
import EventKit

var store = EKEventStore()
store.requestAccess(to: .reminder) { granted, error in
    // Handle the response to the request.
    print("got access")
}

// Get the appropriate calendar.
var calendar = Calendar.current;

// Create the start date components
var oneDayAgoComponents = DateComponents()
oneDayAgoComponents.day = -1
var oneDayAgo = calendar.date(byAdding: oneDayAgoComponents, to: Date(), wrappingComponents: false)

var oneYearFromNowComponents = DateComponents()
oneYearFromNowComponents.day = 1
var oneYearFromNow = calendar.date(byAdding: oneYearFromNowComponents, to: Date(), wrappingComponents: false)

// Create the predicate from the event store's instance method.
var predicate: NSPredicate? = nil
if let anAgo = oneDayAgo, let aNow = oneYearFromNow {
    predicate = store.predicateForEvents(withStart: anAgo, end: aNow, calendars: nil)
}


// Fetch all events that match the predicate.
var events: [EKEvent]? = nil
if let aPredicate = predicate {
    events = store.events(matching: aPredicate)
}
print("events=")
for e in events! {
    print(e.title!, e.attendees)
}
```
