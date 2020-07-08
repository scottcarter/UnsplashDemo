# About

I created this project to experiment with [Unsplash](https://unsplash.com/).  They [offer an API](https://unsplash.com/developers) that is free to use for developers.    

As the project evolved I decided that it could serve as a nice example of many iOS  features and patterns.

# Installation

The project requires SwiftLint which is installed as a Pod.

> pod install

You will also need to obtain an API key for Unsplash.  The key should be inserted in Constants.swift where the placeholder reads "Enter Unsplash API Key here".

# Project feature examples

## Table View Controller implementation
- Loading view with UIActivityIndicatorView
- Dark mode customization (loading view)
- Use of Scene Dock view (loading view)
- Refresh control implementation
- Manual constraint specification and response to viewSafeAreaInsetsDidChange()
- Triggered API fetches as user scrolls table

## Other feature examples
- MVVM
- Combine (used with Bookmarks)
- Core Data, including NSFetchedResultsController
- Collection View Controller
- Use of helper UIWindow for easy placement of alert views (FetchingView)
- Use of XIB file to load subview for a UIViewController
- SwiftLint (via CocoaPods)
- Alamofire (via Swift Package)
- Unsplash API
- Issue generation for issue navigator
- Use of Swift "Result" generic enumeration, including mapError method to transform to custom Error struct.

# Details

## NSFetchedResultsController

I use a pair of instances of NSFetchedResultsController.   

One is used in BookmarksModel.swift and is used to monitor for changes that will affect our Bookmarks table view.

The other is used in ImageModel and is used to monitor for addition/deletion of any bookmark associated with the currently displayed image.  This is used to control the enable for the add bookmark button in the navigation bar.

## Table Layout

An issue can arise with table layout that needs to be handled.  Apparently when a UITableView first loads and is being laid out, it can set the height of its cells to 0. 

This can cause a warning "Unable to simultaneously satisfy constraints." where part of the message includes something along the lines of:
UITableViewCellContentView:0x102c1ed40.height == 0 

The warning did not occur consistently, but I could trigger it by deleting all bookmarks, adding a couple, and then returning to the Bookmarks table view.

A solution that is typically found is to lower the priority on one of the constraints.   In the case of the BookmarksTableViewController, I lowered the priority for the image view top constraint.

Reference: https://stackoverflow.com/a/30333810/1949877


## Bookmarks Table View Controller

There were a couple items that required special attention to detail.

**Changes to Table View**
Changes while this Table View was not visible (not in the view hierarchy) needed to be guarded against.  This was done by examining the tableView.window property.

**Edit mode**
Depending on whether the bookmarks list was empty or not determined whether we were in edit mode and if the edit button was disabled.   
- If the last bookmark was deleted while in edit mode, we turn off edit mode and disable the button.
- If a bookmark is subsequently added, we enable the button.


## Scene Dock Views

The Scene Dock provides a convenient place to store lightweight views.  I used one for the initial loading view for the Recents table view controller.

Note: The Safe Area Layout Guide can be unchecked for the scene dock view (Size Inspector).

A few references:
- http://blog.curtisherbert.com/secondary-views/
- https://medium.com/if-let-swift-programming/interface-builder-scene-dock-extra-views-26cef5fe363b
- https://www.raywenderlich.com/4518-demystifying-views-in-ios/lessons/13  (you need a subscription to view this video)

 


## SwiftLint

SwiftLint is a great tool for ensuring some consistent use of best practices in your project.

https://github.com/realm/SwiftLint

**Installation**
I installed SwiftLint via CocoaPods

Add a build phase run script containing
${PODS_ROOT}/SwiftLint/swiftlint

**Editing**
In order to assist in trimming whitespaces from empty lines, check the two boxes:
Xcode->Preferences->Text Editing->Editing
- Automatically trim trailing whitespace
- Including whitespace-only lines

**Style Guides**
For help in getting past lint issues, you might refer to the following style guides:

- https://swift.org/documentation/api-design-guidelines/
- https://google.github.io/swift/



## Issue generation for issue navigator

It can be handy to use TODO and FIXME markers during development.  To allow these to show up in the Issue Navigator, I added a build phase run script.

