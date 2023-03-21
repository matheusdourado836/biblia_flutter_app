const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require("axios");
admin.initializeApp();


exports.pubSubNotification = functions.pubsub.topic('versiculo_diario').onPublish((message) => {
  const messageBody = message.data ? Buffer.from(message.data, 'base64').toString() : null;
  androidPushNotifications();
  functions.logger.log(`Received message: ${messageBody}`);
  return null;
});

function androidPushNotifications() {
    const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6Ik1vbiBGZWIgMjAgMjAyMyAwMzowMDoxNyBHTVQrMDAwMC5tYXRoZXdkb3VyYWRvQGdtYWlsLmNvbSIsImlhdCI6MTY3Njg2MjAxN30.vKZaCH69KfQSzO5ICg5xQSj5Tt6ummDluwuUrTD4wSM';
    const options = {
      headers: {"Authorization": "Bearer ", token}
    }
    admin.firestore().collection('devices').get().then(
      result => {
        var registrationTokens = [];
        result.docs.forEach(
          (value, index) => {
            registrationTokens.push(value.data().user_token);
          }
        );

        return axios.get("https://www.abibliadigital.com.br/api/verses/nvi/random", options)
        .then(response => {
          const title = response.data.book.name + " " + response.data.chapter + ":" + response.data.number; 
          const body = response.data.text;
          const message = {
            notification: {
              title: "Hora de ler a Bíblia!",
              body: title + " " + body
            },
            payload: response.data.book.abbrev.pt + " " + response.data.book.name + " " + response.data.chapter + ":" + response.data.number,
            tokens: registrationTokens
          };
          return admin.messaging().sendMulticast(message);
        })
        .catch(error => {
          console.error(error);
        });
      }
    );
}


