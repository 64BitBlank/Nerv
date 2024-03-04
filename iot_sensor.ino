#include <Arduino.h>
#if defined(ESP32) || defined(ARDUINO_RASPBERRY_PI_PICO_W)
#include <WiFi.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#elif __has_include(<WiFiNINA.h>)
#include <WiFiNINA.h>
#elif __has_include(<WiFi101.h>)
#include <WiFi101.h>
#elif __has_include(<WiFiS3.h>)
#include <WiFiS3.h>
#endif

#include <Firebase_ESP_Client.h>
#include <addons/TokenHelper.h>
#include <addons/RTDBHelper.h>

#define WIFI_SSID "VM0255918"
#define WIFI_PASSWORD "zY9ovsmh8ekyonBy"

#define API_KEY "asdf"

#define USER_EMAIL "test1@gmail.com"
#define USER_PASSWORD "uuuuuu"

#define DATABASE_URL "https://nerv-8ed11-default-rtdb.europe-west1.firebasedatabase.app/"

#define DATABASE_SECRET "DATABASE_SECRET"

#define LDRPIN 32


FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

unsigned long dataMillis = 0;
int count = 0;

#if defined(ARDUINO_RASPBERRY_PI_PICO_W)
WiFiMulti multi;
#endif

void setup()
{

    Serial.begin(115200);
    pinMode(LDRPIN, INPUT);
#if defined(ARDUINO_RASPBERRY_PI_PICO_W)
    multi.addAP(WIFI_SSID, WIFI_PASSWORD);
    multi.run();
#else
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
#endif

    Serial.print("Connecting to Wi-Fi");
    unsigned long ms = millis();
    while (WiFi.status() != WL_CONNECTED)
    {
        Serial.print(".");
        delay(300);
#if defined(ARDUINO_RASPBERRY_PI_PICO_W)
        if (millis() - ms > 10000)
            break;
#endif
    }
    Serial.println();
    Serial.print("Connected with IP: ");
    Serial.println(WiFi.localIP());
    Serial.println();

    Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);

    /* Assign the api key (required) */
    config.api_key = API_KEY;
    /* Assign the user sign in credentials */
    auth.user.email = USER_EMAIL;
    auth.user.password = USER_PASSWORD;
    /* Assign the RTDB URL */
    config.database_url = DATABASE_URL;

    // The WiFi credentials are required for Pico W
    // due to it does not have reconnect feature.
#if defined(ARDUINO_RASPBERRY_PI_PICO_W)
    config.wifi.clearAP();
    config.wifi.addAP(WIFI_SSID, WIFI_PASSWORD);
#endif

    // Comment or pass false value when WiFi reconnection will control by your code or third party library e.g. WiFiManager
    Firebase.reconnectNetwork(true);
    fbdo.setBSSLBufferSize(4096 /* Rx buffer size in bytes from 512 - 16384 */, 1024 /* Tx buffer size in bytes from 512 - 16384 */);
    fbdo.setResponseSize(4096);

    String base_path = "/Sensor Collection/";

    /* Assign the callback function for the long running token generation task */
    config.token_status_callback = tokenStatusCallback; // see addons/TokenHelper.h

    /* Initialize the library with the Firebase authen and config */
    Firebase.begin(&config, &auth);

    String var = "$userId";
    String val = "($userId === auth.uid && auth.token.premium_account === true && auth.token.admin === true)";
    Firebase.RTDB.setReadWriteRules(&fbdo, base_path, var, val, val, DATABASE_SECRET);
}

void loop()
{
    // Firebase.ready() should be called repeatedly to handle authentication tasks.
    int ldrStatus = analogRead(LDRPIN);
    float voltage = ldrStatus / 1200.0;
    if (millis() - dataMillis > 3000 && Firebase.ready())
    {
        dataMillis = millis();
        String uid = auth.token.uid.c_str(); //<- user uid of current user that sign in with Emal/Password

        // Counter
        String counterPath = "/UserSensors/" + uid + "/Counter";
        Serial.printf("Set int... %s\n", Firebase.RTDB.setInt(&fbdo, counterPath, count++) ? "ok" : fbdo.errorReason().c_str());

        // LDR
        String ldrPath = "/UserSensors/" + uid + "/LDR";
        Serial.printf("Set ldr... %s\n", Firebase.RTDB.setInt(&fbdo, ldrPath, ldrStatus) ? "ok" : fbdo.errorReason().c_str());

        // Voltage
        String voltagePath = "/UserSensors/" + uid + "/Voltage";
        Serial.printf("Set voltage... %s\n", Firebase.RTDB.setFloat(&fbdo, voltagePath, voltage) ? "ok" : fbdo.errorReason().c_str());
    }
}


