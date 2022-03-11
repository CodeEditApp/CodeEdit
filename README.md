# CodeEdit macOS App

![github-cover](https://user-images.githubusercontent.com/806104/157921972-022b758f-eb9d-4436-881a-d94c883d5685.png)

## Motivation

Developers that use a Mac shouldn't be forced to use an app from the other guys. Yes, these other editors have growing communities and infrastructure around extensions, and have seen incredible adoption that satisfies the needs of most developers. However, comparable editors are built on Electron. This is a huge limitation because it cannot utilize all system resources to it's fullest potential.

Electron requires a Chromium instance in order to run. This can mean massive performance losses and high RAM usage even for small apps built on it. Additionally, the overall code footprint is much larger and animations are slower. More frames are lost and things like window resizing feels laggy. Native apps are smooth as butter and better utilize all system resources for better performance and better reliability. For more information on this, we'll point you to [a fantastic article](https://www.remotion.com/blog/why-remotion-is-a-native-macos-app-not-electron) by the nice folks at Remotion.

Xcode offers this native experience and it feels right at home on the Mac but it only supports projects written in languages like Swift. There are other languages out there, and those working on those projects deserve that same macOS-native experience as they get in Xcode.

This lead to the creation of [this concept](https://www.figma.com/proto/qj6raZbQsZpGO0NAVi4qsv/CodeEdit-Concept?node-id=1%3A870). We'd like to take this concept and make it a reality. 

## Mission

Our goal is to develop an app that looks and feels like it was designed and developed by Apple. We think there is room to really streamline the developer experience. Something that Xcode has done. We want to offer users an IDE experience while staying lightweight. To gain maximum adoption, CodeEdit should be open source, free to use, and supported by the community. 

## To do

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
- [ ] Extension insfrastructure
- [ ] Extension manager
- [ ] Project preferences
- [ ] Application preferences
- [ ] Debug experience
- [ ] Code symbols navigator
- [ ] Integrated terminal
- [ ] File information sidebar

...more to come

## Contributing

Feel free to join and collaborate on our [Discord server](https://discord.gg/ANUVc6TF).
