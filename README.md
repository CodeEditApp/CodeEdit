# CodeEdit macOS App

![github-cover](https://user-images.githubusercontent.com/806104/157921972-022b758f-eb9d-4436-881a-d94c883d5685.png)


| :warning: | **CodeEdit is currently in development and we do not yet offer a download.** <br> We will post a link here when we have an alpha release ready for testing. Until then, we welcome contributors to help bring this project to life. | &nbsp;&nbsp;&nbsp;&nbsp;[CONTRIBUTE](https://github.com/CodeEditApp/CodeEdit/blob/main/CONTRIBUTING.md)&nbsp;&nbsp;&nbsp;&nbsp; |
| - |:-| - |

## To do

- [x] Design a concept
- [x] Start a boilerplate app
- [x] Set up a Github repository to allow the community to get involved
- [x] Start a [discord server](https://discord.gg/vChUXVf9Em) for community collaboration
- [x] Project navigator - Manage and edit files within a project
- [x] Source control navigator
- [x] Welcome screen
- [x] Text editor
- [x] Syntax highlighting
- [ ] Find in document
- [x] Find in project
- [x] Open file search bar overlay
- [ ] Commands overlay
- [x] Breadcrumb bar
- [x] Status bar
- [x] Tabs
- [ ] Split editors
- [ ] Extension insfrastructure
- [ ] Extension manager
- [ ] Project preferences
- [x] Application preferences
- [ ] Debug experience
- [ ] Code symbols navigator
- [x] Integrated terminal
- [ ] File information sidebar

...more to come!

## Motivation

Developers that use a Mac shouldn't be forced to use an app from the other guys. Yes, these other editors have growing communities and infrastructure around extensions, and have seen incredible adoption that satisfies the needs of most developers. However, comparable editors are built on Electron. This is a huge limitation because it cannot utilize all system resources to its fullest potential.

Electron requires a Chromium instance in order to run. This can mean massive performance losses and high RAM usage even for small apps built on it. Additionally, the overall code footprint is much larger and animations are slower. More frames are lost and things like window resizing feels laggy. Native apps are smooth as butter and better utilize all system resources for better performance and better reliability. For more information on this, we'll point you to [a fantastic article](https://www.remotion.com/blog/why-remotion-is-a-native-macos-app-not-electron) by the nice folks at Remotion.

Xcode offers this native experience and it feels right at home on the Mac but it mostly just supports projects written for Apple platforms. There are many projects not written for Apple platforms that deserve that same macOS-native experience as developers get in Xcode.

This lead to the creation of [this concept](https://www.figma.com/proto/qj6raZbQsZpGO0NAVi4qsv/CodeEdit-Concept?node-id=1%3A870). We'd like to take this concept and make it a reality. 

## Mission

We think there is room to really streamline the developer experience. Something that Xcode has done. We want to offer users an IDE experience while staying lightweight. To gain maximum adoption, CodeEdit should be open source, free to use, and supported by the community. 

Our goal is to develop an app that looks and feels like it was designed and developed by Apple and to closely stick to their design standards and development patterns even down to the application icon and naming strategy.

![codeedit-icon-equation](https://user-images.githubusercontent.com/806104/158899043-8a56e431-6705-40aa-93a6-3c909f20218c.png)

We'd like to keep our application light as TextEdit, but provide an experience like Xcode. 

It might sound crazy, but it is our hope that at some point Apple adopts this project or at least feels like they could.


## Contributing

Read the [Contribution Guide](https://github.com/CodeEditApp/CodeEdit/blob/main/CONTRIBUTING.md)

## License

Licensed under the [MIT license](https://github.com/CodeEditApp/CodeEdit/blob/main/LICENSE.md).
