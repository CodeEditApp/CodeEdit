# Contribute to CodeEdit

Feel free to join and collaborate on our [Discord Server](https://discord.gg/vChUXVf9Em).

> ⚠️ Please do not submit `localization` related pull requests at this time. 
> Once we are ready to support more languages we will let you know with a guide on how to contribute here and on our [Discord Server](https://discord.gg/vChUXVf9Em).

## Fork & Clone CodeEdit

Tap the **"Fork"** button on the top of the site. After forking clone the forked repository to your Mac.

## Explore Issues

Find issues from the [Issues tab](https://github.com/CodeEditApp/CodeEdit/issues) or from the To Do column in our [project](https://github.com/orgs/CodeEditApp/projects/3/views/2). If you find an issue you want to work on, please indicate it in the issue and/or attach a draft PR once available. An admin or maintainer will then assign the Issue and/or PR to you.

## Getting Started

Please read the [Getting Started](https://github.com/CodeEditApp/CodeEdit/wiki/Getting-Started) guide in our wiki.

We also have a [troubleshooting guide](https://github.com/CodeEditApp/CodeEdit/wiki/Troubleshooting) that provides common resolutions.

## Code Style

Please read our guide on [Code Style](https://github.com/CodeEditApp/CodeEdit/wiki/Code-Style) in our wiki.

## Pull Request

Once you are happy with your changes, submit a `Pull Request`.

The pull request opens with a template loaded. Fill out all fields that are relevant.

The `PR` should include following information:
* A descriptive **title** on what changed.
* A detailed **description** of changes.
* If you made changes to the UI please add a **screenshot** or **video** as well.
* If there is a related issue please add a **reference to the issue**. If not, create one beforehand and link it.
* If your PR is still in progress mark it as **Draft**.

### Checks, Tests & Documentation

Request a review from one of our admins @austincondiff, @lukepistrol, @MarcoCarnevali, @jasonplatts, @pkasila or maintainers @cstef, @linusS1, @RayZhao1998, @wdg.

Note: If it is your first PR, an admin will need to request a review for you.

> Please resolve all `Violation` errors in Xcode (except: _TODO:_ warnings). Otherwise the swiftlint check on GitHub will fail.

Once you submit the `PR` GitHub will run a couple of actions which run tests and `SwiftLint` (this can take a couple of minutes). Should a test fail, it cannot be merged until tests succeed.

Make sure to resolve all merge-conflicts otherwise the `PR` cannot be merged.

> **Important**: make sure your code is well documented so others can interact with your code easily!
