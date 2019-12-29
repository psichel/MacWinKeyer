//
//  WK24MacAppDelegate.m
//  WK24Mac
//
//  Created by James  T. Rogers on 4/11/11.
//  Copyright 2011 Jim Rogers, W4ATK. All rights reserved.
//

#import "MacWinKeyer.h"
@import ORSSerial;
#import "StandaloneSettings.h"
#import "WinKeyerConstants.h"
#import "WinKeyerRegisters.h"
#import "Preferences.h"

#pragma mark - TODO

// Echo doesn't appear until after first esc (Clear)
// Can't edit keyboard input -- no type-ahead?

#pragma mark - Initialization

@implementation MacWinKeyer

- (instancetype)init
{
	self = [super init];
	if (self) {
        self.version2 = YES; // default for hidden bindings
        self.version3 = !self.version2;
        [NSApp activateIgnoringOtherApps:YES];
        [self addObserver:self forKeyPath:@"keyboardBufferString" options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}


- (void)awakeFromNib
{
    self.keyboardBufferString = @"";
    self.paddleEchoString = @"";
    self.versionString = @"";
    self.portOpenCloseButtonTitle = @"Open Port";
    [self changeStatusString];
}

- (void)changeStatusString
{
    self.statusGumdropImage = [NSImage imageNamed:NSImageNameStatusUnavailable];
    if (self.winkeyerPort.isOpen) {
        self.statusString = [@"" stringByAppendingString:self.versionString];
        if (self.isHostMode) {
            self.statusString = [self.statusString stringByAppendingString:@" Host Mode"];
            self.statusGumdropImage = [NSImage imageNamed:NSImageNameStatusAvailable];
        } else {
            self.statusString = [self.statusString stringByAppendingString:@" Standalone Mode"];
        }
    } else {
        self.statusString = @"";
        self.versionString = @"";
    }
}

- (void)insertInput:(NSString *)string
{
    static const NSInteger displayLength = 60L;
    self.paddleEchoString = [self.paddleEchoString stringByAppendingString:string];
    if (self.paddleEchoString.length > displayLength) {
        self.paddleEchoString = [self.paddleEchoString substringFromIndex:(self.paddleEchoString.length - displayLength)];
    }
}

- (void)sendMessage:(NSUInteger)buttonID
{
    NSString* message = nil;
    NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:hostSettingsKeyPath];
    switch (buttonID) {
        case 1: message = [preferences[Message1] uppercaseString]; break;
        case 2: message = [preferences[Message2] uppercaseString]; break;
        case 3: message = [preferences[Message3] uppercaseString]; break;
        case 4: message = [preferences[Message4] uppercaseString]; break;
        default: break;
    }
    if (message) {
        [self sendAsciiString:message];
    }
}

- (void)loadDefaults {
    NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:hostSettingsKeyPath];
    uint8 defaults[16];
    defaults[0] = kWKImmediateLoadDefaultsCommand;
    defaults[1] = encodeModeRegisterFromDict(preferences);
    if (preferences[SpeedPotLock]) {
        defaults[2] = 0;
    } else {
        defaults[2] = [preferences[SpeedCommanded] integerValue];
    }
    if (self.version2) {
        defaults[3] = encodeWK2SidetoneRegisterFromDict(preferences);
    } else {
        defaults[3] = encodeWK3SidetoneRegisterFromDict(preferences);
    }
    defaults[4] = [preferences[KeyWeight] integerValue];
    defaults[5] = [preferences[PushToTalkLeadDelay] integerValue];
    defaults[6] = [preferences[PushToTalkTailDelay] integerValue];
    defaults[7] = [preferences[SpeedMinimum] integerValue];
    defaults[8] = [preferences[SpeedRange] integerValue];
    if (self.isVersion2) {
        defaults[9] = [preferences[KeyFirstExtension] integerValue];
    } else {
        defaults[9] = encodeExtension2RegisterFromDict(preferences);
    }
    defaults[10] = [preferences[KeyCompensation] integerValue];
    defaults[11] = [preferences[SpeedFarnsworth] integerValue];
    defaults[12] = [preferences[PaddleSwitchpoint] integerValue];
    defaults[13] = [preferences[KeyRatio] integerValue];
    defaults[14] = encodePinConfigurationRegisterFromDict(preferences);
    if (self.isVersion2) {
        defaults[15] = 0x00;
    } else {
        defaults[15] = encodeWK3Extension1RegisterFromDict(preferences);
    }
    [self.winkeyerPort sendData:bytesToData(defaults, 16)];
}

#pragma mark - NSApplicationDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
//    [SUUpdater sharedUpdater].automaticallyChecksForUpdates = NO;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.serialPortManager = [ORSSerialPortManager sharedSerialPortManager];
    
    NSString* portName = [[NSUserDefaults standardUserDefaults] stringForKey:winKeyerPortNamePreferenceKey];
    NSArray* allPorts = [ORSSerialPortManager sharedSerialPortManager].availablePorts;
    for (ORSSerialPort* port in allPorts) {
        if ([port.name isEqualToString:portName]) {
            self.winkeyerPort = port;
            [self openOrCloseWinKeyer:self];
            break;
        }
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *)sender
{
    self.terminating = YES;

    [self closePort];
    
    // quit now!
	return NSTerminateNow;
}

