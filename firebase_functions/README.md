# Instructions for initializing the application with your own Firebase Instance
There are 4 main steps:
1. Create and initialize a **firebase application**
2. **Initialize Firebase Tools** on your local machine and **deploy functions and rules** to your firebase instance
3. Link your **android application instance** to your firebase application
4. **Authorize accounts** for use with the firebase instance

## Creating & Initializing a Firebase Application
1. Go to https://console.firebase.google.com/ and create a new project. You may use Google Analytics.
2. Register the android application with the firebase instance:
    * Create a new android application in the console with the package name `il.ac.biu.cs.workshop_digitalization`
    * Make sure to download and save `google-services.json` as you will need it for the linking process
    * Steps 3 and 4 in the initialization may be skipped since the application already passed them
3. Initialize **Authentication**, **Database** and **Storage**:
    * Authentication - Enable the sign up method named `Email/Password`
    * Database - Create a Database (in **Production Mode**), you may choose whatever database location you want. We used eur3 (europe-west).
    * Storage - Create a Storage Bucket

First, we have to **install and initialize** Firebase Tools on our local machine:

## Initialize Firebase Tools and Deploy Functions & Rules

### **Online Instructions**
The instructions for the **installation**(without deploying) are available in this video:
https://youtu.be/DYfP-UIKxH0

And in this link:
https://firebase.google.com/docs/functions/get-started#set-up-node.js-and-the-firebase-cli (steps 2 and 3)

### **Full Instructions (with deployment)**
1. **Install NPM**(node package manager) and make sure it's set in the PATH
2. **Installing Firebase Tools**: Run the command `npm install -g firebase-tools`
    * To ensure latest version use:

	    `npm install firebase-functions@latest firebase-admin@latest --save`

        `npm install -g firebase-tools`

    * You should be able to run the `firebase` command now, try it out (for example `firebase -V` will return the firebase version, we tested on version 8.6.0)
3. **Initialize Firebase Tools**: Run the command `firebase login`, and choose your google account where you initialized your firebase project.
    * If login was successful, try running the command `firebase projects:list` to see a list of all the firebase projects associated with your account. You should see your firebase project listed there (something like this):
    ```
    ┌──────────────────────┬────────────┬────────────────┬──────────────────────┐
    │ Project Display Name │ Project ID │ Project Number │ Resource Location ID │
    ├──────────────────────┼────────────┼────────────────┼──────────────────────┤
    │ test                 │ test-a97ea │ 281064715819   │ europe-west          │
    └──────────────────────┴────────────┴────────────────┴──────────────────────┘
    ```
    * Grab the `Project ID` of the desired firebase project and type in console `firebase use <ProjectID>`, in my example I would type `firebase use test-a97ea`.
    * Now you are ready to deploy the firebase functions and rules.
4. **Install Dependencies**: You need the NPM dependencies installed on your machine. To install run the command `firebase install` in the project folder.
5. **Deploy**: Make sure your console working directory is `firebase_functions`, after that, type in the console `firebase deploy`. This will upload the **firebase functions** and **custom rules** for **firestore** and **storage**.
    * You should be expecting output ending like this:
        ```
        +  functions: Finished running predeploy script.
        i  firebase.storage: checking storage.rules for compilation errors...
        +  firebase.storage: rules file storage.rules compiled successfully
        i  firestore: reading indexes from firestore.indexes.json...
        i  cloud.firestore: checking firestore.rules for compilation errors...
        +  cloud.firestore: rules file firestore.rules compiled successfully
        i  functions: ensuring required API cloudfunctions.googleapis.com is enabled...

        !  functions: The Node.js 8 runtime is deprecated and will be decommissioned on 2021-03-15. For more information, see: https://firebase.google.com/support/faq#functions-runtime

        +  functions: required API cloudfunctions.googleapis.com is enabled
        i  storage: latest version of storage.rules already up to date, skipping upload...
        +  firestore: deployed indexes in firestore.indexes.json successfully
        i  firestore: latest version of firestore.rules already up to date, skipping upload...
        i  functions: preparing functions directory for uploading...
        i  functions: packaged functions (31.1 KB) for uploading
        +  functions: functions folder uploaded successfully
        +  storage: released rules storage.rules to firebase.storage
        +  firestore: released rules firestore.rules to cloud.firestore
        i  functions: updating Node.js 8 (Deprecated) function disableOnRegister(us-central1)...
        i  functions: updating Node.js 8 (Deprecated) function enableAllowedAccounts(us-central1)...
        +  functions[enableAllowedAccounts(us-central1)]: Successful update operation.
        +  functions[disableOnRegister(us-central1)]: Successful update operation.

        +  Deploy complete!
        ```
