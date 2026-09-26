# Google Docs setup for My High School Journey

This is a one-time app configuration step. Students do not enter these values themselves.

1. Open Google Cloud Console and create or select the project for My High School Journey.
2. Enable the **Google Docs API**. You may also enable the **Google Drive API** now because later versions may use Drive folders or additional file features.
3. Configure the OAuth consent screen for the app.
4. Create an **OAuth client ID** for **iOS** using this bundle ID:
   `org.scriptingforschools.MyHighSchoolJourney`
5. Copy the iOS client ID. It will look similar to:
   `1234567890-abcdefg.apps.googleusercontent.com`
6. Create the reversed client ID by reversing the Google domain prefix. For the example above it would be similar to:
   `com.googleusercontent.apps.1234567890-abcdefg`
7. In `project.yml`, replace these two placeholder values:
   - `replace-me.apps.googleusercontent.com`
   - `com.googleusercontent.apps.replace-me`
8. Commit the updated `project.yml` to GitHub and run the normal Codemagic/TestFlight build.

The app requests only `https://www.googleapis.com/auth/drive.file`, which limits access to files the student creates or opens through this app.