#pragma mark - WinKeyer Admin functions

- (void)openHostMode
{
    if (self.isHostMode) return;
    ORSSerialPacketDescriptor* descriptor = [[ORSSerialPacketDescriptor alloc] initWithMaximumPacketLength:1
                                                                                                  userInfo:nil
                                                                                         responseEvaluator:^BOOL(NSData* inputData) {
                                                                                             if (inputData.length == 0) return NO;
                                                                                             return YES;
                                                                                         }];
    NSDictionary* userInfo = @{@"CommandName": @"HostOpen"};
    ORSSerialRequest* request = [ORSSerialRequest requestWithDataToSend:bytesToData(kWKAdminHostOpenCommand, 2)
                                                               userInfo:userInfo
                                                        timeoutInterval:10.0
                                                     responseDescriptor:descriptor];
    [self.winkeyerPort sendRequest:request];
}

- (void)readMinorVersion
{
    ORSSerialPacketDescriptor* descriptor = [[ORSSerialPacketDescriptor alloc] initWithMaximumPacketLength:1
                                                                                                  userInfo:nil
                                                                                         responseEvaluator:^BOOL(NSData* inputData) {
                                                                                             if (inputData.length == 0) return NO;
                                                                                             return YES;
                                                                                         }];
    NSDictionary* userInfo = @{@"CommandName": @"ReadMinorVersion"};
    ORSSerialRequest* request = [ORSSerialRequest requestWithDataToSend:bytesToData(kWKAdminReadMinorVersionCommand, 2)
                                                               userInfo:userInfo
                                                        timeoutInterval:10.0
                                                     responseDescriptor:descriptor];
    [self.winkeyerPort sendRequest:request];
}

- (void)readType
{
    ORSSerialPacketDescriptor* descriptor = [[ORSSerialPacketDescriptor alloc] initWithMaximumPacketLength:1
                                                                                                  userInfo:nil
                                                                                         responseEvaluator:^BOOL(NSData* inputData) {
                                                                                             if (inputData.length == 0) return NO;
                                                                                             return YES;
                                                                                         }];
    NSDictionary* userInfo = @{@"CommandName": @"ReadType"};
    ORSSerialRequest* request = [ORSSerialRequest requestWithDataToSend:bytesToData(kWKAdminGetTypeCommand, 2)
                                                               userInfo:userInfo
                                                        timeoutInterval:10.0
                                                     responseDescriptor:descriptor];
    [self.winkeyerPort sendRequest:request];
}

- (void)echoTest
{
    _suppressEchoTestCharacterDisplay = YES;
    NSDictionary* userInfo = @{@"CommandName": @"EchoTest"};
    ORSSerialPacketDescriptor* descriptor = [[ORSSerialPacketDescriptor alloc] initWithMaximumPacketLength:1
                                                                                                  userInfo:nil
                                                                                         responseEvaluator:^BOOL(NSData* inputData) {
                                                                                             if (inputData.length != 1) return NO;
                                                                                             uint8* echo = (uint8*)(inputData.bytes);
                                                                                             if (echo[0] != 0x55) return NO;
                                                                                             return YES;
                                                                                         }];
    ORSSerialRequest* request = [ORSSerialRequest requestWithDataToSend:bytesToData(kWKAdminEchoTestCommand, 3)
                                                               userInfo:userInfo
                                                        timeoutInterval:4.0
                                                     responseDescriptor:descriptor];
    [self.winkeyerPort sendRequest:request];
}

- (void)closeHostMode
{
    if (!self.isHostMode) return;
    [self.winkeyerPort sendData:bytesToData(kWKAdminHostCloseCommand, 2)];
    self.hostMode = NO;
    [self changeStatusString];
}

#pragma mark - Actions

- (IBAction)openWebSite:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://k1el.tripod.com/DocsC.html"]];
}

- (IBAction)sendMessage1:(id)sender {
    NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:hostSettingsKeyPath];
    NSString* message = [preferences[Message1] uppercaseString];
    [self sendAsciiString:message];
}

- (IBAction)sendMessage2:(id)sender {
    NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:hostSettingsKeyPath];
    NSString* message = [preferences[Message2] uppercaseString];
    [self sendAsciiString:message];
}

- (IBAction)sendMessage3:(id)sender {
    NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:hostSettingsKeyPath];
    NSString* message = [preferences[Message3] uppercaseString];
    [self sendAsciiString:message];
}

- (IBAction)sendMessage4:(id)sender {
    NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:hostSettingsKeyPath];
    NSString* message = [preferences[Message4] uppercaseString];
    [self sendAsciiString:message];
}

- (IBAction)sendMessage5:(id)sender {
    NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:hostSettingsKeyPath];
    NSString* message = [preferences[Message5] uppercaseString];
    [self sendAsciiString:message];
}

