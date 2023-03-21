const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { warn } = require("firebase-functions/logger");

exports.androidPushNotifications = functions.firestore.document("Notifications/{docId}").onCreate(
  (snap, context) => {
    admin.firestore().collection("devices").get().then(
      result => {
        var registrationTokens = [];
        result.docs.forEach(
          (value, index) => {
            console.warn('INDEX ', index);
            registrationTokens.push(value.data().token);
          }
        );
        admin.messaging().sendMulticast({
          message: {
            'title': snap.data().title,
            'body': snap.data().body
          },
          tokens: registrationTokens
        })
      }
    );
  }
);
