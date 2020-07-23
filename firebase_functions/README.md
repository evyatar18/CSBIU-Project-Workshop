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
4. **Deploy**: Make sure your console working directory is `firebase_functions`, after that, type in the console `firebase deploy`. This will upload the **firebase functions** and **custom rules** for **firestore** and **storage**.
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
5. **Test**: You may test everything was deployed:

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
6. Everything on the firebase side is ready for use now.