- (IBAction)sendMessage6:(id)sender {
    NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:hostSettingsKeyPath];
    NSString* message = [preferences[Message6] uppercaseString];
    [self sendAsciiString:message];
}

- (IBAction)clearKeyboardBuffer:(id)sender	// stops sending immediately. clears the chips buffer.
{
    self.keyboardBufferString = @"";
	_keyboardBufferCharacterIndex = 0;
    const uint8 command[2] = {kWKImmediateClearBufferCommand, kWKImmediateRequestWinKeyer2StatusCommand};
    [self.winkeyerPort sendData:bytesToData(command, 2)];
    self.paddleEchoString = @"";
}

- (IBAction)tune:(id)sender
{
    BOOL isOn = ([sender state] == NSOnState);
    const uint8 command[2] = {kWKImmediateKeyImmediateCommand, (isOn ? 0x01 : 0x00)};
	[self.winkeyerPort sendData:bytesToData(command, 2)];
}

- (IBAction)pause:(id)sender {				//toggle - pause immediate.
    BOOL isOn = ([sender state] == NSOnState);
    const uint8 command[2] = {kWKImmediateSetPauseStateCommand, (isOn ? 0x01 : 0x00)};
    [self.winkeyerPort sendData:bytesToData(command, 2)];
}

- (IBAction)togglePotLock:(id)sender
{
    NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:hostSettingsKeyPath];
    BOOL isPotLock = [preferences[SpeedPotLock] boolValue];
    uint8 speed = 0x00;
    if (!isPotLock) {
        speed = [preferences[SpeedCommanded] integerValue];
    }
    const uint8 command[2] = {kWKImmediateSetWPMSpeedCommand, speed};
    [self.winkeyerPort sendData:bytesToData(command, 2)];
}

// Action not sent when Pot Lock is true (UI disabled)
- (IBAction)changeSpeed:(id)sender
{
    NSInteger speed = [sender integerValue];
    NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:hostSettingsKeyPath];
    if (speed != 0) {
        NSInteger minWPMSpeed =[preferences[SpeedMinimum] integerValue];
        NSInteger maxWPMRange = [preferences[SpeedRange] integerValue];
        speed = (speed < minWPMSpeed ? minWPMSpeed : speed);
        speed = (speed > minWPMSpeed + maxWPMRange ? minWPMSpeed + maxWPMRange : speed);
    }
    self.currentSpeed = speed;
    NSMutableDictionary* newPreferences = [NSMutableDictionary dictionaryWithDictionary:preferences];
    newPreferences[SpeedCommanded] = @(self.currentSpeed);
    [[NSUserDefaults standardUserDefaults] setObject:newPreferences forKey:hostSettingsKeyPath];
    const uint8 command[2] = {kWKImmediateSetWPMSpeedCommand, (uint8)self.currentSpeed};
    [self.winkeyerPort sendData:bytesToData(command, 2)];
}

- (IBAction)changeFavoriteSpeed:(id)sender
{
//TODO    NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:hostSettingsKeyPath];
//TODO    NSInteger speed = [preferences[SpeedFavorite] integerValue];
}

- (IBAction)openOrCloseWinKeyer:(id)sender
{
    if (self.winkeyerPort.isOpen) {
        [self closePort];
    } else {
        self.winkeyerPort.baudRate = @(B1200);
        self.winkeyerPort.parity = ORSSerialPortParityNone;
        self.winkeyerPort.numberOfStopBits = 1;
        self.winkeyerPort.delegate = self;
        self.winkeyerPort.DTR = YES;
        self.winkeyerPort.RTS = NO;
        [self.winkeyerPort open];
        if (self.winkeyerPort.isOpen) {
            [self sendAsciiString:@"\r\r\r\r"];
            [self changeStatusString];
            self.portOpenCloseButtonTitle = @"Close Port";
            [[NSUserDefaults standardUserDefaults] setObject:self.winkeyerPort.name forKey:winKeyerPortNamePreferenceKey];
            [self openHostMode];
        } else {
            [self changeStatusString];
        }
    }
}

- (IBAction)changeRatio:(id)sender
{
    NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:hostSettingsKeyPath];
    uint8 ratio = [preferences[KeyRatio] integerValue];
    const uint8 command[2] = {kWKImmediateSetDitDahRatioCommand, ratio};
    [self.winkeyerPort sendData:bytesToData(command, 2)];
}

- (IBAction)changeWeight:(id)sender
{
    NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:hostSettingsKeyPath];
    uint8 weight = [preferences[KeyWeight] integerValue];
    const uint8 command[2] = {kWKImmediateSetWeightingCommand, weight};
    [self.winkeyerPort sendData:bytesToData(command, 2)];
}

- (IBAction)changeKeyingCompensation:(id)sender
{
    NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:hostSettingsKeyPath];
    uint8 compensation = [preferences[KeyCompensation] integerValue];
    const uint8 command[2] = {kWKImmediateSetKeyingCompensationCommand, compensation};
    [self.winkeyerPort sendData:bytesToData(command, 2)];
}

