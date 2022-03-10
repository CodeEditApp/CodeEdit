# CodeEdit macOS App

This open source app is in need of contributors. 

<img width="1153" alt="github-cover" src="https://user-images.githubusercontent.com/806104/157763529-fef2b06e-c989-49cd-ad4c-19a6377971c1.png">

## Mission

Our goal is to develop an app that looks and feels like it was designed and developed by Apple. We think there is room to really streamline the developer experience. Something that Xcode has done. We want to offer users an IDE experience while staying lightweight. 

## Motivation

I am a UI designer and developer focusing on web based applications (Javascript/React). I've been playing around with Swift/SwiftUI and I am really impressed with it and with Xcode and how it felt to use it compared to other mainstream editors. Thinking about this lead me to create [this concept](https://www.figma.com/proto/qj6raZbQsZpGO0NAVi4qsv/CodeEdit-Concept). Developers that use a Mac shouldn't be forced to use an app from the other guys. 

Yes, there are other editors that already have a growing community and infrastructure around extensions, and has seen incredible adoption that satisfies the needs of most developers. That said, most are built on Electron. This is a huge limitation because it cannot utilize all system resources to it's fullest potential.

Electron requires a Chromium instance in order to run. This can mean massive performance losses and high RAM usage even for a small apps built on it. Additionally, the overall code footprint is much larger and animations are slower. More frames are lost and things like window resizing feels laggy. Native apps are smooth as butter and better utilize all system resources for better performance and better reliability. For more information on this, we'll point you to [a fantastic article](https://www.remotion.com/blog/why-remotion-is-a-native-macos-app-not-electron) by the nice folks at Remotion.

## Todo

- [x] Design a concept
- [x] Start a boilerplate app
- [x] Set up a Github repository to allow the community to get involved
- [x] Start a [discord server](https://discord.gg/ANUVc6TF) for community collaboration
- [ ] Develop the underlying text editor complete with syntax heighlighting
- [ ] Project navigator - Manage and edit files within a project
- [ ] Source control navigator
- [ ] Find in document
- [ ] Find in project
- [ ] Open file search bar overlay
- [ ] Commands overlay
- [ ] Statusbar
- [ ] Tabs
- [ ] Split editors
- [ ] Extension manager
- [ ] Project preferences
- [ ] Application preferences
- [ ] Debug experience
- [ ] Code symbols navigator
- [ ] File information sidebar
...more to come

## Contributing

Feel free to join and collaborate on our [Discord server](https://discord.gg/ANUVc6TF).
