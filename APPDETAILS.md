- Application created on 16/1/2023 by Syam Kumar Own ideology by the grace of god App name is GlorifyGod 
- App name --->  Glorify God
- App basic idea and thoughts
   - Music that only for christ songs
   - Basic functions like forward and backward play pause feature 
   - Every song has a feature of adding to favourites


17/1/2023
   - Created app files Architecture
   - Designing themes 
   - Added just_audio package for audio implementation and testing design in process
   - Created git repo with glorify_god 
      - git hub setup done


18/1/2023
   - Started working on music player ui first

19/1/2023
   - Music started playing and some UI changes are done 
   - Forward and backward for 5 sec is done
   - Seek bar change done

20/1/2023
   - Working on music player
   - Google fonts package installed
   - home screen design

26/1/2023
   - Designed home tabs 
   - Liked and explore screens
   - font families
   - Selected song play after songs logic

29/1/2023
   - Pushing the code for 26th jan code
   - Starting UI improvements

4/2/2023
   - Bottom nav bar ui changes
   - Integrating Provider for music player {riverpod}

5/2/2023
   - Just audio integrated with provider 
   - bottom music bar integration
   - pop-up show on tap tile
1/5/2023
   - Pushing the code for previous improvements

10/3/23
   - Connecting app to localhost for testing the api calls
   - Set up your local development environment: You'll need to have a local development environment set up on your computer. You can use tools like XAMPP or WAMP to set up a local server.
   - Create an API endpoint: Create an API endpoint on your local server that will handle the requests from your Flutter app. You can use a server-side language like PHP or Node.js to create your API endpoint.
   - Test your API endpoint: Test your API endpoint to make sure it's working correctly. You can use tools like Postman or cURL to test your endpoint.
   - Make API calls from your Flutter app: In your Flutter app, use a package like http or dio to make API calls to your local server. Make sure to use the IP address or hostname of your computer instead of localhost in your API endpoint URL.
   - UNTIL I SET AN LOCAL ENVIRONMENT IT WONT BE POSSIBLE TO TEST THE LOCAL HOST API CALLS

18/4/23
   - Working on Google ADMob implementation
   - Getting errors need to fix them for ads

7/5/23
   - Added firebase google-services.json and firebase setup done
   - Added one Better days song to AWS bucket and url to the app - success

[comment]: <> (   - Let's set Gmail login page and storing cred in cache )

25/6/23
   - Implemented Splash screen with loading animation
   - Login with gmail implemented in login screen

26/8/23
   - Implemented LocalHost api (Tested
   
27/8/23
   - Firebase authentication in python fastapi
   - Added Login call and working on bug fixes on login User Model class 


28/8/23
   - Finally fixed the model class errors
   - Fire base google login linked with the UserLogin Api call
     
29/8/23
   - Adding new api call for testing the createArtist call with the createdAt as a timeStamp ( under Progress )
   - Continuing on 29th this month

4/12/2023
   - Added search api
   - Getting all Favourite songs in liked section with pull to refresh UI
   - On tap on searched list or the favourites list will play the song
   - Search field moved up to the app bar and profile section brought to the bottom bar
   - Explore section set to coming soon
   - Profile will show the background a fix quote image and the profile image on top with the name

- 3/1/2024
    - Working on EC2 instance connection with Database changes

- 4/1/2024
    - Added EndPoint with some changes in the end_points file - working fine
    - Fixed Some issues related to audio player
    - Home screen tile UI change
      Need more clarity on fixing the UI for title
    - Removed the youtube image box for testing ( No thought on bringing it back )
    - Liked songs song tile overflow fix

- 5/1/2024
  - Added min value to slider
  - Text alignments fixes
  - Audio player UI changes with blurred background with the song image
  - Bottom height and UI changes
  - Home screen app title changed with new font family

- 7/1/2024
  - Added all app icons
  - On tap music bar instead of bottomSheet now moved to materialRoute with page transition (code from chatGpt) works super fine
  - Search screen logic added on clearing the entry
  - End point moved to the domain system now that points to api.glorifygod.in
          