- (IBAction)changePTT:(id)sender
{
    NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:hostSettingsKeyPath];
    uint8 pttLeadTime = [preferences[PushToTalkLeadDelay] integerValue];
    uint8 pttTailTime = [preferences[PushToTalkTailDelay] integerValue];
    const uint8 command[3] = {kWKImmediateSetPTTLeadTailCommand, pttLeadTime, pttTailTime};
    [self.winkeyerPort sendData:bytesToData(command, 3)];
}

- (IBAction)changeFirstExtension:(id)sender
{
    NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:hostSettingsKeyPath];
    uint8 firstExtension = [preferences[KeyFirstExtension] integerValue];
    const uint8 command[2] = {kWKImmediateSetFirstExtensionCommand, firstExtension};
    [self.winkeyerPort sendData:bytesToData(command, 2)];
}

- (IBAction)changeFarnsworthSpeed:(id)sender
{
    NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:hostSettingsKeyPath];
    uint8 farnsworthSpeed = [preferences[SpeedFarnsworth] integerValue];
    const uint8 command[2] = {kWKImmediateSetFarnsworthWPMCommand, farnsworthSpeed};
    [self.winkeyerPort sendData:bytesToData(command, 2)];
}

- (IBAction)changePaddleSwitchpoint:(id)sender
{
    NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:hostSettingsKeyPath];
    BOOL disablePaddleMemory = [preferences[PaddleDisableDitDahMemory] boolValue];
    if (disablePaddleMemory) {
        const uint8 command[2] = {kWKImmediateSetPaddleSwitchpointCommand, 0x00};
        [self.winkeyerPort sendData:bytesToData(command, 2)];
    } else {
        uint8 switchPoint = [preferences[PaddleSwitchpoint] unsignedCharValue];
        const uint8 command[2] = {kWKImmediateSetPaddleSwitchpointCommand, switchPoint};
        [self.winkeyerPort sendData:bytesToData(command, 2)];
    }
}

- (IBAction)changePinConfiguration:(id)sender
{
    NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:hostSettingsKeyPath];
    uint8 pinConfigurationRegister = encodePinConfigurationRegisterFromDict(preferences);
    const uint8 command[2] = {kWKImmediateSetPinConfigurationCommand, pinConfigurationRegister};
    [self.winkeyerPort sendData:bytesToData(command, 2)];
}

- (IBAction)changeModeRegister:(id)sender
{
    NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:hostSettingsKeyPath];
    uint8 modeRegister = encodeModeRegisterFromDict(preferences);
    const uint8 command[2] = {kWKImmediateSetWinkeyer2ModeCommand, modeRegister};
    [self.winkeyerPort sendData:bytesToData(command, 2)];
}

- (IBAction)changeExtensionRegister1:(id)sender
{
    NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:hostSettingsKeyPath];
    uint8 extensionRegister = 0x00;
    if (self.isVersion2) {
        extensionRegister = encodeWK2Extension1RegisterFromDict(preferences);
    } else {
        extensionRegister = encodeWK3Extension1RegisterFromDict(preferences);
    }
    const uint8 command[3] = {kWKAdminWriteX1MODECommand[0], kWKAdminWriteX1MODECommand[1], extensionRegister};
    [self.winkeyerPort sendData:bytesToData(command, 3)];
}

- (IBAction)changeExtensionRegister2:(id)sender
{
    if (self.version3) {
        NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:hostSettingsKeyPath];
        uint8 extensionRegister = encodeExtension2RegisterFromDict(preferences);
        const uint8 command[3] = {kWKAdminWriteX2MODECommand[0], kWKAdminWriteX2MODECommand[1], extensionRegister};
        [self.winkeyerPort sendData:bytesToData(command, 3)];
    }
}

- (IBAction)changeSidetone:(id)sender
{
    NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:hostSettingsKeyPath];
    uint8 sidetoneRegister = 0x00;
    if (self.isVersion2) {
        sidetoneRegister = encodeWK2SidetoneRegisterFromDict(preferences);
    } else {
        sidetoneRegister = encodeWK3SidetoneRegisterFromDict(preferences);
    }
    const uint8 command[2] = {kWKImmediateSidetoneControlCommand, sidetoneRegister};
    [self.winkeyerPort sendData:bytesToData(command, 2)];
    if (self.isVersion3) {
        uint8 extensionRegister = encodeExtension2RegisterFromDict(preferences);
        const uint8 adminCommand[3] = {kWKAdminWriteX2MODECommand[0], kWKAdminWriteX2MODECommand[1], extensionRegister};
        [self.winkeyerPort sendData:bytesToData(adminCommand, 3)];
    }
}

