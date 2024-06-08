# Testing

CodeEdit utilizes Xcode's XCTest suite and PointFreeCo's snapshot library for testing. This document documents the methods for creating tests for both UI elements and Unit tests.

> Note: This document is likely to change in the future. As of writing (May 1, 2024) CodeEdit's interactive UI tests have been removed due to issues with the test runner. When those tests are added back instructions will be added here to add them. For now, non-interactive tests are all that's necessary.

## Testing Target & Plan

The `CodeEditTests` target contains all the code used for tests. It's divided into two folders: Features and Utils. When adding tests for a feature like Git a folder in the Features group should be added and a descriptive file should be added. Make sure to keep alphabetical order when adding new groups and files to the Features group.

The Utils group is for any extensions or helpers for testing. For instance the snapshot wrapper function, and useful hashing functions are stored here.

CodeEdit uses Xcode's test plan feature to plan our tests. The only test plan is called `CodeEditTestPlan.xctestplan`. All unit tests should be added automatically to this test plan. 

If a test needs to be disabled or given a specific configuration, new plans can be added to the test plan and specific tests or groups of tests can be disabled in the same place.

b## Adding Unit Tests

-   Ensure the correct feature folder exists in the Features group.
    -   If this is a new feature, a new folder should be added.
    -   If the feature already exists, there likely exists a test suite for the feature you're adding tests to. Use this file for the rest of the instructions.
    -   If there isn't a relevant test file, create a new swift file with a descriptive name in the feature folder.



## Adding UI Unit Tests

