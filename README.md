# Crypto

## Notes
- My refactoring focused mainly around how the view models were being used or not being used. I prefer to keep the view models contained within the view controller. I also added some additional unit tests to cover the view models.
- Tried to set it up so that we only test the VM's not the controller's spinning up a UIKit class is a pain in tests.
- I have a tagged commit which was the first iteration i thought made sense, but did not follow the readme and how the current code was being used, just in case.
- A mixture of UIKit, SwiftUI, RXSwift and Combine is used just to show i am capable of using all of them together, as some legacy projects will not be on the latest swift tech stack.
- also add tests with the new swift testing, just as a learning experiment  
- Moved the List VC to swift UI so the app and scene delgates could be deleted, reducing overhead and increasing code coverage
- after some experimenting how to use snapshot, still not as consistent as i would like but good enough for it's use case
