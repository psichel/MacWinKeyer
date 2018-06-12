//
//  WinKeyerRegisters.h
//  MacWinKeyer
//
//  Created by Willard Myers on 2015-03-08.
//
//

#ifndef MacWinKeyer_WinKeyerRegisters_h
#define MacWinKeyer_WinKeyerRegisters_h

uint8 encodeModeRegisterFromDict(NSDictionary* preferences);
void decodeModeRegisterIntoDict(uint8 modeRegister, NSMutableDictionary* preferences);

uint8 encodeWK2SidetoneRegisterFromDict(NSDictionary* preferences);
void decodeWK2SidetoneRegisterIntoDict(uint8 sidetoneRegister, NSMutableDictionary* preferences);

uint8 encodeWK3SidetoneRegisterFromDict(NSDictionary* preferences);
void decodeWK3SidetoneRegisterIntoDict(uint8 sidetoneRegister, NSMutableDictionary* preferences);

uint8 encodePinConfigurationRegisterFromDict(NSDictionary* preferences);
void decodePinConfigurationRegisterIntoDict(uint8 pinConfigurationRegister, NSMutableDictionary* preferences);

uint8 encodeWK2Extension1RegisterFromDict(NSDictionary* preferences);
void decodeWK2Extension1RegisterIntoDict(uint8 extensionRegister, NSMutableDictionary* preferences);

uint8 encodeWK3Extension1RegisterFromDict(NSDictionary* preferences);
void decodeWK3Extension1RegisterIntoDict(uint8 extensionRegister, NSMutableDictionary* preferences);

uint8 encodeExtension2RegisterFromDict(NSDictionary* preferences);
void decodeExtension2RegisterIntoDict(uint8 extensionRegister, NSMutableDictionary* preferences);

#endif
