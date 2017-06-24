# Thoughtless

[![Platform iOS](https://img.shields.io/badge/platform-iOS-blue.svg?style=flat)](http://developer.apple.com/ios)
[![Language](http://img.shields.io/badge/language-swift-orange.svg?style=flat)](https://developer.apple.com/swift)
[![Swift 3 Compatible](https://img.shields.io/badge/swift3-compatible-4BC51D.svg?style=flat)](https://swift.org/blog/swift-3-0-released/)
[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/yoha/Notes/blob/master/LICENSE)
[![Issues](https://img.shields.io/github/issues/yoha/Thoughtless.svg?style=flat)](https://github.com/yoha/Thoughtless/issues)

## An iOS app that lets user quickly jot down thoughts with Markdown support.

![NotesTableViewController](http://i.imgur.com/JCgRD1W.png)
![NonEmptyNotesViewController](http://i.imgur.com/jzkSqv2.png)
![MarkdownNotesWebViewController](http://i.imgur.com/JhMLKl6.png)

![MarkdownUserGuide](http://i.imgur.com/ZwuuL0u.png)
![EditNotesTableViewController](http://i.imgur.com/ykeO1DE.png)
![EmptyNotesViewController](http://i.imgur.com/fsIg0uY.png)

## Description

Perhaps you are often in a situation where you want to jot down a thought that crosses your mind as quickly as you can so that 

1. You don't have to keep trying to remember it. 
2. You can move on to anticipate the next stream of thoughts. 

In those cases, Thoughtless, as its name implies, can help you store your thoughts quickly if you have a busy mind like I do.

#### Features:

- Immediate text entry mode every time you launch the app for a quick dump of thought.  
- Text formatting via Markdown. 
- Markdown's characters access on keyboard.  
- Search your thoughts. 
- Various swipe gestures for intuitive in-app navigation. 

ps: Make sure your device has iCloud pre-enabled.

## Installation Instructions

1. Install [Xcode 8](https://developer.apple.com/xcode/)
2. Download [Thoughtless source code](https://github.com/yoha/Thoughtless/releases/latest)
3. Open `Thoughtless.xcworkspace` in Xcode
4. Open Xcode's Preferences -> Accounts -> add your Apple ID
5. In Xcode's project navigator, click Thoughtless on the very top and go to Targets list -> Thoughtless -> General -> Identity and add a word to the end of the entry in Bundle Identifier to make it unique. Also select your Apple ID in Signing -> Team
6. Connect your iPhone or iPad and select it in Xcode's Product menu -> Destination
7. Press CMD+R or Product -> Run to install Thoughtless

## Credits

3rd Party Libraries used in this app:
- [CFAlertViewController](https://github.com/Codigami/CFAlertViewController) by [Crowdfire](https://github.com/Codigami)
- [HidingNavigationBar](https://github.com/tristanhimmelman/HidingNavigationBar) by [Tristan Himmelman](https://github.com/tristanhimmelman)
- [IQKeyboardManager](https://github.com/hackiftekhar/IQKeyboardManager) by [Mohd Iftekhar Qurashi](https://github.com/hackiftekhar)
- [SwiftHEXColors](https://github.com/thii/SwiftHEXColors) by [Thi](https://github.com/thii)

Icons used in this app:
- [Thought Bubble](http://www.flaticon.com/free-icon/thought-bubble_65491) by [Freepik](http://www.flaticon.com/authors/freepik)
- Icon pack by [Icons8](http://icons8.com)

## License

MIT License

Copyright (c) 2017 Yohannes Wijaya. All respective rights reserved.  

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