- (IBAction)changeSpeedPot:(id)sender
{
    NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:hostSettingsKeyPath];
    NSUInteger speedMinimum = [preferences[SpeedMinimum] integerValue]; // Between 5 and 94
    NSUInteger speedMaximum = [preferences[SpeedMaximum] integerValue]; // Between 10 and 99
    if (speedMaximum < speedMinimum + 5) {
        speedMaximum = speedMinimum + 5;
        NSMutableDictionary* newPreferences = [NSMutableDictionary dictionaryWithDictionary:preferences];
        newPreferences[SpeedMaximum] = @(speedMaximum);
        [[NSUserDefaults standardUserDefaults] setObject:newPreferences forKey:hostSettingsKeyPath];
    }
    
    NSUInteger speedRange = speedMaximum - speedMinimum;
    NSUInteger potRange = [preferences[SpeedRange] integerValue];
    if (potRange != speedRange) {
        NSMutableDictionary* newPreferences = [NSMutableDictionary dictionaryWithDictionary:preferences];
        newPreferences[SpeedRange] = @(speedRange);
        [[NSUserDefaults standardUserDefaults] setObject:newPreferences forKey:hostSettingsKeyPath];
    }
    
    const uint8 command[4] = {kWKImmediateSetupSpeedPotCommand, (uint8)speedMinimum, (uint8)speedRange, 0x00};
    [self.winkeyerPort sendData:bytesToData(command, 4)];
    // Turn on pot lock to cause speed update
    const uint8 potLockCommand[2] = {kWKImmediateSetWPMSpeedCommand, 0x00};
    [self.winkeyerPort sendData:bytesToData(potLockCommand, 2)];
    // Request speed, response will turn pot lock off if it was on
    [self.winkeyerPort sendData:byteToData(kWKImmediateGetSpeedPotCommand)];
}

// Disabled when no serial port, works with Host Mode open
- (IBAction)playStandaloneMessage:(id)sender
{
    uint8 messageID = [sender tag];
    messageID = (messageID < 1 ? 1 : messageID);
    if (self.isVersion2) {
        messageID = (messageID > 6 ? 6 : messageID);
    } else {
        BOOL useMessageBankOne = NO;
        if (messageID > 6) {
            useMessageBankOne = YES;
            messageID -= 6;
        }
        messageID = (messageID > 6 ? 6 : messageID);
        NSDictionary* preferences;
        if (useMessageBankOne) {
            preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:standaloneSettings1KeyPath];
        } else {
            preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:standaloneSettings0KeyPath];
        }
        uint8 extensionRegister1 = encodeWK3Extension1RegisterFromDict(preferences);
        extensionRegister1 &= 0x3F; // Turn off user 1 and message bank 1
        if (useMessageBankOne) extensionRegister1 |= 0xC0; // Turn on user 1 and message bank 1
        const uint8 command[7] = {'\r', '\r', '\r', '\r', kWKAdminWriteX1MODECommand[0], kWKAdminWriteX1MODECommand[1], extensionRegister1};
        [self.winkeyerPort sendData:bytesToData(command, 7)];
    }
    const uint8 command[7] = {'\r', '\r', '\r', '\r', kWKAdminSendStandaloneMessageCommand[0], kWKAdminSendStandaloneMessageCommand[1], messageID};
    [self.winkeyerPort sendData:bytesToData(command, 7)];
}

- (IBAction)writeEeprom:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (!self.winkeyerPort.isOpen) return;
    const uint8 command[6] = {'\r', '\r', '\r', '\r', kWKAdminWriteEEPROMCommand[0], kWKAdminWriteEEPROMCommand[1]};
    NSMutableData* dataToSend = [NSMutableData dataWithData:bytesToData(command, 6)];
    if (self.isVersion2) {
        [_busyReadWriteProgressWK2 startAnimation:self];
        [dataToSend appendData:[_standaloneSettings wk2EepromData]];
    } else if (self.isVersion3) {
        [_busyReadWriteProgressWK3 startAnimation:self];
        [dataToSend appendData:[_standaloneSettings wk3EepromData]];
    } else {
        ; //TODO
    }
    // Main loop so that progress indicator animates
    [self performSelectorOnMainThread:@selector(closeHostModeAndSendData:) withObject:dataToSend waitUntilDone:YES];
    // WK needs time to digest eeprom before we can reopen Host Mode
    [self performSelector:@selector(reopenHostMode) withObject:nil afterDelay:5];
}

- (void)closeHostModeAndSendData:(NSData*)dataToSend
{
    [self closeHostMode];
    NSLog(@"%s send of %ld bytes started at %@", __PRETTY_FUNCTION__, dataToSend.length, [NSDate date]);
    [self.winkeyerPort sendData:dataToSend];
    NSLog(@"%s send ended at %@", __PRETTY_FUNCTION__, [NSDate date]);
}

- (void)reopenHostMode
{
    [self openHostMode];
    [_busyReadWriteProgressWK2 stopAnimation:self];
    [_busyReadWriteProgressWK3 stopAnimation:self];
}

