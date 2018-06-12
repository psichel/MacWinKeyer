//
//  WinKeyerConstants.m
//
//  Created by Willard Myers on 2008.11.20.
//  Copyright 2008 K1GQ. All rights reserved.
//

#import "WinKeyerConstants.h"

// Host Mode Commands
const uint8 kWKAdminCalibrateCommand[2] = {0x00, 0x00}; // historical
const uint8 kWKAdminResetCommand[2] = {0x00, 0x01};
const uint8 kWKAdminHostOpenCommand[2] = {0x00, 0x02};
const uint8 kWKAdminHostCloseCommand[2] = {0x00, 0x03};
const uint8 kWKAdminEchoTestCommand[3] = {0x00, 0x04, 0x55};
const uint8 kWKAdminPaddleA2DCommand[2] = {0x00, 0x05}; // historical
const uint8 kWKAdminSpeedA2DCommand[2] = {0x00, 0x06}; // historical
const uint8 kWKAdminGetValuesCommands[2] = {0x00, 0x07};
const uint8 kWKAdminReservedCommand[2] = {0x00, 0x08};
const uint8 kWKAdminGetCalCommand[2] = {0x00, 0x09}; // historical
const uint8 kWKAdminGetMajorVersionCommand[2] = {0x00, 0x09}; // undocumented
const uint8 kWKAdminSetWK1ModeCommand[2] = {0x00, 10};
const uint8 kWKAdminSetWK2ModeCommand[2] = {0x00, 11};
const uint8 kWKAdminReadEEPROMCommand[2] = {0x00, 12};
const uint8 kWKAdminWriteEEPROMCommand[2] = {0x00, 13};
const uint8 kWKAdminSendStandaloneMessageCommand[2] = {0x00, 14}; // <nn> 1 <= nn <= 6
const uint8 kWKAdminWriteX1MODECommand[2] = {0x00, 15}; // <nn> extension mode register 1
const uint8 kWKAdminFirmwareUpdateCommand[2] = {0x00, 16};
const uint8 kWKAdminSetHighBaudCommand[2] = {0x00, 17};
const uint8 kWKAdmitSetLowBaudCommand[2] = {0x00, 18};
const uint8 kWKAdminSetK1ELAntennaSwitch[2] = {0x00, 19};
const uint8 kWKAdminSetWK3ModeCommand[2] = {0x00, 20};
const uint8 kWKAdminReadBackVccCommand[2] = {0x00, 21};
const uint8 kWKAdminWriteX2MODECommand[2] = {0x00, 22}; // <nn> extension mode register 2
const uint8 kWKAdminReadMinorVersionCommand[2] = {0x00, 23}; // undocumented
const uint8 kWKAdminGetTypeCommand[2] = {0x00, 24}; // undocumented
const uint8 kWKAdminReadExtendedCommand[2] = {0x00, 25}; // undocumented

const uint8 kWKImmediateSidetoneControlCommand = 0x01; // <nn> KWKSidetoneControl...
const uint8 kWKImmediateSetWPMSpeedCommand = 0x02; // <nn> 5 <= nn <= 99
const uint8 kWKImmediateSetWeightingCommand = 0x03; // <nn> 10 <= nn <= 90
const uint8 kWKImmediateSetPTTLeadTailCommand = 0x04; // <nn><nn> 0 <= nn/10 << 250
const uint8 kWKImmediateSetupSpeedPotCommand = 0x05; // <nn>,nn>,<nn> 5 <= nn <= 99
const uint8 kWKImmediateSetPauseStateCommand = 0x06; // <nn> nn = [0 | 1]
const uint8 kWKImmediateGetSpeedPotCommand = 0x07; 
const uint8 kWKImmediateBackspaceCommand = 0x08;
const uint8 kWKImmediateSetPinConfigurationCommand = 0x09; // <nn> kWKPinConfiguration...
const uint8 kWKImmediateClearBufferCommand = 0x0A;
const uint8 kWKImmediateKeyImmediateCommand = 0x0B; // <nn> nn = [0 | 1]
const uint8 kWKImmediateSetHSCWCommand = 0x0C; // <nn> nn = lpm/100, 1000 <= lpm <= 8000
const uint8 kWKImmediateSetFarnsworthWPMCommand = 0x0D; // <nn> 10 <= nn <= 99
const uint8 kWKImmediateSetWinkeyer2ModeCommand = 0x0E; // <nn> kWKWinKeyer2Mode...
const uint8 kWKImmediateLoadDefaultsCommand = 0x0F; // <nn>...<nn> 15 bytes
const uint8 kWKImmediateSetFirstExtensionCommand = 0x10; // <nn> 0 <= nn <= 250
const uint8 kWKImmediateSetKeyingCompensationCommand = 0x11; // <nn> 0 <= nn <= 250
const uint8 kWKImmediateSetPaddleSwitchpointCommand = 0x12; // <nn> 10 <= nn <= 90
const uint8 kWKImmediateNullCommand = 0x13; 
const uint8 kWKImmediateSoftwarePaddleCommand = 0x14; // <nn> nn = [0 | 1 | 2 | 3]
const uint8 kWKImmediateRequestWinKeyer2StatusCommand = 0x15;
const uint8 kWKImmediatePointerCommand = 0x16; // <nn> nn = [0 | 1 | 2 | 3]
const uint8 kWKImmediateSetDitDahRatioCommand = 0x17; // <nn> 33 <= nn <= 66

const uint8 kWKBufferedPTTOnOffCommand = 0x18; // <nn> nn = [0 | 1]
const uint8 kWKBufferedTimedKeyDownCommand = 0x19; // <nn>  0 <= nn <= 99
const uint8 kWKBufferedWaitCommand = 0x1A; // <nn>  0 <= nn <= 99
const uint8 kWKBufferedMergeLettersCommand = 0x1B; // <c><c>
const uint8 kWKBufferedChangeSpeedCommand = 0x1C; // <nn> 5 <= nn <= 99
const uint8 kWKBufferedChangeHSCWCommand = 0x1D; // <nn> nn = lpm/100 1000 <= lpm <= 8000
const uint8 kWKBufferedPortSelectCommand = 0x1D; // <nn> nn == [0 | 1]
const uint8 kWKBufferedCancelSpeedChangeCommand = 0x1E;
const uint8 kWKBufferedNOPCommand = 0x1F;

NSString* kWKPortNamePrefix = @"usbserial-";
NSString* portNameNone = @"No Value";

NSData* byteToData(const uint8 c)
{
    return [NSData dataWithBytes:&c length:1];
}

NSData* bytesToData(const uint8* c, NSUInteger length)
{
    return [NSData dataWithBytes:c length:length];
}


