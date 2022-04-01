# Contribute to CodeEdit

Feel free to join and collaborate on our [Discord Server](https://discord.gg/vChUXVf9Em).

> ⚠️ Please do not submit `localization` related pull requests at this time. 
> Once we are ready to support more languages we will let you know with a guide on how to contribute here and on our [Discord Server](https://discord.gg/vChUXVf9Em).

## Fork & Clone CodeEdit

Tap the **"Fork"** button on the top of the site. After forking clone the forked repository to your Mac.

## Explore Issues

Find issues from the [Issues tab](https://github.com/CodeEditApp/CodeEdit/issues) or from the To Do column in our project. If you find an issue you want to work on, please indicate it in the issue and/or attach a draft PR once available. An admin or maintainer will then assign the Issue and/or PR to you.

## Open the Workspace

Inside the CodeEdit folder you just cloned to your Mac, make sure you open the `CodeEdit.xcworkspace` file with Xcode (the white icon).

<img width="960" alt="Open CodeEdit.xcworkspace in Xcode" src="https://user-images.githubusercontent.com/9460130/158924759-42a61d23-4961-4bfb-8d44-930ec2427f0f.png">

> Note: Opening the `CodeEdit.xcodeproj` file will not include the local packages which are required to build & run.

### Troubleshooting

If you are experiencing problems or weird errors you did not expect after cloning the `main` branch try the following things:

* Clear `DerivedData` folder. Usually found in `~/Library/Developer/Xcode
* Reset package caches using `File > Packages > Reset Package Caches`
* Close the project and restart Xcode
* Make sure `SwiftLint` is installed on your Mac (see next section).

If you cannot resolve the issues by using those steps have a look at the `#help` channel on Discord. 

## SwiftLint

In order to keep a unified style in our codebase we use `SwiftLint` to warn about inconsistencies. Make sure you have `SwiftLint` installed.

```bash
brew install swiftlint
```

> If this command does not work, make sure to install [Homebrew](https://brew.sh).

## Coding Style & Documentation

In order to make code easily understandable documenting your code is required. Especially if you add functionality make sure that you:
* If you are not familiar with documentation have a read [here](https://developer.apple.com/documentation/xcode/writing-symbol-documentation-in-your-source-files).
* Also have a look at Swift's [API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/#conventions).
* use describing variables.
  ```swift
  /* Don't use this */
  var x = ...

  /* Use this */
  var panelWidth = ...
  ```
* use non-redundant function headers.
  ```swift
  /* Don't use this */
  func addNumber(number: Int, toNumber: Int) {}

  /* Use this */
  func addNumber(_ num1: Int, to num2: Int) {}
  ```
* Add comments to larger blocks of code describing each major step.
* Add documentation to at least all public `struct`, `class`, `enum`, and `func` declarations.
  > To add documentation in Xcode click on the name of the `struct`, `func`, ... and press `⌥ + ⌘ + /` or `⌘ + click` on the name and select `Add Documentation`.
* Don't leave commented code in your pull requests.
  ```swift
  /* remove the following */
  // func doSomething() {
  //     doSomethingElse() 
  // }
  ```
* Don't leave `print` statements in your pull request.
* If possible add your new feature as a package to `CodeEditModules`.
* Also consider adding `Tests`.
* Do not include any swiftlint disable rules in your pull request.

## Pull Request

Once you are happy with your changes, submit a `Pull Request`.

The pull request opens with a template loaded. Fill out all fields that are relevant.

The `PR` should include follwing information:
* A descriptive **title** on what changed.
* A detailed **description** of changes.
* If you made changes to the UI please add a **screenshot** or **video** as well.
* If there is a related issue please add a **reference to the issue**. If not create one beforehand an link it.
* If your PR is still in progress mark it as **Draft**.

### Checks and Tests

Request a review from one of our admins @austincondiff, @lukepistrol, @MarcoCarnevali, or maintainers @cstef, @jasonplatts, @linusS1, @pkasila, @RayZhao1998, @wdg.

> Please resolve all `Violation` errors in Xcode (except: _TODO:_ warnings). Otherwise the swiftlint check on GitHub will fail.

Once you submitted the `PR` GitHub will run a couple of actions which run tests and `SwiftLint` (this can take a couple of minutes). Should a test fail it cannot be merged until tests succeed.

Make sure to resolve all merge-conflicts otherwise the `PR` cannot be merged.
 
