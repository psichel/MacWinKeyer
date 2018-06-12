//
//  WK24MacAppDelegate.h
//  WK24Mac
//
//  Created by James  T. Rogers on 4/11/11.
//  Copyright 2011 Jim Rogers, W4ATK. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ORSSerialPort;
@class ORSSerialPortManager;

@interface WK24MacAppDelegate : NSObject <NSApplicationDelegate, NSTextViewDelegate, ORSSerialPortDelegate> {
    NSWindow *__weak window;

	// Winkeyer Tab
	IBOutlet NSTextField *oKeyerPaddleEchoField;
	IBOutlet NSTextView *oKeyerBufferDisplayField;
	IBOutlet NSPopUpButton *oKeyerPortSelection;
	//Settings Tab
	IBOutlet NSTextField *oSettingsWeightField;
	IBOutlet NSStepper *oSettingsWeightStepper;
	IBOutlet NSTextField *oSettingsCompField;
	IBOutlet NSStepper *oSettingsCompStepper;
	IBOutlet NSTextField *oSettingsLeadInField;
	IBOutlet NSStepper *oSettingsLeadInStepper;
	IBOutlet NSTextField *oSettings1stExtField;
	IBOutlet NSStepper *oSettings1stExtStepper;
	IBOutlet NSTextField *oSettingsTailField;
	IBOutlet NSStepper *oSettingsTailStepper;
	IBOutlet NSTextField *oSettingsSampleField;
	IBOutlet NSStepper *oSettingsSampleStepper;
	IBOutlet NSTextField *oSettingsFarnsField;
	IBOutlet NSStepper *oSettingsFarnsStepper;
	IBOutlet NSPopUpButton *oSettingsKeyerModeButton;
	IBOutlet NSMenuItem *oSettingsIambicA;
	IBOutlet NSMenuItem *oSettingsIambicB;
	IBOutlet NSMenuItem *oSettingsUltimatic;
	IBOutlet NSMenuItem *oSettingsUlti_Dit;
	IBOutlet NSMenuItem *oSettingsUlti_Dah;
	IBOutlet NSMenuItem *oSettingsBug;
	IBOutlet NSPopUpButton *oSettingsHangTimeButton;
	IBOutlet NSMenuItem *oSettingsHangTime_1;
	IBOutlet NSMenuItem *oSettingsHangTime_13;
	IBOutlet NSMenuItem *oSettingsHangTime_16;
	IBOutlet NSMenuItem *oSettingsHangTime_2;
	// Mode Tab
	IBOutlet NSButton *oModeSwapChkBox;
	IBOutlet NSButton *oModeAutoSpaceChkBox;
	IBOutlet NSButton *oModeCTSpaceChkBox;
	IBOutlet NSButton *oModePaddleDogChkBox;
	IBOutlet NSButton *oModePaddleEchoChkBox;
	IBOutlet NSButton *oModeSerialEchoChkBox;
	IBOutlet NSButton *oModeWPMPotLockChkBox;
	IBOutlet NSButton *oModeSTPaddleOnlyChkBox;
	IBOutlet NSTextField *oModeWPMPotMax;
	IBOutlet NSStepper *oModeWPMPotMaxStepper;
	IBOutlet NSTextField *oModeWPMPotMin;
	IBOutlet NSStepper *oModeWPMPotMinStepper;
	// OutPut Tab
	IBOutlet NSPopUpButton *oOutputPortButton;
	IBOutlet NSMenuItem *oOutputModePort1;
	IBOutlet NSMenuItem *oOutputModePort1ToneOn;
	IBOutlet NSMenuItem *oOutputModePort1PTTOn;
	IBOutlet NSMenuItem *oOutputModePort1ToneOnPTT;
	IBOutlet NSMenuItem *oOutputModePort2;
	IBOutlet NSMenuItem *oOutputModePort2ToneOn;
	IBOutlet NSMenuItem *oOutputModePort2PTTOn;
	IBOutlet NSMenuItem *oOutputModePort2ToneOnPTT ;
	IBOutlet NSPopUpButton *oOutputSTFreqButton;
	IBOutlet NSMenuItem *oOutputSTFreq4k;
	IBOutlet NSMenuItem *oOutputSTFreq2k;
	IBOutlet NSMenuItem *oOutputSTFreq13k;
	IBOutlet NSMenuItem *oOutputSTFreq1k;
	IBOutlet NSMenuItem *oOutputSTFreq800;
	IBOutlet NSMenuItem *oOutputSTFreq666;
	IBOutlet NSMenuItem *oOutputSTFreq531;
	IBOutlet NSMenuItem *oOutputSTFreq500;
	IBOutlet NSMenuItem *oOutputSTFreq444;
	IBOutlet NSMenuItem *oOutputSTFreq400;

    // EEPROM SAVE
	IBOutlet NSButton *oSaveToEEPROMChkBox;
	
