#include <Wire.h>
#define cbi(sfr, bit) _SFR_BYTE(sfr) &= ~_BV(bit)
#define sbi(sfr, bit) _SFR_BYTE(sfr) |= _BV(bit)

void setup()
{
	Serial.begin(115200);
}

void twi_close()
{
	// de-activate internal pull-up resistors
	cbi(PORTD, 0);
	cbi(PORTD, 1);
	sbi(TWSR, TWPS0);
	sbi(TWSR, TWPS1);
	sbi(TWCR,TWINT);
	sbi(TWCR,TWSTO);
	cbi(TWCR,TWEA);
	cbi(TWCR,TWSTA);
	cbi(TWCR,TWWC);
	sbi(TWCR,TWEN);
	cbi(TWCR,TWIE);
	//cbi(PRR0,PRTWI);
}

void bootup()
{
	if(analogRead(0) > 512) {
		Wire.begin();
		Serial.write((uint8_t)0);
		return;
	}
	pinMode(A4, OUTPUT);
	digitalWrite(A4, LOW); 
	pinMode(A5, OUTPUT);
	digitalWrite(A5, LOW);
	while(analogRead(0) < 512); 
	delay(1000); 
	pinMode(A4, OUTPUT);
	digitalWrite(A4, HIGH);
	pinMode(A5, OUTPUT);
	digitalWrite(A5, HIGH);
	Wire.begin();
	Serial.write((uint8_t)0);
}

void shutdown() {
	//twi_close();
}

void loop() {
	int i, device, dir, amount_read, msg_size, msg[100];
	bootup();
	while(analogRead(0) > 512) {
		amount_read = 0;
		while(!Serial.available() > 0);
		device = Serial.read();
		while(!Serial.available() > 0);
		dir = Serial.read();
		while(!Serial.available() > 0);
		msg_size = Serial.read();
		if(dir == 0) {
			while(msg_size > amount_read) {
				while(!Serial.available() > 0);
				msg[amount_read] = Serial.read();
				amount_read++;   
			}
			Wire.beginTransmission(device);
			for(i = 0; i < msg_size; ++i) {
				Wire.send(msg[i]);
			}
			Serial.println((int)Wire.endTransmission());
		}
		else {
			Wire.requestFrom(device, msg_size);
			while(Wire.available() < msg_size);
			Serial.write((uint8_t)0);
			for(i = 0; i < msg_size; ++i) {
				Serial.write(Wire.receive());
			}
		}
	}
	shutdown();
}