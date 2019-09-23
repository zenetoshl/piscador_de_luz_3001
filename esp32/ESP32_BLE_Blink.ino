/*
    Based on Neil Kolban example for IDF: https://github.com/nkolban/esp32-snippets/blob/master/cpp_utils/tests/BLE%20Tests/SampleWrite.cpp
    Ported to Arduino ESP32 by Evandro Copercini
*/

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

int LED_BUILTIN = 2;
int velocidade = 16;
const int velocidadeMax = 1;
const int velocidadeMin = 31;

// See the following for generating UUIDs:
// https://www.uuidgenerator.net/

#define SERVICE_UUID        "37f64eb3-c25f-449b-ba34-a5f5387fdb6d"
#define CHARACTERISTIC_UUID "560d029d-57a1-4ccc-8868-9e4b4ef41da6"


class MyCallbacks: public BLECharacteristicCallbacks {
    void onWrite(BLECharacteristic *pCharacteristic) {
      std::string value = pCharacteristic->getValue();
      if (velocidade > velocidadeMax && value[0] == 34){
        velocidade= velocidade - 1;
      } else if (velocidade < velocidadeMin && value[0] == 35){
        velocidade= velocidade + 1;
      }
      
    }
};

void setup() {
  

  BLEDevice::init("ESP32_Athena_Jose");
  
  BLEServer *pServer = BLEDevice::createServer();

  BLEService *pService = pServer->createService(SERVICE_UUID);

  BLECharacteristic *pCharacteristic = pService->createCharacteristic(
                                         CHARACTERISTIC_UUID,
                                         BLECharacteristic::PROPERTY_READ |
                                         BLECharacteristic::PROPERTY_WRITE
                                       );

  pCharacteristic->setCallbacks(new MyCallbacks());
  pinMode (LED_BUILTIN, OUTPUT);//Specify that LED pin is output
  pCharacteristic->setValue("Hello World");
  pService->start();

  BLEAdvertising *pAdvertising = pServer->getAdvertising();
  pAdvertising->start();
}

void loop() {
    digitalWrite(LED_BUILTIN, HIGH);   // turn the LED on (HIGH is the voltage level)
    delay(100*velocidade);                       // wait for a second
    digitalWrite(LED_BUILTIN, LOW);    // turn the LED off by making the voltage LOW
    delay(100*velocidade);
}