	Boolean isEnabled;
	unsigned int characterIndex;
	char MODEREGISTER, PINCONFIG, SIDETONE;
	unsigned char DEFAULTS[16];
	
	//Keyer Flags
	Boolean kWAIT;
	Boolean kBUSY;
	Boolean kBREAKIN;
	Boolean kXOFF;
	Boolean kPAUSE;
	Boolean kTUNE;
	Boolean kPB1;
	Boolean kPB2;
	Boolean kPB3;
	Boolean kPB4;
	Boolean kPOTLOCK;
    
	//Command Buffer
	char kCommand[16];
	int kCmdLength;
	
	//Backspace Detector
	int BS;
	
}
@property (weak) IBOutlet NSWindow *window;

@property NSColor* winKeyerStatusColor;
@property NSColor* serialCommStatusColor;

@property ORSSerialPortManager * serialPortManager;
@property ORSSerialPort * winkeyerPort;
@property NSString* versionString;
@property BOOL terminating;

- (IBAction) openOrCloseWinKeyer:(id)sender;

// Winkeyer Tab
- (IBAction) mKeyerMem1Button:(id)sender;
- (IBAction) mKeyerMem2Button:(id)sender;
- (IBAction) mKeyerMem3Button:(id)sender;
- (IBAction) mKeyerMem4Button:(id)sender;
- (IBAction) mKeyerMem5Button:(id)sender;
- (IBAction) mKeyerMem6Button:(id)sender;
- (IBAction) mKeyerClearButton:(id)sender;
- (IBAction) mKeyerTuneButton:(id)sender;
- (IBAction) mKeyerPauseButton:(id)sender;
- (IBAction) stepKeyerWPM:(id)sender;

// Settings Tab
- (IBAction)changeRatio:(id)sender;
- (IBAction) stepSettingsWeight:(id)sender;
- (IBAction) stepSettingsComp:(id)sender;
- (IBAction) stepSettingsLeadIn:(id)sender;
- (IBAction) stepSettings1stExt:(id)sender;
- (IBAction) stepSettingsTail:(id)sender;
- (IBAction) stepSettingsSample:(id)sender;
- (IBAction) stepSettingsFarns:(id)sender;
- (IBAction) modeSetingsIambicA:(id)sender;
- (IBAction) modeSettingsIambicB:(id)sender;
- (IBAction) modeSettingsUltimatic:(id)sender;
- (IBAction) modeSettingsUlti_Dit:(id)sender;
- (IBAction) modeSettingsUlti_Dah:(id)sender;
- (IBAction) modeSettingsBug:(id)sender;
- (IBAction) mnuSettingsHangTime_1:(id)sender;
- (IBAction) mnuSettingsHangTime_13:(id)sender;
- (IBAction) mnuSettingsHangTime_16:(id)sender;
- (IBAction) mnuSettingsHangTime_2:(id)sender;

// Mode Tab
- (IBAction) chkModePaddleSwap:(id)sender;
- (IBAction) chkModeAutoSpace:(id)sender;
- (IBAction) chkModeCTSpace:(id)sender;
- (IBAction) chkModePaddleDog:(id)sender;
- (IBAction) chkModePaddleEcho:(id)sender;
- (IBAction) chkModeSerialEcho:(id)sender;
- (IBAction) chkModeSideTonePaddleOnly:(id)sender;
- (IBAction)changeSpeedPot:(id)sender;

// OutPut Tab
- (IBAction) mnuOutputModePort1:(id)sender;
- (IBAction) mnuOutputModePort1ToneOn:(id)sender;
- (IBAction) mnuOutputModePort1PTTOn:(id)sender;
- (IBAction) mnuOutputModePort1ToneOnPTT:(id)sender;
- (IBAction) mnuOutputModePort2:(id)sender;
- (IBAction) mnuOutputModePort2ToneOn:(id)sender;
- (IBAction) mnuOutputModePort2PTTOn:(id)sender;
- (IBAction) mnuOutputModePort2ToneOnPTT:(id)sender;
- (IBAction) mnuOutputSTFreq4k:(id)sender;
- (IBAction) mnuOutputSTFreq2k:(id)sender;
- (IBAction) mnuOutputSTFreq13k:(id)sender;
- (IBAction) mnuOutputSTFreq1k:(id)sender;
- (IBAction) mnuOutputSTFreq800:(id)sender;
- (IBAction) mnuOutputSTFreq666:(id)sender;
- (IBAction) mnuOutputSTFreq531:(id)sender;
- (IBAction) mnuOutputSTFreq500:(id)sender;
- (IBAction) mnuOutputSTFreq444:(id)sender;
- (IBAction) mnuOutputSTFreq400:(id)sender;

- (void) textDidChange:(NSNotification *)aNotification;
//OBE - (int)findPorts;
//OBE - (int)openPort;
//OBE - (int)hostOpen;
- (void)loadDefaults;
- (void)insertInput:(NSString*)string;
//OBE - (void)readThread;


@end