- (IBAction)readEeprom:(id)sender
{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (!self.winkeyerPort.isOpen) return;
    NSDictionary* userInfo = nil;
    NSUInteger bytesToRead = 0;
    if (self.isVersion2) {
        [_busyReadWriteProgressWK2 startAnimation:self];
        userInfo = @{@"CommandName": @"ReadWK2EEPROM"};
        bytesToRead = 256;
    } else {
        [_busyReadWriteProgressWK3 startAnimation:self];
        userInfo = @{@"CommandName": @"ReadWK3EEPROM"};
        bytesToRead = 32 + 256;
    }
    [self closeHostMode];
    if (userInfo) {
        const uint8 command[6] = {'\r', '\r', '\r', '\r', kWKAdminReadEEPROMCommand[0], kWKAdminReadEEPROMCommand[1]};
        ORSSerialPacketDescriptor* descriptor = [[ORSSerialPacketDescriptor alloc] initWithMaximumPacketLength:bytesToRead
                                                                                                      userInfo:nil responseEvaluator:^BOOL(NSData* inputData) {
                                                                                                          if (inputData.length < bytesToRead) return NO;
                                                                                                          return YES;
                                                                                                      }];
        ORSSerialRequest* request = [ORSSerialRequest requestWithDataToSend:bytesToData(command, 6)
                                                                   userInfo:userInfo
                                                            timeoutInterval:10.0
                                                         responseDescriptor:descriptor];
        [self.winkeyerPort sendRequest:request];
//        NSLog(@"%s request sent at %@ with CommandName = %@", __PRETTY_FUNCTION__, [NSDate date], userInfo[@"CommandName"]);
    }
}

#pragma mark - Properties

- (void)setSerialPort:(ORSSerialPort *)port
{
    if (port != _winkeyerPort)
    {
        [_winkeyerPort close];
        _winkeyerPort.delegate = nil;
        
        _winkeyerPort = port;
        
        _winkeyerPort.delegate = self;
    }
}

#pragma mark - Keyboard text field observer

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if (self.winkeyerPort.isOpen && self.isHostMode) {
        [self sendKeyboardBuffer];
    }
}

- (void)sendKeyboardBuffer
{
    static const NSUInteger maximumToSendLength = 64;
    if (_keyboardBufferCharacterIndex < self.keyboardBufferString.length) {
        NSString* stringToSend = [self.keyboardBufferString substringFromIndex:_keyboardBufferCharacterIndex];     // extract the new data to send
        if (stringToSend.length > maximumToSendLength) {								// max length to WK2 chip
            stringToSend = [stringToSend substringToIndex:maximumToSendLength];
        }
        _keyboardBufferCharacterIndex = _keyboardBufferCharacterIndex + stringToSend.length;
        [self sendAsciiString:stringToSend];
    }
}

#pragma mark - Serial Comm Utilities

- (void)closePort
{
    [self closeHostMode];
    sleep(2); // Give the port time to send the commands
    [self.winkeyerPort close];
    self.portOpenCloseButtonTitle = @"Open Port";
}

