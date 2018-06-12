//
//  WinKeyerConstants.h
//
//  Created by Willard Myers on 2008.11.20.
//  Copyright 2008 K1GQ. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Commands
extern const uint8 kWKAdminCalibrateCommand[2];
extern const uint8 kWKAdminResetCommand[2];
extern const uint8 kWKAdminHostOpenCommand[2];
extern const uint8 kWKAdminHostCloseCommand[2];
extern const uint8 kWKAdminEchoTestCommand[3];
extern const uint8 kWKAdminPaddleA2DCommand[2];
extern const uint8 kWKAdminSpeedA2DCommand[2];
extern const uint8 kWKAdminGetValuesCommands[2];
extern const uint8 kWKAdminReservedCommand[2];
extern const uint8 kWKAdminGetCalCommand[2];
extern const uint8 kWKAdminGetMajorVersionCommand[2];
extern const uint8 kWKAdminSetWK1ModeCommand[2];
extern const uint8 kWKAdminSetWK2ModeCommand[2];
extern const uint8 kWKAdminReadEEPROMCommand[2];
extern const uint8 kWKAdminWriteEEPROMCommand[2];
extern const uint8 kWKAdminSendStandaloneMessageCommand[2];
extern const uint8 kWKAdminWriteX1MODECommand[2];
extern const uint8 kWKAdminFirmwareUpdateCommand[2];
extern const uint8 kWKAdminSetHighBaudCommand[2];
extern const uint8 kWKAdmitSetLowBaudCommand[2];
extern const uint8 kWKAdminSetK1ELAntennaSwitch[2];
extern const uint8 kWKAdminSetWK3ModeCommand[2];
extern const uint8 kWKAdminReadBackVccCommand[2];
extern const uint8 kWKAdminWriteX2MODECommand[2];
extern const uint8 kWKAdminReadMinorVersionCommand[2];
extern const uint8 kWKAdminGetTypeCommand[2];
extern const uint8 kWKAdminReadExtendedCommand[2];

extern const uint8 kWKImmediateSidetoneControlCommand;
extern const uint8 kWKImmediateSetWPMSpeedCommand;
extern const uint8 kWKImmediateSetWeightingCommand;
extern const uint8 kWKImmediateSetPTTLeadTailCommand;
extern const uint8 kWKImmediateSetupSpeedPotCommand;
extern const uint8 kWKImmediateSetPauseStateCommand;
extern const uint8 kWKImmediateGetSpeedPotCommand; 
extern const uint8 kWKImmediateBackspaceCommand;
extern const uint8 kWKImmediateSetPinConfigurationCommand;
extern const uint8 kWKImmediateClearBufferCommand;
extern const uint8 kWKImmediateKeyImmediateCommand;
extern const uint8 kWKImmediateSetHSCWCommand;
extern const uint8 kWKImmediateSetFarnsworthWPMCommand;
extern const uint8 kWKImmediateSetWinkeyer2ModeCommand;
extern const uint8 kWKImmediateLoadDefaultsCommand;
extern const uint8 kWKImmediateSetFirstExtensionCommand;
extern const uint8 kWKImmediateSetKeyingCompensationCommand;
extern const uint8 kWKImmediateSetPaddleSwitchpointCommand;
extern const uint8 kWKImmediateNullCommand; 
extern const uint8 kWKImmediateSoftwarePaddleCommand;
extern const uint8 kWKImmediateRequestWinKeyer2StatusCommand;
extern const uint8 kWKImmediatePointerCommand;
extern const uint8 kWKImmediateSetDitDahRatioCommand;

extern const uint8 kWKBufferedPTTOnOffCommand;
extern const uint8 kWKBufferedTimedKeyDownCommand;
extern const uint8 kWKBufferedWaitCommand;
extern const uint8 kWKBufferedMergeLettersCommand;
extern const uint8 kWKBufferedChangeSpeedCommand;
extern const uint8 kWKBufferedChangeHSCWCommand;
extern const uint8 kWKBufferedPortSelectCommand;
extern const uint8 kWKBufferedCancelSpeedChangeCommand;
extern const uint8 kWKBufferedNOPCommand;

// String constants
extern NSString* kWKPortNamePrefix;
extern NSString* portNameNone;

// Utilities
extern NSData* byteToData(const uint8 c);
extern NSData* bytesToData(const uint8* c, NSUInteger length);