6. **Test**: You may test everything was deployed:

    * In the `Database` section, under the `Rules` tab you should see the following content:
        ```
        rules_version = '2';
        service cloud.firestore {
          // allow only logged in users to read and write
          match /{document=**} {
            allow read, write: if request.auth != null && request.auth.token.admin == true;
          }
        }
        ```
    * In the `Storage` section, under the `Rules` tab you should see the following content:
        ```
        rules_version = '2';
        service firebase.storage {
        match /b/{bucket}/o {
            // allow only logged in users to read and write
            match /{allPaths=**} {
            allow read, write: if request.auth != null && request.auth.token.admin == true;
            }
          }
        }
        ```
    * In the `Functions` section, under the `Dashboard` tab, you should see two functions:

        1. `disableOnRegister` with the trigger `user.create`
        2. `enableAllowedAccounts` with the trigger `document.write; allowed/{doc_id}`
7. Everything on the firebase side is ready for use now.


## Linking the Android Application to the Firebase Application
1. After all the previous steps were passed, you can finally open the Android Application
2. Copy the `google-services.json` contents into your clipboard
3. You should see the contents of your clipboard as plaintext in the main screen of the application. You may confirm everything was copied correctly. If not, try repeating `step 2 and 3`
4. If everything seems ok, hit the `Load` button to load the firebase instance contents for use with the application. You should see the login screen now. If not, click the `Change Database` button and then try repeating `steps 2-4`. If the error persists, you may have to re-initalize the Android Application on your Firebase (and download a new `google-services.json`) as described in `Part 1`.

## Authorizing Accounts (Do this for every user that logs in for the first time)
1. You are now in the login screen, and you're almost ready to start using the application.
2. Choose your login credentials, we recommend using a randomly generated password and then enabling the `Save Password` option as it will make things much more convenient for you as a user.

    **Note**: The password is saved as plaintext on the SharedPreferences of your android phone, so make sure **NOT** to enable it if you use that one password which you repeat in several places.
3. Hit the register button. You should see a success message. If not, there is a problem with connection to firebase, or you may have initialized things wrong.
4. Go to your **Firebase Console** under the **Authentication** section and locate the **Users** Tab.
5. You should see a newly registered **Disabled** user with the mail you just specified in the login screen.
6. Copy the user id (for example `kh5lph2GJTR6IfXUmtbwtDdHzPl2`) and go to the `Database` section.
7. In `Cloud Firestore`, start a new collection (if doesn't exist) named `allowed`
8. Under that collection, create a new document with an id identical to the previously copied user id(example: `kh5lph2GJTR6IfXUmtbwtDdHzPl2`). The new document should include a boolean field named `admin`.
9. If you want to give permissions to the new user, make sure `admin` is set to `true`. If it is set to `false`, or if the document does not exist, the user permissions are **revoked**

    **Note**: The revoking doesn't work with logged in users, as firebase functions don't allow revoking an OAuth2 credential given to a user. The revoking must happen while the user is logged out.
10. Now go back to the `Authentication` section and check if the newly created user is enabled/disabled(according to the **admin** value). This may take a little while for the `enableAllowedAccounts` function to start running, so if you don't see it immediately, try to refresh a few times.
11. After the user is enabled, you can finally log into the app and start using it. You may need to hit the `Create Root` button to start using for the first time.