- (void)sendAsciiString:(NSString *)string
{
    NSString* remappedString = [self remapString:string];
    NSString* stringToSend = remappedString.uppercaseString;
    NSData* dataToSend = [stringToSend dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
//    NSLog(@"Sending '%@'", dataToSend);
    [self.winkeyerPort sendData:dataToSend];
}

- (NSString*)remapString:(NSString*)string
{
    NSString* remappedString = [string copy];
    NSDictionary* characterMappings = @{@":": @"OS", // Override
                                        @";": @"KR", // Override
                                        @"!": @"KW", // New
                                        @"_": @"UK", // New
                                        @"&": @"AS", // New
                                        @"^": @"FT", // For N9SE
                                        @"]": @"AA", // Prosign
                                        @"`": @"HH", // Prosign
                                        @"{": @"SN", // Prosign
                                        @"}": @"CT"}; // Prosign
    for (NSString* characterToRemap in characterMappings.allKeys) {
        if ([remappedString rangeOfString:characterToRemap].location != NSNotFound) {
            NSString* remappedCharacter = [NSString stringWithFormat:@"%c%@", 0x1B, characterMappings[characterToRemap]];
            remappedString = [remappedString stringByReplacingOccurrencesOfString:characterToRemap withString:remappedCharacter];
        }
    }
    return remappedString;
}

#pragma mark - ORSSerialPortDelegate

- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data
{
//    NSLog(@"%s %@", __PRETTY_FUNCTION__, data);
    if (data.length > 0) {
        for (int i = 0; i < data.length; i++) {
            uint8 v = ((uint8*)data.bytes)[i];
            if (v == 0xFF) {
                ; // NSLog(@"Status : Error");
            } else if ((v & 0xDE) == 0xDE) {
                ; // Dot paddle closed
            } else if ((v & 0xDD) == 0xDD) {
                ; // Dash paddle closed
            } else if ((v & 0xDC) == 0xDC) {
                ; // Paddle released
            } else if ((v & 0xC0) == 0xC0) { // Status byte
                self.statusGumdropImage = [NSImage imageNamed:NSImageNameStatusAvailable];
                if (v & 0x08) { // Pushbutton status
                    NSUInteger buttonID = 0;
                    if (v & 0x01) buttonID = 1;
                    if (v & 0x02) buttonID = 2;
                    if (v & 0x04) buttonID = 3;
                    if (v & 0x10) buttonID = 4;
                    //if (buttonID > 0) NSLog(@"Pushbutton status : Button %ld pressed", buttonID);
                    //else NSLog(@"Pushbutton status : No buttons pressed");
                    [self sendMessage:buttonID];
                } else { // Other status
                    if (v & 0x10) {
                        //NSLog(@"Status : Wait");
                        self.waitState = YES;
                        self.statusGumdropImage = [NSImage imageNamed:NSImageNameStatusUnavailable];
                    } else {
                        //NSLog(@"Status : Not Wait");
                        self.waitState = NO;
                    }
                    if (v & 0x04) {
                        //NSLog(@"Status : Busy");
                        self.busyState = YES;
                        self.statusGumdropImage = [NSImage imageNamed:NSImageNameStatusPartiallyAvailable];
                    } else {
                        //NSLog(@"Status : Not Busy");
                        self.busyState = NO;
                    }
                    if (v & 0x02) {
                        //NSLog(@"Status : Breakin");
                        self.paddleBreakinState = YES;
                    } else {
                        //NSLog(@"Status : Not Breakin");
                        self.paddleBreakinState = NO;
                    }
                    if (v & 0x01) {
                        //NSLog(@"Status : Xoff");
                        self.bufferNearlyFullState = YES;
                        self.statusGumdropImage = [NSImage imageNamed:NSImageNameStatusUnavailable];
                    } else {
                        //NSLog(@"Status : Not Xoff");
                        self.bufferNearlyFullState = NO;
                    }
                    if (!self.waitState && !self.busyState && !self.paddleBreakinState && !self.bufferNearlyFullState) {
                        [self sendKeyboardBuffer];
                    }
                }
            } else if ((v & 0x80) == 0x80) { // Speed pot report
                NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:hostSettingsKeyPath];
                NSInteger speedPotMinimum = [preferences[SpeedMinimum] integerValue];
                self.currentSpeed = (v & 0x3F) + speedPotMinimum;
                // changeSpeedPot may have enabled pot lock mode by setting speed to zero. If the pot lock
                // preference perference isn't set, then disable pot lock mode by setting non-zero speed.
                BOOL isSpeedPotLock = [preferences[SpeedPotLock] boolValue];
                if (!isSpeedPotLock) {
                    const uint8 command[2] = {kWKImmediateSetWPMSpeedCommand, self.currentSpeed};
                    [self.winkeyerPort sendData:bytesToData(command, 2)];
                }
            } else { // Echo byte
                if (!_suppressEchoTestCharacterDisplay) {
                    NSData* echoAsData = byteToData(v);
                    NSString* echoString = [[NSString alloc] initWithData:echoAsData encoding:NSASCIIStringEncoding];
                    NSDictionary* preferences = [[NSUserDefaults standardUserDefaults] dictionaryForKey:hostSettingsKeyPath];
                    BOOL paddleEchoback = [preferences[HostPaddleEchoback] boolValue];
                    if (paddleEchoback && self.paddleBreakinState) {
                        [self insertInput:echoString];
                    }
                    BOOL serialEchoback = [preferences[HostSerialEchoback] boolValue];
                    if (serialEchoback && !self.paddleBreakinState) {
                        [self insertInput:echoString];
                    }
                } else {
                    _suppressEchoTestCharacterDisplay = NO;
                }
            }
        }
    }
}

