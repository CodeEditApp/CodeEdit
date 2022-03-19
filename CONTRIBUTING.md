# Contribute to CodeEdit

Feel free to join and collaborate on our [Discord Server](https://discord.gg/vChUXVf9Em).

## Fork & Clone CodeEdit

Tap the **"Fork"** button on the top of the site. After forking clone the forked repository to your Mac.

## Open the Workspace

Inside the CodeEdit folder you just cloned to your Mac, make sure you open the `CodeEdit.xcworkspace` file with Xcode.

<img width="960" alt="Open CodeEdit.xcworkspace in Xcode" src="https://user-images.githubusercontent.com/9460130/158924759-42a61d23-4961-4bfb-8d44-930ec2427f0f.png">

> Note: Opening the `CodeEdit.xcodeproj` file will not include the local packages which are required to build & run.

## SwiftLint

In order to keep a unified style in our codebase we use `SwiftLint` to warn about inconsistencies. Make sure you have `SwiftLint` installed.

```bash
brew install swiftlint
```

> If this command does not work, make sure to install [Homebrew](https://brew.sh).

## Pull Request

Once you are happy with your changes, submit a `Pull Request`.

The `PR` should include follwing information:
* A descriptive **title** on what changed
* A detailed **description** of changes
* If you made changes to the UI please add a **screenshot** as well
* If there is a related issue please add a **reference to the issue**
* If your PR is still in progress mark it as **Draft**.

> Please resolve all `Violation` warnings in Xcode (except: _TODO:_ warnings). Otherwise the swiftlint check on GitHub will fail.

Once you submitted the `PR` GitHub will run a couple of actions which run tests and `SwiftLint` (this can take a couple of minutes). Should a test fail it cannot be merged until tests succeed.

Make sure to resolve all merge-conflicts otherwise the `PR` cannot be merged.
 
