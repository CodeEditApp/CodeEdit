<p align="center">
  <img src="https://user-images.githubusercontent.com/806104/163099605-4eaedd33-8441-4125-9ca1-a7ccb2f62a74.png" height="128">
  <h1 align="center">CodeEdit for macOS</h1>
</p>

<p align="center">
  <a aria-label="Follow CodeEdit on Twitter" href="https://twitter.com/CodeEditApp" target="_blank">
    <img alt="" src="https://img.shields.io/badge/Follow%20@CodeEditApp-black.svg?style=for-the-badge&logo=Twitter">
  </a>
  <a aria-label="Join the community on Discord" href="https://discord.gg/vChUXVf9Em" target="_blank">
    <img alt="" src="https://img.shields.io/badge/Join%20the%20community-black.svg?style=for-the-badge&logo=Discord">
  </a>
</p>

CodeEdit is a code editor built by the community, for the community, written entirely and unapologetically for macOS. Features include syntax highlighting, code completion, project find and replace, snippets, terminal, task running, debugging, git integration, code review, extensions, and more. 

<img width="1012" alt="github-banner" src="https://user-images.githubusercontent.com/806104/163101427-4787970f-c78b-4a98-a29b-1ef26b62fd40.png">

[![All Contributors](https://img.shields.io/badge/all_contributors-32-orange.svg?style=flat-square)](#contributors-)
![GitHub branch checks state](https://img.shields.io/github/checks-status/CodeEditApp/CodeEdit/main?style=flat-square)
![GitHub Repo stars](https://img.shields.io/github/stars/CodeEditApp/CodeEdit?style=flat-square)
![GitHub forks](https://img.shields.io/github/forks/CodeEditApp/CodeEdit?style=flat-square)
[![Discord Badge](https://img.shields.io/discord/951544472238444645?color=5865F2&label=Discord&logo=discord&logoColor=white&style=flat-square)](https://discord.gg/vChUXVf9Em)

| :warning: | **CodeEdit is currently in development and we do not yet offer a download.** <br> We will post a link here when we have an alpha release ready for testing. Until then, we welcome contributors to help bring this project to life. | &nbsp;&nbsp;&nbsp;&nbsp;[CONTRIBUTE](https://github.com/CodeEditApp/CodeEdit/blob/main/CONTRIBUTING.md)&nbsp;&nbsp;&nbsp;&nbsp; |
| - |:-| - |

## Table of Contents

- [Motivation](#motivation)
- [Mission](#mission)
- [Community](#community)
- [Contributing](#contributing)
- [Contributors](#contributors)
- [Sponsors](#sponsors)
- [Backers](#backers)
- [License](#license)

## Motivation

Developers that use a Mac should be able to use an editor that feels at home on the Mac. Comparable editors are built on Electron. This is a huge limitation because it cannot utilize system resources to their fullest potential.

Electron requires a Chromium instance to run. This can mean massive performance losses and high RAM usage even for small apps built on it. Additionally, the overall code footprint is much larger and animations are slower. More frames are lost and things like window resizing feels laggy. Native apps are smooth as butter and utilize system resources much more efficiently for better performance and reliability. For more information on this, we'll point you to [a fantastic article](https://www.remotion.com/blog/why-remotion-is-a-native-macos-app-not-electron) by the nice folks at Remotion.

Xcode offers this great native experience however it mostly supports projects written specifically for Apple platforms. There are many projects not written for Apple platforms that deserve that same macOS-native experience that developers get with Xcode.

This raised the question, what if such an editor existed? We think developers deserve a native experience. This led to the creation of [this concept](https://www.figma.com/proto/qj6raZbQsZpGO0NAVi4qsv/CodeEdit-Concept?node-id=1%3A870) which our project aims to make a reality.

## Mission

We think there is room to streamline the developer experience. To gain maximum adoption, CodeEdit should be open source, free to use, and supported by the community. 

![github-equation](https://user-images.githubusercontent.com/806104/163101287-feba5466-dde0-450c-a9ac-8f9dd3d00e52.png)

We'd like to keep our application light as TextEdit, but provide an experience similar to Xcode. In other words, we'd like to offer developers the power of a full IDE while remaining lightweight.

Our goal is to develop an app that looks and feels like it was designed and developed by Apple and to closely stick to their design standards and development patterns even down to the application icon and naming strategy.

It might sound crazy, but it is our hope that at some point Apple adopts this project or at least feels like they could.

## Community

Join our growing community on [Discord](https://discord.gg/vChUXVf9Em) where we discuss and collaborate on all things CodeEdit. Don't be shy, jump right in and be part of the discussion!

## Contributing

Be part of the next revolution in code editing by contributing to the project. This is a community-led effort, so we welcome as many contributors who can help. Read the [Contribution Guide](https://github.com/CodeEditApp/CodeEdit/blob/main/CONTRIBUTING.md) for more information.

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
    <td align="center"><a href="https://github.com/dzign1"><img src="https://avatars.githubusercontent.com/u/44317715?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Rob Hughes</b></sub></a><br /><a href="https://github.com/CodeEditApp/CodeEdit/commits?author=dzign1" title="Code">💻</a></td>
    <td align="center"><a href="https://lingxi.li"><img src="https://avatars.githubusercontent.com/u/36816148?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Lingxi Li</b></sub></a><br /><a href="https://github.com/CodeEditApp/CodeEdit/commits?author=lilingxi01" title="Code">💻</a> <a href="https://github.com/CodeEditApp/CodeEdit/issues?q=author%3Alilingxi01" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://github.com/octree"><img src="https://avatars.githubusercontent.com/u/7934444?v=4?s=100" width="100px;" alt=""/><br /><sub><b>HZ.Liu</b></sub></a><br /><a href="https://github.com/CodeEditApp/CodeEdit/commits?author=octree" title="Code">💻</a> <a href="https://github.com/CodeEditApp/CodeEdit/issues?q=author%3Aoctree" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://www.youtube.com/channel/UCx1gvWpy5zjOd7yZyDwmXEA?sub_confirmation=1"><img src="https://avatars.githubusercontent.com/u/8013017?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Richard Topchii</b></sub></a><br /><a href="https://github.com/CodeEditApp/CodeEdit/commits?author=richardtop" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/Pythonen"><img src="https://avatars.githubusercontent.com/u/53183345?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Pythonen</b></sub></a><br /><a href="https://github.com/CodeEditApp/CodeEdit/commits?author=Pythonen" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/jav-solo"><img src="https://avatars.githubusercontent.com/u/10246220?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Javier Solorzano</b></sub></a><br /><a href="https://github.com/CodeEditApp/CodeEdit/commits?author=jav-solo" title="Code">💻</a> <a href="https://github.com/CodeEditApp/CodeEdit/issues?q=author%3Ajav-solo" title="Bug reports">🐛</a></td>
  </tr>
  <tr>
    <td align="center"><a href="http://angcosmin.com"><img src="https://avatars.githubusercontent.com/u/8146514?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Cosmin Anghel</b></sub></a><br /><a href="https://github.com/CodeEditApp/CodeEdit/commits?author=AngCosmin" title="Code">💻</a></td>
    <td align="center"><a href="http://mmshivesh.ml"><img src="https://avatars.githubusercontent.com/u/23611514?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Shivesh</b></sub></a><br /><a href="https://github.com/CodeEditApp/CodeEdit/commits?author=mmshivesh" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/drucelweisse"><img src="https://avatars.githubusercontent.com/u/36012972?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Andrey Plotnikov</b></sub></a><br /><a href="https://github.com/CodeEditApp/CodeEdit/commits?author=drucelweisse" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/POPOBE97"><img src="https://avatars.githubusercontent.com/u/7891810?v=4?s=100" width="100px;" alt=""/><br /><sub><b>POPOBE97</b></sub></a><br /><a href="https://github.com/CodeEditApp/CodeEdit/commits?author=POPOBE97" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/nrudnyk"><img src="https://avatars.githubusercontent.com/u/20221382?v=4?s=100" width="100px;" alt=""/><br /><sub><b>nrudnyk</b></sub></a><br /><a href="https://github.com/CodeEditApp/CodeEdit/commits?author=nrudnyk" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/KaiTheRedNinja"><img src="https://avatars.githubusercontent.com/u/88234730?v=4?s=100" width="100px;" alt=""/><br /><sub><b>KaiTheRedNinja</b></sub></a><br /><a href="https://github.com/CodeEditApp/CodeEdit/commits?author=KaiTheRedNinja" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/benkoska"><img src="https://avatars.githubusercontent.com/u/17319613?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Ben Koska</b></sub></a><br /><a href="https://github.com/CodeEditApp/CodeEdit/commits?author=benkoska" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/evolify"><img src="https://avatars.githubusercontent.com/u/12669069?v=4?s=100" width="100px;" alt=""/><br /><sub><b>evolify</b></sub></a><br /><a href="https://github.com/CodeEditApp/CodeEdit/issues?q=author%3Aevolify" title="Bug reports">🐛</a></td>
    <td align="center"><a href="https://github.com/shibotong"><img src="https://avatars.githubusercontent.com/u/44807628?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Shibo Tong</b></sub></a><br /><a href="https://github.com/CodeEditApp/CodeEdit/commits?author=shibotong" title="Code">💻</a></td>
    <td align="center"><a href="https://ethanwong.me"><img src="https://avatars.githubusercontent.com/u/8158163?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Ethan Wong</b></sub></a><br /><a href="https://github.com/CodeEditApp/CodeEdit/commits?author=GetToSet" title="Code">💻</a></td>
    <td align="center"><a href="http://gantoreno.com"><img src="https://avatars.githubusercontent.com/u/43397475?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Gabriel Moreno</b></sub></a><br /><a href="https://github.com/CodeEditApp/CodeEdit/issues?q=author%3Agantoreno" title="Bug reports">🐛</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

## Sponsors

Support CodeEdit's development by [becoming a sponsor](https://github.com/sponsors/CodeEditApp).

<a title="Vercel" href="https://vercel.com/?utm_source=codeedit&utm_campaign=oss" target="_blank"><img src="https://user-images.githubusercontent.com/806104/162766170-60f3b95a-ca30-4015-a3e3-a605df78b98a.png" width="128"></a>
<a title="MacStadium" href="https://macstadium.com" target="_blank"><img src="https://user-images.githubusercontent.com/806104/162766594-eff7f985-31a9-48c5-9e58-139794fefa10.png" width="128"></a>
<a title="GitBook" href="https://www.gitbook.com/" target="_blank"><img src="https://user-images.githubusercontent.com/806104/162766464-c10dc9fc-088a-4945-a0e1-17bd42705b70.png" width="128"></a>
<a title="panascais" href="https://github.com/panascais" target="_blank"><img src="https://avatars.githubusercontent.com/u/19628635?s=200&v=4" width="128"></a>
<a title="DevUtilsApp" href="https://devutils.app/?utm_source=codeedit&utm_campaign=oss" target="_blank"><img src="https://devutils.app/512.png" width="128"></a>

## Backers

Support CodeEdit's development by [becoming a backer](https://github.com/sponsors/CodeEditApp).

<a title="dannydorazio" href="https://github.com/dannydorazio" target="_blank"><img src="https://avatars.githubusercontent.com/u/21158275?v=4" width="64"></a>
<a title="omrd" href="https://github.com/omrd" target="_blank"><img src="https://avatars.githubusercontent.com/u/34616424?v=4" width="64"></a>
<a title="sparrowcode" href="https://github.com/sparrowcode" target="_blank"><img src="https://avatars.githubusercontent.com/u/98487302?s=200&v=4" width="64"></a>
<a title="Gebes" href="https://github.com/Gebes" target="_blank"><img src="https://avatars.githubusercontent.com/u/35232234?v=4" width="64"></a>
<a title="lovetodream" href="https://github.com/lovetodream" target="_blank"><img src="https://avatars.githubusercontent.com/u/38291523?v=4" width="64"></a>
<a title="ridafkih" href="https://github.com/ridafkih" target="_blank"><img src="https://avatars.githubusercontent.com/u/9158485?v=4" width="64"></a>

### Thanks to all of our other backers

[@ivanvorobei](https://github.com/ivanvorobei)
[@albertorestifo](https://github.com/albertorestifo)
[@rkusa](https://github.com/rkusa)
[@cadenkriese](https://github.com/cadenkriese)
[@petrjahoda](https://github.com/petrjahoda)
[@allejo](https://github.com/allejo)
[@frousselet](frousselet)
[@wkillerud](wkillerud)

## License

Licensed under the [MIT license](https://github.com/CodeEditApp/CodeEdit/blob/main/LICENSE.md).
