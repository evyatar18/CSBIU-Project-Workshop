import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript

// export const helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Henlo from Firebase!");
// });

admin.initializeApp();

function getDisabled(after: admin.firestore.DocumentSnapshot): boolean {
    if (!after.exists) {
        return true;
    }

    const isAdmin: boolean | undefined = after.get("admin");
    return isAdmin == undefined || !isAdmin;
}

function setUserState(uid: string, disabled: boolean): Promise<any> {
    return Promise.all([
        admin.auth().updateUser(uid, { disabled: disabled }),
        admin.auth().setCustomUserClaims(uid, { "admin": !disabled })
    ]).then(async (_) => {
        const user = await admin.auth().getUser(uid);
        console.log(`Set user state for user with uid ${uid},\n`
            + `custom claims: ${user.customClaims}, disabled: ${user.disabled}`);

    });
}

export const disableOnRegister = functions.auth.user()
    .onCreate((user) => setUserState(user.uid, true));


export const enableAllowedAccounts = functions.firestore.document("/allowed/{doc_id}")
    .onWrite((change, _) => {
        const after = change.after;
        const userId = after.id;
        return setUserState(userId, getDisabled(after));
    });