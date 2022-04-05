![github-cover](https://user-images.githubusercontent.com/806104/157921972-022b758f-eb9d-4436-881a-d94c883d5685.png)

# CodeEdit macOS App
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-15-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->
![GitHub branch checks state](https://img.shields.io/github/checks-status/CodeEditApp/CodeEdit/main)
![GitHub Repo stars](https://img.shields.io/github/stars/CodeEditApp/CodeEdit)
![GitHub forks](https://img.shields.io/github/forks/CodeEditApp/CodeEdit)
[![Discord Badge](https://img.shields.io/discord/951544472238444645?color=5865F2&label=Discord&logo=discord&logoColor=white&style=flat-square)](https://discord.gg/vChUXVf9Em)

| :warning: | **CodeEdit is currently in development and we do not yet offer a download.** <br> We will post a link here when we have an alpha release ready for testing. Until then, we welcome contributors to help bring this project to life. | &nbsp;&nbsp;&nbsp;&nbsp;[CONTRIBUTE](https://github.com/CodeEditApp/CodeEdit/blob/main/CONTRIBUTING.md)&nbsp;&nbsp;&nbsp;&nbsp; |
| - |:-| - |

## Motivation

Developers that use a Mac shouldn't be forced to use an app from the other guys. Yes, these other editors have growing communities and infrastructure around extensions and have seen incredible adoption that satisfies the needs of most developers. However, comparable editors are built on Electron. This is a huge limitation because it cannot utilize all system resources to their fullest potential.

Electron requires a Chromium instance to run. This can mean massive performance losses and high RAM usage even for small apps built on it. Additionally, the overall code footprint is much larger and animations are slower. More frames are lost and things like window resizing feel laggy. Native apps are smooth as butter and better utilize all system resources for better performance and reliability. For more information on this, we'll point you to [a fantastic article](https://www.remotion.com/blog/why-remotion-is-a-native-macos-app-not-electron) by the nice folks at Remotion.

Xcode offers this native experience and it feels right at home on the Mac however it mostly just supports projects written specifically for Apple platforms. There are many projects not written for Apple platforms that deserve that same macOS-native experience as developers get with Xcode.

This led to the creation of [this concept](https://www.figma.com/proto/qj6raZbQsZpGO0NAVi4qsv/CodeEdit-Concept?node-id=1%3A870). We'd like to take this concept and make it a reality.

## Mission

We think there is room to streamline the developer experience. To gain maximum adoption, CodeEdit should be open source, free to use, and supported by the community. 

![codeedit-icon-equation](https://user-images.githubusercontent.com/806104/158899043-8a56e431-6705-40aa-93a6-3c909f20218c.png)

We'd like to keep our application light as TextEdit, but provide an experience like Xcode. In other words, we want to offer developers an IDE experience while staying lightweight.

Our goal is to develop an app that looks and feels like it was designed and developed by Apple and to closely stick to their design standards and development patterns even down to the application icon and naming strategy.

It might sound crazy, but it is our hope that at some point Apple adopts this project or at least feels like they could.

## Community

Join our growing community of amazing contributors on [Discord](https://discord.gg/vChUXVf9Em).

## To do

- [x] Initial concept design
- [x] Put starter app on GitHub
- [x] Start a [Discord server](https://discord.gg/vChUXVf9Em) for community collaboration
- [x] UI Framework - Navigator and Inspector Sidebars, Toolbar, Tabs, Breadcrumbs, Drawer, Statusbar
- [x] Welcome screen
- [x] Project navigator - Manage and edit files within a project
- [x] Source control navigator
- [x] Find navigator (find in project)
- [ ] Issue navigator
- [ ] Code symbols navigator
- [ ] Debug navigator
- [ ] Extension navigator
- [ ] Extensions API
- [ ] Extensions Store
- [x] Text editor
- [ ] Split editors
- [x] Syntax highlighting
- [ ] Find in document
- [x] Integrated terminal
- [x] Open quickly overlay
- [ ] Commands overlay
- [ ] Application Preferences
- [ ] Project Preferences
- [ ] File inspector

...more to come!


## Contributing

Read the [Contribution Guide](https://github.com/CodeEditApp/CodeEdit/blob/main/CONTRIBUTING.md)

## Contributors


<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="http://www.austincondiff.com"><img src="https://avatars.githubusercontent.com/u/806104?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Austin Condiff</b></sub></a><br /><a href="#design-austincondiff" title="Design">🎨</a> <a href="https://github.com/CodeEditApp/CodeEdit/commits?author=austincondiff" title="Code">💻</a></td>
    <td align="center"><a href="http://lukaspistrol.com"><img src="https://avatars.githubusercontent.com/u/9460130?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Lukas Pistrol</b></sub></a><br /><a href="#infra-lukepistrol" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/CodeEditApp/CodeEdit/commits?author=lukepistrol" title="Tests">⚠️</a> <a href="https://github.com/CodeEditApp/CodeEdit/commits?author=lukepistrol" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/pkasila"><img src="https://avatars.githubusercontent.com/u/17158860?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Pavel Kasila</b></sub></a><br /><a href="#infra-pkasila" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/CodeEditApp/CodeEdit/commits?author=pkasila" title="Tests">⚠️</a> <a href="https://github.com/CodeEditApp/CodeEdit/commits?author=pkasila" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/MarcoCarnevali"><img src="https://avatars.githubusercontent.com/u/9656572?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Marco Carnevali</b></sub></a><br /><a href="#infra-MarcoCarnevali" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/CodeEditApp/CodeEdit/commits?author=MarcoCarnevali" title="Tests">⚠️</a> <a href="https://github.com/CodeEditApp/CodeEdit/commits?author=MarcoCarnevali" title="Code">💻</a></td>
    <td align="center"><a href="https://wdg.codes"><img src="https://avatars.githubusercontent.com/u/1290461?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Wesley De Groot</b></sub></a><br /><a href="#infra-wdg" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/CodeEditApp/CodeEdit/commits?author=wdg" title="Tests">⚠️</a> <a href="https://github.com/CodeEditApp/CodeEdit/commits?author=wdg" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/nanashili"><img src="https://avatars.githubusercontent.com/u/63672227?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Nanashi Li</b></sub></a><br /><a href="https://github.com/CodeEditApp/CodeEdit/commits?author=nanashili" title="Code">💻</a></td>
    <td align="center"><a href="https://ninjiacoder.me"><img src="https://avatars.githubusercontent.com/u/22616933?v=4?s=100" width="100px;" alt=""/><br /><sub><b>ninjiacoder</b></sub></a><br /><a href="https://github.com/CodeEditApp/CodeEdit/commits?author=RayZhao1998" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://twitch.tv/Jeehut"><img src="https://avatars.githubusercontent.com/u/6942160?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Cihat Gündüz</b></sub></a><br /><a href="https://github.com/CodeEditApp/CodeEdit/commits?author=Jeehut" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/MysteryCoder456"><img src="https://avatars.githubusercontent.com/u/43755491?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Rehatbir Singh</b></sub></a><br /><a href="https://github.com/CodeEditApp/CodeEdit/commits?author=MysteryCoder456" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/Angelk90"><img src="https://avatars.githubusercontent.com/u/20476002?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Angelk90</b></sub></a><br /><a href="https://github.com/CodeEditApp/CodeEdit/commits?author=Angelk90" title="Code">💻</a></td>
    <td align="center"><a href="https://www.stefkors.com"><img src="https://avatars.githubusercontent.com/u/11800807?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Stef Kors</b></sub></a><br /><a href="https://github.com/CodeEditApp/CodeEdit/commits?author=StefKors" title="Code">💻</a></td>
    <td align="center"><a href="https://akringblog.com/"><img src="https://avatars.githubusercontent.com/u/6525286?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Chris Akring</b></sub></a><br /><a href="https://github.com/CodeEditApp/CodeEdit/commits?author=akring" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/highjeans"><img src="https://avatars.githubusercontent.com/u/77588045?v=4?s=100" width="100px;" alt=""/><br /><sub><b>highjeans</b></sub></a><br /><a href="https://github.com/CodeEditApp/CodeEdit/commits?author=highjeans" title="Code">💻</a></td>
    <td align="center"><a href="https://blog.windchillmedia.com"><img src="https://avatars.githubusercontent.com/u/35942988?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Khan Winter</b></sub></a><br /><a href="https://github.com/CodeEditApp/CodeEdit/commits?author=thecoolwinter" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/jasonplatts"><img src="https://avatars.githubusercontent.com/u/48892071?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Jason Platts</b></sub></a><br /><a href="#infra-jasonplatts" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="#plugin-jasonplatts" title="Plugin/utility libraries">🔌</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

## Sponsors

Support CodeEdit's development by [becoming a sponsor](https://github.com/sponsors/CodeEditApp).

<a href="https://github.com/panascais" target="_blank"><img src="https://avatars.githubusercontent.com/u/19628635?s=200&v=4" width="128"></a>

[![powered-by-vercel](https://user-images.githubusercontent.com/806104/161609938-2fe03e88-fd43-4ed4-a2d2-8d3e3fc4eec7.svg)](https://vercel.com/?utm_source=codeedit&utm_campaign=oss)


## Backers

Support CodeEdit's development by [becoming a backer](https://github.com/sponsors/CodeEditApp).

<a href="https://github.com/dannydorazio" target="_blank"><img src="https://avatars.githubusercontent.com/u/21158275?v=4" width="64"></a>

### Thanks to all of our other backers

[@omrd](https://github.com/omrd)

## License

Licensed under the [MIT license](https://github.com/CodeEditApp/CodeEdit/blob/main/LICENSE.md).
