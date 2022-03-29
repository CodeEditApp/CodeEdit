# CodeEdit macOS App

![github-cover](https://user-images.githubusercontent.com/806104/157921972-022b758f-eb9d-4436-881a-d94c883d5685.png)


| :warning: | **CodeEdit is currently under development and we do not yet offer a download.** <br> We'll post a link here when we have an alpha release ready for testing. Until then, we welcome contributors to help bring this project to life. | &nbsp;&nbsp;&nbsp;&nbsp;[CONTRIBUTE](https://github.com/CodeEditApp/CodeEdit/blob/main/CONTRIBUTING.md)&nbsp;&nbsp;&nbsp;&nbsp; |
| - |:-| - |

## To do

- [x] Design a concept
- [x] Start a boilerplate app
- [x] Set up a GitHub repository to allow the community to get involved
- [x] Start a [Discord server](https://discord.gg/vChUXVf9Em) for community collaboration
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

Developers that use Mac shouldn't be forced to use a code editor made by the other guys. Sure, these other editors do have large communities and growing libraries of extensions, but they also have one major limitation: they're built on Electron.

Electron is a one-size-fits-all framework that has one big issue: it's partially based on Chromium. Just like many Chromium-based browsers, Electron apps hog system resources, causing a slow and frusturating experience. Animations are slow, frames are lost, and window resizing is buggy.

Native apps just don't have these issues. Native apps better utilize system resouces, meaning they're faster and more reliable. Compared to Electron apps, native apps are as smooth as butter. The nice folks at Remotion wrote [this article](https://www.remotion.com/blog/why-remotion-is-a-native-macos-app-not-electron) which goes more in-depth about the differences between native apps and Electron apps.

When it comes to code editors, there's one in particular that feels right at home on the Mac: Xcode. The problem with Xcode, however, is that it's specifically purposed to build software for Apple platforms.

We believe there are many projects that deserve the same great development experience that Xcode offers. This philosophy led to the creation of [this concept](https://www.figma.com/proto/qj6raZbQsZpGO0NAVi4qsv/CodeEdit-Concept?node-id=1%3A870). We'd like to make this concept a reality.

## Mission

We think there is room to really streamline the developer experience. Something that Xcode has done for projects for Apple platorms. We want to offer users an IDE experience while staying lightweight. To gain maximum adoption, CodeEdit should be open source, free to use, and supported by the community. 

Our goal is to develop an app that looks and feels like it was designed and developed by Apple and to closely stick to their design standards and development patterns even down to the application icon and naming strategy.

![codeedit-icon-equation](https://user-images.githubusercontent.com/806104/158899043-8a56e431-6705-40aa-93a6-3c909f20218c.png)

We'd like to keep our application light as TextEdit, but provide an experience like Xcode. 

It might sound crazy, but it is our hope that at some point Apple adopts this project or at least feels like they could.


## Contributing

Read the [Contribution Guide](https://github.com/CodeEditApp/CodeEdit/blob/main/CONTRIBUTING.md)

## License

Licensed under the [MIT license](https://github.com/CodeEditApp/CodeEdit/blob/main/LICENSE.md).
