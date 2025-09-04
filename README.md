## Architecture Explanation
>  MVVM: The app uses Model-View-ViewModel architecture. Views are declarative with SwiftUI. ViewModels handle business logic and state (e.g., UsersViewModel for fetching and managing users). Models represent data structures (e.g., User).
>  Networking: NetworkService handles API calls using URLSession and Combine.
>  Security: KeychainService manages secure token storage.
>  Combine: Used for all network operations.
>  Bonus: Loading indicators, pull-to-refresh, and infinite scroll pagination implemented.

## Steps to Run the Project
1.  Open the project in Xcode (15+ recommended).
2.  Build and run on iOS simulator or device (Minimum Deployments iOS 18.2+).
3.  Use provided credentials for login.
```
"email": "eve.holt@reqres.in"
"password": "cityslicka"
```
## Any Limitations
•  No offline support or caching.

## Unit tests
> Added unit test for Login api call with mock response, Users list api parsing & token storage & retrival.
<img width="580" height="565" alt="Screenshot 2025-09-04 at 12 07 55 PM" src="https://github.com/user-attachments/assets/c13890a5-af9a-4a80-8e00-d45225d2f142" />


## Git Repository
The completed project is available at: [Technical Project – Senior iOS Developer](https://github.com/shuvokarmakar011/Technical-Project-Assessment
)