- (void)serialPort:(ORSSerialPort*)serialPort didReceiveResponse:(NSData*)responseData toRequest:(ORSSerialRequest*)request
{
    NSString* commandName = request.userInfo[@"CommandName"];
//    NSLog(@"%s %@", __PRETTY_FUNCTION__, commandName);
    if ([commandName isEqualToString:@"HostOpen"]) {
        self.version2 = NO;
        self.version3 = NO;
        uint8 versionNumber = ((uint8*)responseData.bytes)[0];
        NSInteger majorVersion = versionNumber / 10;
        NSInteger minorVersion = versionNumber - 10 * majorVersion;
        if (majorVersion >= 3 && majorVersion < 4) {
            self.version3 = YES;
            self.versionString = [NSString stringWithFormat:@"WinKeyer 3 version %1ld.%1ld", majorVersion, minorVersion];
            self.version31 = (minorVersion > 0 ? YES : NO); // Used to disable EEPROM read/write until get new layout specification
            [self readMinorVersion];
        } else if (majorVersion >= 2 && majorVersion < 3) {
            self.version2 = YES;
            self.versionString = [NSString stringWithFormat:@"WinKeyer 2 version %1ld.%1ld", majorVersion, minorVersion];
            [self echoTest];
        } else {
            NSString* errorDescription = [NSString stringWithFormat:@"WinKeyer returned unsupported version: %ld.", majorVersion];
            NSString* errorDetail = @"Confirm that the WinKeyer version is 20 or newer.";
            NSDictionary* errorDict = @{NSLocalizedDescriptionKey: errorDescription, NSLocalizedRecoverySuggestionErrorKey: errorDetail};
            NSError* error = [NSError errorWithDomain:@"com.k1gq.macwinkeyer" code:1 userInfo:errorDict];
            [[NSUserDefaults standardUserDefaults] setObject:portNameNone forKey:winKeyerPortNamePreferenceKey];
            [NSApp presentError:error];
            [self closePort];
            self.versionString = @"";
        }
    } else if ([commandName isEqualToString:@"ReadMinorVersion"]) {
        uint8 versionNumber = ((uint8*)responseData.bytes)[0];
        NSInteger majorVersion = versionNumber / 10;
        NSInteger minorVersion = versionNumber - 10 * majorVersion;
        self.versionString = [self.versionString stringByAppendingFormat:@".%1ld", minorVersion];
        [self readType];
    } else if ([commandName isEqualToString:@"ReadType"]) {
        self.type = ((uint8*)responseData.bytes)[0];
        self.standalone = self.type != WinKeyerTypeMINI; //TODO what about DUO?
        self.versionString = [self.versionString stringByReplacingOccurrencesOfString:@"WinKeyer 3" withString:@"WKmini"];
        [self echoTest];
    } else if ([commandName isEqualToString:@"EchoTest"]) {
        // Contrary to "Winkeyer2 IC v22 Interface and Operation Manual 6/6/2008", the
        // Admin Set WK2 Mode command is not recognized unless set *after* Host Mode is open.
        // Version state is set in validateVersion
        if (self.isVersion2) {
            [self.winkeyerPort sendData:bytesToData(kWKAdminSetWK2ModeCommand, 2)];
        } else if (self.isVersion3) {
            [self.winkeyerPort sendData:bytesToData(kWKAdminSetWK2ModeCommand, 2)];
            [self.winkeyerPort sendData:bytesToData(kWKAdminSetWK3ModeCommand, 2)];
        } else {
            ; // now what?
        }
        [self loadDefaults];
        [self.winkeyerPort sendData:byteToData(kWKImmediateGetSpeedPotCommand)];
        self.hostMode = YES;
        [self changeStatusString];
    } else if ([commandName isEqualToString:@"ReadWK2EEPROM"]) {
//        NSLog(@"%s ReadWK2EEPROM response at %@", __PRETTY_FUNCTION__, [NSDate date]);
        [_standaloneSettings decodeWK2Eeprom:responseData];
        [self openHostMode];
        [_busyReadWriteProgressWK2 stopAnimation:self];
    } else if ([commandName isEqualToString:@"ReadWK3EEPROM"]) {
//        NSLog(@"%s ReadWK3EEPROM response at %@", __PRETTY_FUNCTION__, [NSDate date]);
        [_standaloneSettings decodeWK3Eeprom:responseData];
        [self openHostMode];
        [_busyReadWriteProgressWK3 stopAnimation:self];
    } else {
        NSLog(@"%s unhandled request response name: %@", __PRETTY_FUNCTION__, commandName);
    }
}

- (void)serialPort:(ORSSerialPort*)serialPort requestDidTimeout:(ORSSerialRequest*)request
{
    [_busyReadWriteProgressWK2 stopAnimation:self];
    [_busyReadWriteProgressWK3 stopAnimation:self];
    NSString* errorDescription = [NSString stringWithFormat:@"WinKeyer command %@ timed out with no response after %.1f seconds.",
                                  request.userInfo[@"CommandName"], request.timeoutInterval];
    NSString* errorDetail = @"Confirm that a WinKeyer is attached to the selected usbserial- port.";
    NSDictionary* errorDict = @{NSLocalizedDescriptionKey: errorDescription, NSLocalizedRecoverySuggestionErrorKey: errorDetail};
    NSError* error = [NSError errorWithDomain:@"com.k1gq.macwinkeyer" code:1 userInfo:errorDict];
    [NSApp presentError:error];
    [self closePort];
}

- (void)serialPortWasRemovedFromSystem:(ORSSerialPort *)serialPort
{
    if (!self.terminating && self.winkeyerPort == serialPort) {
//TODO        if ([self.delegate respondsToSelector:@selector(deviceDidUnplug)]) {
//TODO            [self.delegate deviceDidUnplug];
//TODO        }
        if (self.winkeyerPort.isOpen) {
            NSAlert* alert = [[NSAlert alloc] init];
            alert.messageText = [NSString stringWithFormat:@"Serial port %@ for WinKeyer disappeared while in use.", self.winkeyerPort.name];
            alert.informativeText = [NSString stringWithFormat:@"Unplugging active USB connections is risky. You are responsible for unusual behavior or damage to equipment or data if you do it."];
            alert.alertStyle = NSAlertStyleCritical;
            [alert runModal];
        }
        self.winkeyerPort = nil;
    }
}

- (void)serialPortWasClosed:(ORSSerialPort *)serialPort
{
    self.statusGumdropImage = [NSImage imageNamed:NSImageNameStatusUnavailable];
    self.statusString = @"";
    self.versionString = @"";
}

@end

