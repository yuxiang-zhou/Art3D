// Code Generate for Arduino
#include <stdio.h>
#include <cmath>
#include <unistd.h>

#define HIGH 1
#define LOW 0
#define OUTPUT 1

using namespace std;

void pinMode(int a, int b){}
void digitalWrite(int a, int b){}
void delayMicroseconds(int a){
    usleep(a);
}

// Start Here

// Controller Helper
//Set default parameters to the selected device
int InitDevice(byte nDeviceID)
{
  // 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20
  //B3 02 F8 0C 01 03 00 31 00 15 7C 02 26 02 26 00 01 00 01 1F FE 
  byte btys[] = {0xB3,0x02,0xF8, 0x0C,0x01,0x03,0x00,0x31,0x00,0x15,0x7C, 0x02, 0x26, 0x02,0x26, 0x00,0x01,0x00,0x01, 0x1F,0xFE}; 
  btys[4] = nDeviceID;
  btys[19] = CRC(btys,19);
  Serial1.write(btys,21);
   delay(50);    // waiting for the return data of the SerialPort
  int nread = Serial1.read();
  return nread;
  Serial.print(btys[19]);
}

//Send Run command to selected device
void Run(byte nDeviceID)
{
    byte btys1[] = {0xBA,0x02,0xF8,0x0C,0x01,0x03,0x01,0x30,0x00,0x63,0x9C,0x02,0x26,0x02,0x26,0x80,0xFE};
    btys1[4] = nDeviceID;
    btys1[15] = CRC(btys1,15);
    Serial1.write(btys1,17);
     delay(50);
     Serial1.flush();
    int nRead = 0;
    nRead = Serial1.read();
}

//
void Reverse(byte nDeviceID)
{
      Serial1.flush();
      byte btys3[] = {0xBA,0x02,0xF7,0xA8,0x01,0x03,0x02,0x30,0x00,0x63,0x9C,0x02,0x26,0x02,0x26,0x28,0xFE };
      btys3[4] = nDeviceID;
      btys3[15] = CRC(btys3,15);
      Serial1.write(btys3,17);
       Serial1.flush();
      int nRead = Serial1.read();  
}
//Stop 
void Stop(byte nDeviceID)
{
        Serial1.flush();
         byte btys2[] = {0xBA,0x02,0xF4,0x24,0x01,0x03,0x03, 0x30,0x00,0x63,0x9C,0x02,0x26,0x02, 0x26,0xA6,0xFE };
    btys2[4] = nDeviceID;
    btys2[15] = CRC(btys2,15);
         Serial1.write(btys2,17);
        delay(100);
        int nRead = Serial1.read();
        Serial1.flush();    
}

//Fast Step 100
void Fast(byte nDeviceID)
{
     byte btys4[] = {0xBA,0x02,0xF8,0x0C,0x01,0x03,0x00,0x30,0x00,0x63,0x9C,0x02,0x26,0x02,0x26,0x81,0xFE};
    btys4[4] = nDeviceID;
    btys4[15] = CRC(btys4,15);
     Serial1.write(btys4,17);
      Serial1.flush();
      delay(50);
    int nRead = Serial1.read();  
}
//Slow step 100
int Slow(byte nDeviceID)
{
       byte btys5[] = {0xBA,0x02,0xF7,0xA8,0x01,0x03,0x00,0x30,0x00,0x63,0x9C,0x02,0x26,0x02,0x26,0x2A,0xFE };
    btys5[4] = nDeviceID;
    btys5[15] = CRC(btys5,15);
     Serial1.write(btys5,17);
      Serial1.flush();
      delay(50);
     return Serial1.read();
}

//Process CRC
byte CRC(byte btys[], int nLength)
{
    byte bty = 0; 
    //int nRet = 0;
    for ( int i=0; i < nLength; i ++ )
    {
      //nRet = nRet ^ int(btys[i]);
      bty ^= btys[i];
    }
    return bty;
}

// Time Laps
float wave_delta = 0;

// Initial Position
float x[25];
float y[25];
float z[25];

// runing at 10 FPS
float delta = 100000;

// speed period
float speed_max = 500;
float speed_min = 800;
float step_size = 0.05;

// Feature Functions
float feature_wave(float x, float y, float d, float A, float W)
{
    float deg = x + d;
    return A * sin( deg / W );
}

float feature_gaussian(float x, float y, float d, float xmean, float ymean, float xstd, float ystd, float A)
{
    float x_gaussian = pow(x-xmean, 2) / (2 * pow(xstd, 2));
    float y_gaussian = pow(y-ymean, 2) / (2 * pow(ystd, 2));
    return A * exp (-(x_gaussian + y_gaussian));
}

float feature(float x, float y, float wave_delta, float wavespeed, float amplitude, float wavelength){
    float z = feature_wave(x, y, wave_delta*wavespeed, amplitude, wavelength);
    z += feature_gaussian(x, y, wave_delta*2, 0, 0, 60, 60, amplitude * 5);
    return z - 35;
}

// Helper
float range(float v, float l, float h)
{
    return fmax(l, fmin(v, h));
}

// Main
void setup()
{
  pinMode(1,OUTPUT);
  pinMode(1,OUTPUT);
  pinMode(1,OUTPUT);
  pinMode(1,OUTPUT);
  pinMode(1,OUTPUT);
  pinMode(1,OUTPUT);
}

void loop()
{
    // TODO: Readings from sensor
    float amplitude = 9;
    float wavelength = 20;
    float wavespeed = 5;

    // target
    float h = feature(x,y,wave_delta,wavespeed,amplitude,wavelength);
    float dx = feature(x+1, y,wave_delta,wavespeed,amplitude,wavelength) - feature(x-1, y,wave_delta,wavespeed,amplitude,wavelength);
    float dy = feature(x, y+1,wave_delta,wavespeed,amplitude,wavelength) - feature(x, y-1,wave_delta,wavespeed,amplitude,wavelength);
    float dz = h - z;

    // set default value
    float motor_speed = step_size / (dz * 10 / delta) / 2.0;
    float direction = HIGH;
    float displacement = 0;
    float nPulse = 0;
    float engine = HIGH;

    // set direction
    if(motor_speed < 0) 
        direction = LOW;
    
    // set and limit step period between (500, 800)
    motor_speed = range(abs(motor_speed), speed_max, speed_min);
    // calculate number of pulses needed for 1 frame
    nPulse = floor(delta / 2.0 / motor_speed);
    // calculate expected displacement
    displacement = nPulse * step_size; // unit mm

    // no movement for tiny displacement
    if(displacement > abs(dz) * 10) {
        engine = LOW;
        displacement = 0;
    }

    // set unit of displacement to cm
    displacement *= 0.1;

    // update new finishing z-index
    z = direction ? z + displacement : z - displacement; 

    // Operating
    // Set Direction
    digitalWrite(4,direction);
    delayMicroseconds(10000);
    // Start engine
    digitalWrite(2,engine);
    // Sending Pulses
    for(int i = 0; i < nPulse; ++i) {
        digitalWrite(13,HIGH);
        delayMicroseconds(motor_speed);
        digitalWrite(13,LOW);
        delayMicroseconds(motor_speed);
    }
    // Stop Engine
    digitalWrite(2, LOW);
    // Filling gap with delay to match frame size
    delayMicroseconds(delta - nPulse * motor_speed * 2);
    
    printf("Hight = %f, h = %f, dist = %f, dir = %f, speed = %f\n",z,h,displacement,direction,motor_speed);

    wave_delta += delta / 1000000;
}

int main()
{
    setup();
    while(1) {
        loop();
    }

    return 0;
}