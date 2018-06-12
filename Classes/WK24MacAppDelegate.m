//
//  WK24MacAppDelegate.m
//  WK24Mac
//
//  Created by James  T. Rogers on 4/11/11.
//  Copyright 2011 Jim Rogers, W4ATK. All rights reserved.
//

#import "ORSSerialPort.h"
#import "ORSSerialPortManager.h"
#import "ORSSerialRequest.h"
#import "WK24MacAppDelegate.h"
#import "WinKeyerConstants.h"
//K1GQ #import "serial.h"
//K1GQ #import <termios.h>
//K1GQ #import <sys/ioctl.h>
//K1GQ #import <sys/select.h>
//K1GQ #import <unistd.h>

@implementation WK24MacAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
    self.serialPortManager = [ORSSerialPortManager sharedSerialPortManager];
    
	characterIndex = 0;
	// Initialize the keyer flags.
	kWAIT = FALSE;
	kBUSY = FALSE;
	kBREAKIN = FALSE;
	kXOFF = FALSE;
	kPAUSE = FALSE;
	kPB1 = FALSE;
	kPB2 = FALSE;
	kPB3 = FALSE;
	kPB4 = FALSE;
    kCmdLength = -1;
	BS = 0; //Backspace Detector
	
    //TODO open remembered keyer
    NSString* portName = [[NSUserDefaults standardUserDefaults] stringForKey:winKeyerPORTPreferenceKey];
    NSLog(@"%s portName = %@", __PRETTY_FUNCTION__, portName);
    [oKeyerPortSelection selectItemWithTitle:portName];
    NSArray* allPorts = [[ORSSerialPortManager sharedSerialPortManager] availablePorts];
    for (ORSSerialPort* port in allPorts) {
        if ([port.name isEqualToString:portName]) {
            self.winkeyerPort = port;
            [self openOrCloseWinKeyer:self];
            break;
        }
    }
}

- (instancetype) init {														//init the app
	self = [super init];
	if (self) {
		[NSApp activateIgnoringOtherApps:YES];						//activate this app
	}
	return self;
}


- (void) awakeFromNib
{
	// These items will be needed when the configuration is sent
	// to the Winkeyer2 chip.
	MODEREGISTER = 0x00;	// prep the MODEREGISTER
	PINCONFIG = 0x00;		// prep PINCONFIG
	SIDETONE = 0x00;		// prep SIDETONE
	
	// Now, using the dictionary initialize everything in the view tabs. 
	//keyer tab
	[oSettingsWeightField setIntegerValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"WEIGHT"]];
	[oSettingsWeightStepper setIntegerValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"WEIGHT"]];
	[oSettingsCompField setIntegerValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"COMP"]];
	[oSettingsCompStepper setIntegerValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"COMP"]];
	[oSettingsLeadInField setIntegerValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"LEAD"]];
	[oSettingsLeadInStepper setIntegerValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"LEAD"]];
	[oSettings1stExtField setIntegerValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"EXT"]];
	[oSettings1stExtStepper setIntegerValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"EXT"]];
	[oSettingsTailField setIntegerValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"TAIL"]];
	[oSettingsTailStepper setIntegerValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"TAIL"]];
	[oSettingsSampleField setIntegerValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"SAMPLE"]];
	[oSettingsSampleStepper setIntegerValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"SAMPLE"]];
	[oSettingsFarnsField setIntegerValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"FARNS"]];
	[oSettingsFarnsStepper setIntegerValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"FARNS"]];
    
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"IAMBICA"]) {
		[oSettingsIambicA setState:1];
		[oSettingsKeyerModeButton setTitle:@"Iambic A"];
		MODEREGISTER = MODEREGISTER | 0x10;					//OR in the Iambic A bits if Iambic A is set.
	}else {
		[oSettingsIambicA setState:0];
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"IAMBICB"]) {
		[oSettingsIambicB setState:1];
		[oSettingsKeyerModeButton setTitle:@"Iambic B"];
		// MODEREGISTER = MODEREGISTER default is 0x00		//Nothing to OR, this is the default.
	} else {
		[oSettingsIambicB setState:0];
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ULTIM"]) {
		[oSettingsUltimatic setState:1];
		[oSettingsKeyerModeButton setTitle:@"Ultimatic"];
		MODEREGISTER = MODEREGISTER | 0x20;					//OR in the Ultimatic bits if Ultimatic is set.
	} else {
		[oSettingsUltimatic setState:0];
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ULTIDIT"]) {
		[oSettingsUlti_Dit setState:1];
		[oSettingsKeyerModeButton setTitle:@"Ulti Dits"];
		PINCONFIG = PINCONFIG | 0x80;						//OR in the Ulti_Dits bits if Ulti_Dits is set.
	} else {
		[oSettingsUlti_Dit setState:0];
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ULTIDAH"]) {
		[oSettingsUlti_Dah setState:1];
		[oSettingsKeyerModeButton setTitle:@"Ulti Dahs"];
		PINCONFIG = PINCONFIG | 0x40;						//OR in the Ulti_Dahs bits if Ulti_Dahs is set.
	} else {
		[oSettingsUlti_Dah setState:0];
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"BUg"]) {
		[oSettingsBug setState:1];
		[oSettingsKeyerModeButton setTitle:@"Bug"];
		MODEREGISTER = MODEREGISTER | 0x30;					//OR in the Bug bits if Bug is set.
	} else {
		[oSettingsBug setState:0];
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HANG1"]) {
		[oSettingsHangTime_1 setState:1];
		[oSettingsHangTimeButton setTitle:@"1 Letter space"];
		// PINCONFIG default <00>							//Nothing to OR, this is the default.
	} else {
		[oSettingsHangTime_1 setState:0];
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HANG13"]) {
		[oSettingsHangTime_13 setState:1];
		[oSettingsHangTimeButton setTitle:@"1.3 Letter spaces"];
		PINCONFIG = PINCONFIG | 0x10;						//OR in the HangTime_1.3 bits if HangTime_1.3 is set.
	} else {
		[oSettingsHangTime_13 setState:0];
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HANG16"]) {
		[oSettingsHangTime_16 setState:1];
		[oSettingsHangTimeButton setTitle:@"1.6 Letter spaces"];
		PINCONFIG = PINCONFIG | 0x20;						//OR in the HangTime_1.6 bits if HangTime_1.6 is set.
	} else {
		[oSettingsHangTime_16 setState:0];
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HANG2"]) {
		[oSettingsHangTime_2 setState:1];
		[oSettingsHangTimeButton setTitle:@"2 Letter spaces"];
		PINCONFIG = PINCONFIG | 0x30;						//OR in the HangTime_2 bits if HangTime_2 is set.
	} else {
		[oSettingsHangTime_2 setState:0];
	}
    
	// Mode Tab
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SWAP"]) {
		[oModeSwapChkBox setState:1];
		MODEREGISTER = MODEREGISTER | 0x08;					//OR in the SWap bit if Swap is checked.
	} else {
		[oModeSwapChkBox setState:0];
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AUTO"]) {
		[oModeAutoSpaceChkBox setState:1];
		MODEREGISTER = MODEREGISTER | 0x02;					//OR in the AutoSpace bit if Auto is checked.
	} else {
		[oModeAutoSpaceChkBox setState:0];
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CT"]) {
		[oModeCTSpaceChkBox setState:1];
		MODEREGISTER = MODEREGISTER | 0x00;					//OR in the CTSpace bit if CTSpace is checked.
	} else {
		[oModeCTSpaceChkBox setState:0];
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"DOG"]) {
		[oModePaddleDogChkBox setState:1];
	} else {
		[oModePaddleDogChkBox setState:0];
		MODEREGISTER = MODEREGISTER | 0x80;
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PECHO"]) {
		[oModePaddleEchoChkBox setState:1];
		MODEREGISTER = MODEREGISTER | 0x40;					//OR in the PaddleEcho bit if PaddleEcho is set.
	} else {
		[oModePaddleEchoChkBox setState:0];
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SECHO"]) {
		[oModeSerialEchoChkBox setState:1];
		MODEREGISTER = MODEREGISTER | 0x04;					//OR in the SerialEcho bit if SerialEcho is set.
	}else {
		[oModeSerialEchoChkBox setState:0];
	}
	[oModeWPMPotMax setIntegerValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"MAX"]];
	[oModeWPMPotMaxStepper setIntegerValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"MAX"]];
	[oModeWPMPotMin setIntegerValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"MIN"]];
	[oModeWPMPotMinStepper setIntegerValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"MIN"]];
	[oModeWPMPotLockChkBox setIntegerValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"LOCK"]];
	[oModeSTPaddleOnlyChkBox setIntegerValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"PONLY"]];
    
	// Output Tab
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ST4K"]) {
        oOutputSTFreq4k.state = NSOnState;
		[oOutputSTFreqButton setTitle:@"4000Hz"];
		SIDETONE = 0x01;										//Set SIDETONE 4k.
    } else {
        oOutputSTFreq4k.state = NSOffState;
    }
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ST2K"]) {
        oOutputSTFreq2k.state = NSOnState;
		[oOutputSTFreqButton setTitle:@"2000Hz"];
		SIDETONE = 0x02;										//Set SIDETONE 2k.
    } else {
        oOutputSTFreq2k.state = NSOffState;
    }
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ST13K"]) {
        oOutputSTFreq13k.state = NSOnState;
		[oOutputSTFreqButton setTitle:@"1333Hz"];
		SIDETONE = 0x03;										//Set SIDETONE 1.3k.
    } else {
        oOutputSTFreq13k.state = NSOffState;
    }
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ST1K"]) {
        oOutputSTFreq1k.state = NSOnState;
		[oOutputSTFreqButton setTitle:@"1000Hz"];
		SIDETONE = 0x04;										//Set SIDETONE 1k.
    } else {
        oOutputSTFreq1k.state = NSOffState;
    }
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ST800"]) {
        oOutputSTFreq800.state = NSOnState;
		[oOutputSTFreqButton setTitle:@"800Hz"];
		SIDETONE = 0x05;										//Set SIDETONE 800.
    } else {
        oOutputSTFreq800.state = NSOffState;
    }
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ST666"]) {
        oOutputSTFreq666.state = NSOnState;
		[oOutputSTFreqButton setTitle:@"666Hz"];
		SIDETONE = 0x06;										//Set SIDETOONE 666.
    } else {
        oOutputSTFreq666.state = NSOffState;
    }
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ST531"]) {
        oOutputSTFreq531.state = NSOnState;
		[oOutputSTFreqButton setTitle:@"531Hz"];
		SIDETONE = 0x07;										//Set SIDETONE 531.
    } else {
        oOutputSTFreq531.state = NSOffState;
    }
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ST500"]) {
        oOutputSTFreq500.state = NSOnState;
		[oOutputSTFreqButton setTitle:@"500Hz"];
		SIDETONE = 0x08;										//Set SIDETONE 500.
    } else {
        oOutputSTFreq500.state = NSOffState;
    }
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ST444"]) {
        oOutputSTFreq444.state = NSOnState;
		[oOutputSTFreqButton setTitle:@"444Hz"];
		SIDETONE = 0x09;										//Set SIDETONE 444.
    } else {
        oOutputSTFreq444.state = NSOffState;
    }
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ST400"]) {
        oOutputSTFreq400.state = NSOnState;
		[oOutputSTFreqButton setTitle:@"400Hz"];
		SIDETONE = 0x0a;										//Set SIDETONE 400.
    } else {
        oOutputSTFreq400.state = NSOffState;
    }
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"P1TOFF"]) {
		[oOutputModePort1 setState:1];
		[oOutputPortButton setTitle:@"Port 1"];
		PINCONFIG = PINCONFIG | 0x04;							//OR in the Port1ToneOff bit if Port1ToneOff is set.
	} else {
		[oOutputModePort1 setState:0];
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"P1TON"]) {
		[oOutputModePort1ToneOn setState:1];
		[oOutputPortButton setTitle:@"Port 1,ST"];
		PINCONFIG = PINCONFIG | 0x06;							//OR in the Port1ToneOn bits if Port1ToneOn is set.
	} else {
		[oOutputModePort1ToneOn setState:0];
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"P1PTT"]) {
		[oOutputModePort1PTTOn setState:1];
		[oOutputPortButton setTitle:@"Port 1,PTT"];
		PINCONFIG = PINCONFIG | 0x06;							//OR in the Port1ToneOn bits if Port1ToneOn is set.
	} else {
		[oOutputModePort1PTTOn setState:0];
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"P1TONPTT"]) {
		[oOutputModePort1ToneOnPTT setState:1];
		[oOutputPortButton setTitle:@"Port 1,ST,PTT"];
		PINCONFIG = PINCONFIG | 0x07;							//OR in the Port1ToneOn bits if Port1ToneOn is set.
	} else {
		[oOutputModePort1ToneOnPTT setState:0];
	}
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"P2TOFF"]) {
		[oOutputModePort2 setState:1];
		[oOutputPortButton setTitle:@"Port 2"];
		PINCONFIG = PINCONFIG | 0x08;							//OR in the Port2ToneOff bit if Port2ToneOff is set.
	} else {
		[oOutputModePort2 setState:0];
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"P2TON"]) {
		[oOutputModePort2ToneOn setState:1];
		[oOutputPortButton setTitle:@"Port 2,ST"];
		PINCONFIG = PINCONFIG | 0x0a;							//OR in the Port2ToneOn bits if Port2ToneOn is set.
	} else {
		[oOutputModePort2ToneOn setState:0];
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"P2PTT"]) {
		[oOutputModePort2PTTOn setState:1];
		[oOutputPortButton setTitle:@"Port 2,PTT"];
		PINCONFIG = PINCONFIG | 0x0a;							//OR in the Port2ToneOn bits if Port2ToneOn is set.
	} else {
		[oOutputModePort2PTTOn setState:0];
	}
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"P2TONPTT"]) {
		[oOutputModePort2ToneOnPTT setState:1];
		[oOutputPortButton setTitle:@"Port 2,ST,PTT"];
		PINCONFIG = PINCONFIG | 0x0b;							//OR in the Port2ToneOn bits if Port2ToneOn is set.
	} else {
		[oOutputModePort2ToneOnPTT setState:0];
	}

    // tab initialization completed
    
	// initialize the keyer status indicator
    self.winKeyerStatusColor = [NSColor redColor];

	// So I can examine the MODEREGISTER and PINCONFIG
	MODEREGISTER = MODEREGISTER | 0x00;
	PINCONFIG = PINCONFIG | 0x00;
	SIDETONE = SIDETONE | 0x00;
	
	// set up SIDETONE Paddle Only
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PONLY"]) {
		SIDETONE = SIDETONE | 0x80;
	} else {
		SIDETONE = SIDETONE & 0x0f;
	}
	
	// Complete the DEFAULTS Block so we can initialize the keyer.
	DEFAULTS[0] = kWKImmediateLoadDefaultsCommand;
	DEFAULTS[1] = MODEREGISTER;
	DEFAULTS[2] = (unsigned char)[[[NSUserDefaults standardUserDefaults] objectForKey:winKeyerWPMPreferenceKey] integerValue];
	DEFAULTS[3] = SIDETONE;
    DEFAULTS[4] = (unsigned char)[[[NSUserDefaults standardUserDefaults] objectForKey:winKeyerWEIGHTPreferenceKey] integerValue];
    DEFAULTS[5] = (unsigned char)[[[NSUserDefaults standardUserDefaults] objectForKey:winKeyerLEADPreferenceKey] integerValue];
    DEFAULTS[6] = (unsigned char)[[[NSUserDefaults standardUserDefaults] objectForKey:winKeyerTAILPreferenceKey] integerValue];
    DEFAULTS[7] = (unsigned char)[[[NSUserDefaults standardUserDefaults] objectForKey:winKeyerMINPreferenceKey] integerValue];
    DEFAULTS[8] = (unsigned char)[[[NSUserDefaults standardUserDefaults] objectForKey:winKeyerMAXPreferenceKey] integerValue];
    DEFAULTS[9] = (unsigned char)[[[NSUserDefaults standardUserDefaults] objectForKey:winKeyerEXTPreferenceKey] integerValue];
    DEFAULTS[10] = (unsigned char)[[[NSUserDefaults standardUserDefaults] objectForKey:winKeyerCOMPPreferenceKey] integerValue];
    DEFAULTS[11] = (unsigned char)[[[NSUserDefaults standardUserDefaults] objectForKey:winKeyerFARNSPreferenceKey] integerValue];
    DEFAULTS[12] = (unsigned char)[[[NSUserDefaults standardUserDefaults] objectForKey:winKeyerSAMPLEPreferenceKey] integerValue];
    DEFAULTS[13] = (unsigned char)[[[NSUserDefaults standardUserDefaults] objectForKey:winKeyerRATIOPreferenceKey] integerValue];
	DEFAULTS[14] = PINCONFIG;
	DEFAULTS[15] = 0x0;

#ifdef NOT_OBE
	// Populate the ports list on the ports tab.
	if ([self findPorts] <= 0) {
		[oKeyerPortSelection  addItemWithTitle:@"No USB ports"];
	}
	
	// If no prior port in the plist defaults to the first port in the list.
	devPath = [temp valueForKey:@"PORT"];
	NSLog(@"devPath = %@.", devPath);
	if ([devPath compare:@"Find Port"] == FALSE) {
		devPath = path[0];
	}
	[oKeyerPortSelection setTitle:devPath];
	// Open a port, if you get a response send the inits to the keyer chip and start the thread.
	fileDescriptor = [self openPort];
	if (fileDescriptor == -1) {												//port did not open.
		[oKeyerIndicator setBackgroundColor:[NSColor redColor]];
		[oKeyerIndicator display];
	} else {
		//send host open command
		NSLog(@"Filedescriptor: %d", fileDescriptor);
		if ([self hostOpen] != -1) {
			[self loadDefaults];
			// start the thread
			[NSThread detachNewThreadSelector:@selector(readThread) toTarget:self withObject:nil];
			[oKeyerConnectionIndicator setBackgroundColor:[NSColor greenColor]]; // set the connection indicator to green to go.
			[oKeyerConnectionIndicator display];
		}else {
			[oKeyerIndicator setBackgroundColor:[NSColor redColor]];
			[oKeyerIndicator display];
			NSLog(@"Open host mode failed");
		}

	}
#endif
#ifdef NOT_OBE
        if ([self hostOpen] != -1) {
            [self loadDefaults];
            [oKeyerConnectionIndicator setBackgroundColor:[NSColor greenColor]];
        } else {
            [oKeyerConnectionIndicator setBackgroundColor:[NSColor redColor]];
        }
    }
#endif
}

- (void)insertInput:(NSString *)string {
	NSString *s;
	// NSLog(@"%@",string);
	s = [oKeyerPaddleEchoField stringValue];
	s = [s stringByAppendingString:string];
	if ([s length] > 128) {
		s = [s substringFromIndex:[s length]-128];
	}
	[oKeyerPaddleEchoField setStringValue:s];
}

- (void)loadDefaults {
#ifdef USE_OLD_CODE
	int numBytes;
	numBytes = write(fileDescriptor, DEFAULTS, 16);
	NSLog(@"Wrote %d DEFAULTS bytes.", numBytes);
#else
    [self.winkeyerPort sendData:bytesToData((const unsigned char*)DEFAULTS, 16)];
#endif
}

// delegate of NSApp Converts values where necessary to be compatible with KVC and stores the values
// to the AppData.plist which is contained within the bundle

- (NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *)sender
{
    self.terminating = YES;

#ifdef NOT_OBE
	// data and structures for eeprom read/write
	char sbuff[6];
	int numBytes;
	
	struct WKEEPROM {
		char wkmagic;		// 0x00 always 0xa5
		char wkmodereg;		// 0x01
		char wkoprrate;		// 0x02 cw speed
		char wkstconst;		// 0x03 side tone constant 0x01 thru 0x0a
		char wkweight;		// 0x04
		char wklead_time;	// 0x05
		char wktail_time;	// 0x06
		char wkmin_wpm;		// 0x07
		char wkwpm_range;	// 0x08
		char wkxtnd;		// 0x09
		char wkcomp;		// 0x0a
		char wkfarnswpm;	// 0x0b
		char wksampadj;		// 0x0c
		char wkratio;		// 0x0d
		char wkpincfg;		// 0x0e pinconfig register
		char wkk12mode;		// 0x0f
		char wkcmdwpm;		// 0x10
		char wkfreeptr;		// 0x11
		char wkmsgptr1;		// 0x12
		char wkmsgptr2;		// 0x13
		char wkmsgptr3;		// 0x14
		char wkmsgptr4;		// 0x15
		char wkmsgptr5;		// 0x16
		char wkmsgptr6;		// 0x17
		char wkmsgs[232];	// 0x18
		
		char wkcopy[241];	// 0x0f copied and return to standalone - DO NOT MODIFY.
	} wkstate;

	// items for dictionary save to plist
	NSNumber *kWPM, *kRatio, *kWeight, *kComp;
	NSNumber *kLead, *kExt, *kTail, *kSample, *kFarns;
	NSNumber *kIambicA, *kIambicB, *kUltimatic, *kUltiDit, *kUltiDah, *kBug;
	NSNumber *kHang1, *kHang13, *kHang16, *kHang2;
	NSNumber *kSwap, *kAuto, *kCT, *kDog, *kPecho, *kSecho, *kLock, *kPonly;
	NSNumber *kMax, *kMin, *kSt4k, *kSt2k, *kSt13k,*kSt1k, *kSt800, *kSt666;
	NSNumber *kSt531, *kSt500, *kSt444, *kSt400;
	NSNumber *kP1toff, *kP1ton, *kP1ptt, *kP1tonptt;
	NSNumber *kP2toff, *kP2ton, *kP2ptt, *kP2tonptt;
	NSString *Mem1, *Mem2, *Mem3, *Mem4, *Mem5, *Mem6;
	
	// Keyer
	// Settings
	kWeight = [[NSNumber alloc] initWithInt:[oSettingsWeightField intValue]];
	kComp = [[NSNumber alloc] initWithInt:[oSettingsCompField intValue]];
	kLead = [[NSNumber alloc] initWithInt:[oSettingsLeadInField intValue]];
	kExt = [[NSNumber alloc] initWithInt:[oSettings1stExtField intValue]];
	kTail = [[NSNumber alloc] initWithInt:[oSettingsTailField intValue]];
	kSample = [[NSNumber alloc] initWithInt:[oSettingsSampleField intValue]];
	kFarns = [[NSNumber alloc] initWithInt:[oSettingsFarnsField intValue]];
	kIambicA = [[NSNumber alloc] initWithInt:[oSettingsIambicA state]];
	kIambicB = [[NSNumber alloc] initWithInt:[oSettingsIambicB state]];
	kUltimatic = [[NSNumber alloc] initWithInt:[oSettingsUltimatic state]];
	kUltiDit = [[NSNumber alloc] initWithInt:[oSettingsUlti_Dit state]];
	kUltiDah = [[NSNumber alloc] initWithInt:[oSettingsUlti_Dah state]];
	kBug = [[NSNumber alloc] initWithInt:[oSettingsBug state]];
	kHang1 = [[NSNumber alloc] initWithInt:[oSettingsHangTime_1 state]];
	kHang13 = [[NSNumber alloc] initWithInt:[oSettingsHangTime_13 state]];
	kHang16 = [[NSNumber alloc] initWithInt:[oSettingsHangTime_16 state]];
	kHang2 = [[NSNumber alloc] initWithInt:[oSettingsHangTime_2 state]];
	// Mode
	kSwap = [[NSNumber alloc] initWithInt:[oModeSwapChkBox intValue]];
	kAuto = [[NSNumber alloc] initWithInt:[oModeAutoSpaceChkBox intValue]];
	kCT = [[NSNumber alloc] initWithInt:[oModeCTSpaceChkBox intValue]];
	kDog = [[NSNumber alloc] initWithInt:[oModePaddleDogChkBox intValue]];
	kPecho = [[NSNumber alloc] initWithInt:[oModePaddleEchoChkBox intValue]];
	kSecho = [[NSNumber alloc] initWithInt:[oModeSerialEchoChkBox intValue]];
	kLock = [[NSNumber alloc] initWithInt:[oModeWPMPotLockChkBox intValue]];
	kPonly = [[NSNumber alloc] initWithInt:[oModeSTPaddleOnlyChkBox intValue]];
	kMax = [[NSNumber alloc] initWithInt:[oModeWPMPotMax intValue]];
	kMin = [[NSNumber alloc] initWithInt:[oModeWPMPotMin intValue]];
	// Output
	kSt4k = [[NSNumber alloc] initWithInt:[oOutputSTFreq4k state]];
	kSt2k = [[NSNumber alloc] initWithInt:[oOutputSTFreq2k state]];
	kSt13k = [[NSNumber alloc] initWithInt:[oOutputSTFreq13k state]];
	kSt1k = [[NSNumber alloc] initWithInt:[oOutputSTFreq1k state]];
	kSt800 = [[NSNumber alloc] initWithInt:[oOutputSTFreq800 state]];
	kSt666 = [[NSNumber alloc] initWithInt:[oOutputSTFreq666 state]];
	kSt531 = [[NSNumber alloc] initWithInt:[oOutputSTFreq531 state]];
	kSt500 = [[NSNumber alloc] initWithInt:[oOutputSTFreq500 state]];
	kSt444 = [[NSNumber alloc] initWithInt:[oOutputSTFreq444 state]];
	kSt400 = [[NSNumber alloc] initWithInt:[oOutputSTFreq400 state]];
	kP1toff = [[NSNumber alloc] initWithInt:[oOutputModePort1 state]];
	kP1ton = [[NSNumber alloc] initWithInt:[oOutputModePort1ToneOn state]];
	kP1ptt = [[NSNumber alloc] initWithInt:[oOutputModePort1PTTOn state]];
	kP1tonptt = [[NSNumber alloc] initWithInt:[oOutputModePort1ToneOnPTT state]];
	kP2toff = [[NSNumber alloc] initWithInt:[oOutputModePort2 state]];
	kP2ton = [[NSNumber alloc] initWithInt:[oOutputModePort2ToneOn state]];
	kP2ptt = [[NSNumber alloc] initWithInt:[oOutputModePort2PTTOn state]];
	kP2tonptt = [[NSNumber alloc] initWithInt:[oOutputModePort2ToneOnPTT state]];
	// Memories
	Mem1 = [oMemories1 stringValue];
	Mem2 = [oMemories2 stringValue];
	Mem3 = [oMemories3 stringValue];
	Mem4 = [oMemories4 stringValue];
	Mem5 = [oMemories5 stringValue];
	Mem6 = [oMemories6 stringValue];
	
	NSMutableDictionary *temp = [[NSMutableDictionary alloc]init];
	// Keyer
	[temp setObject:kWPM forKey:@"WPM"];
    [[NSUserDefaults standardUserDefaults] setObject:[oKeyerPortSelection title] forKey:winKeyerPortNamePreferenceKey];
	[temp setObject:[oKeyerPortSelection title] forKey:@"PORT"]; //Save the current port for next time.
	// Settings
	[temp setObject:kRatio forKey:@"RATIO"];
	[temp setObject:kWeight forKey:@"WEIGHT"];
	[temp setObject:kComp forKey:@"COMP"];
	[temp setObject:kLead forKey:@"LEAD"];
	[temp setObject:kExt forKey:@"EXT"];
	[temp setObject:kTail forKey:@"TAIL"];
	[temp setObject:kSample forKey:@"SAMPLE"];
	[temp setObject:kFarns forKey:@"FARNS"];
	[temp setObject:kIambicA forKey:@"IAMBICA"];
	[temp setObject:kIambicB forKey:@"IAMBICB"];
	[temp setObject:kUltimatic forKey:@"ULTIM"];
	[temp setObject:kUltiDit forKey:@"ULTIDIT"];
	[temp setObject:kUltiDah forKey:@"ULTIDAH"];
	[temp setObject:kBug forKey:@"BUG"];
	[temp setObject:kHang1 forKey:@"HANG1"];
	[temp setObject:kHang13 forKey:@"HANG13"];
	[temp setObject:kHang16 forKey:@"HANG16"];
	[temp setObject:kHang2 forKey:@"HANG2"];
	//MODE
	[temp setObject:kSwap forKey:@"SWAP"];
	[temp setObject:kAuto forKey:@"AUTO"];
	[temp setObject:kCT forKey:@"CT"];
	[temp setObject:kDog forKey:@"DOG"];
	[temp setObject:kPecho forKey:@"PECHO"];
	[temp setObject:kSecho forKey:@"SECHO"];
	[temp setObject:kLock forKey:@"LOCK"];
	[temp setObject:kPonly forKey:@"PONLY"];
	[temp setObject:kMax forKey:@"MAX"];
	[temp setObject:kMin forKey:@"MIN"];
	// Output
	[temp setObject:kSt4k forKey:@"ST4K"];
	[temp setObject:kSt2k forKey:@"ST2K"];
	[temp setObject:kSt13k forKey:@"ST13K"];
	[temp setObject:kSt1k forKey:@"ST1K"];
	[temp setObject:kSt800 forKey:@"ST800"];
	[temp setObject:kSt666 forKey:@"ST666"];
	[temp setObject:kSt531 forKey:@"ST531"];
	[temp setObject:kSt500 forKey:@"ST500"];
	[temp setObject:kSt444 forKey:@"ST444"];
	[temp setObject:kSt400 forKey:@"ST400"];
	[temp setObject:kP1toff forKey:@"P1TOFF"];
	[temp setObject:kP1ton forKey:@"P1TON"];
	[temp setObject:kP1ptt forKey:@"P1PTT"];
	[temp setObject:kP1tonptt forKey:@"P1TONPTT"];
	[temp setObject:kP2toff forKey:@"P2TOFF"];
	[temp setObject:kP2ton forKey:@"P2TON"];
	[temp setObject:kP2ptt forKey:@"P2PTT"];
	[temp setObject:kP2tonptt forKey:@"P2TONPTT"];
	// Memories
	[temp setObject:Mem1 forKey:@"MEM1"];
	[temp setObject:Mem2 forKey:@"MEM2"];
	[temp setObject:Mem3 forKey:@"MEM3"];
	[temp setObject:Mem4 forKey:@"MEM4"];
	[temp setObject:Mem5 forKey:@"MEM5"];
	[temp setObject:Mem6 forKey:@"MEM6"];
	
	for(id key in temp) {
		NSLog(@"Saving Key: %@ Value: %@", key, [temp objectForKey:key]);
	}
	
	NSString *plistPath = [[NSBundle mainBundle]pathForResource:@"AppData" ofType:@"plist"];
    NSString* error = nil;
	NSData *plistData = [NSPropertyListSerialization
						 dataFromPropertyList:temp
						 format:NSPropertyListXMLFormat_v1_0
						 errorDescription:&error];
	if (plistData) {
		[plistData writeToFile:plistPath atomically:YES];
	} else {
		NSLog(@"ERROR formatting plistData: %@", error);
	}
	
	// HOST CLOSE
	sbuff[0] = 0x00;
	sbuff[1] = 0x03;
#endif
#ifdef TODO
    // READ/SAVE EEPROM
    if ([oSaveToEEPROMChkBox state] == NSOnState) {
        sbuff[1] = 0x0c;												// read the eeprom into the wkstate structure
        numBytes = write(fileDescriptor, sbuff, 2);
        [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.5]];
        numBytes = read(fileDescriptor, &wkstate, sizeof(wkstate));
        NSLog(@"Read %d EEPROM bytes", numBytes);
        if (numBytes == 256) { // good read.
            // what changed??
            wkstate.wkmodereg = MODEREGISTER;
            wkstate.wkoprrate = [oSettingsWPMField intValue];
            wkstate.wkstconst = SIDETONE & 0x0f;
            wkstate.wkpincfg = PINCONFIG;
            wkstate.wkweight = [oSettingsWeightField intValue];
            wkstate.wklead_time = [oSettingsLeadInField intValue];
            wkstate.wktail_time = [oSettingsTailField intValue];
            wkstate.wkmin_wpm = [oModeWPMPotMin intValue];
            wkstate.wkwpm_range = [oModeWPMPotMax intValue] - wkstate.wkmin_wpm;
            wkstate.wkxtnd = [oSettings1stExtField intValue];
            wkstate.wkcomp = [oSettingsCompField intValue];
            wkstate.wkfarnswpm = [oSettingsFarnsField intValue];
            wkstate.wksampadj = [oSettingsSampleField intValue];
            wkstate.wkratio = [oSettingsRatioField intValue];
            //write the information to the EEPROM
            sbuff[1] =0x0d;
            numBytes = write(fileDescriptor, sbuff, 2);
            numBytes = write(fileDescriptor, (char *)&wkstate, sizeof(wkstate));
            NSLog(@"Wrote %d bytes to EEPROM", numBytes);
        }
    }
#endif
	
#ifdef USE_OLD_CODE
    numBytes = write(fileDescriptor, sbuff, 2);						// close host
    // close the serial port
    close(fileDescriptor);
#else
    [self.winkeyerPort sendData:bytesToData(kWKAdminHostCloseCommand, 2)];
    [self.winkeyerPort close];
#endif
    
    // quit now!
	return NSTerminateNow;
}

#pragma mark - Keyer Tab Actions

- (IBAction)mKeyerMem1Button:(id)sender {
    [self sendAsciiString:[[NSUserDefaults standardUserDefaults] stringForKey:winKeyerMEM1PreferenceKey]];
}

- (IBAction)mKeyerMem2Button:(id)sender {
    [self sendAsciiString:[[NSUserDefaults standardUserDefaults] stringForKey:winKeyerMEM2PreferenceKey]];
}

- (IBAction)mKeyerMem3Button:(id)sender {
    [self sendAsciiString:[[NSUserDefaults standardUserDefaults] stringForKey:winKeyerMEM3PreferenceKey]];
}

- (IBAction)mKeyerMem4Button:(id)sender {
    [self sendAsciiString:[[NSUserDefaults standardUserDefaults] stringForKey:winKeyerMEM4PreferenceKey]];
}

- (IBAction)mKeyerMem5Button:(id)sender {
    [self sendAsciiString:[[NSUserDefaults standardUserDefaults] stringForKey:winKeyerMEM5PreferenceKey]];
}

- (IBAction)mKeyerMem6Button:(id)sender {
    [self sendAsciiString:[[NSUserDefaults standardUserDefaults] stringForKey:winKeyerMEM6PreferenceKey]];
}

- (IBAction)mKeyerClearButton:(id)sender {				// stops sending immediately. clears the chips buffer.
	//NSString *string;									// JR 5/20/11
	
	//string = [oKeyerBufferDisplayField string];		// JR 5/20/11
	//characterIndex = [string length];
	[oKeyerBufferDisplayField setString:@""];
	characterIndex = 0;
	kCommand[kCmdLength + 1] = 0x0a;
	kCommand[kCmdLength + 2] = 0x16;
	kCommand[kCmdLength + 3] = 0x00;
	kCommand[kCmdLength + 4] = 0x15;
	kCmdLength = kCmdLength + 4;
	kPAUSE = FALSE;										// clear pause.
	kTUNE = FALSE;										// clear tune.
	BS = 0;												// Backspace detector
}

- (IBAction)mKeyerTuneButton:(id)sender {				// toggle - key immediate.
	//Set tune
	kCommand[kCmdLength + 1] = 0x0b;
	if (!kTUNE) {
		kTUNE = TRUE;
		kCommand[kCmdLength + 2] = 0x01;
	} else {
		kTUNE = FALSE;
		kCommand[1] = 0x00;
	}
	kCmdLength = 2;
}

- (IBAction)mKeyerPauseButton:(id)sender {				//toggle - pause immediate.
	//Set Pause
	if (kBUSY) {
		kCommand[kCmdLength + 1] = 0x06;
		if (!kPAUSE) {
			kPAUSE = TRUE;
			kCommand[kCmdLength + 2] = 0x01;
		} else {
			kPAUSE = FALSE;
			kCommand[kCmdLength + 2] = 0x00;
		}
		kCmdLength = 2;
	}
}

- (IBAction)stepKeyerWPM:(id)sender {
    NSInteger speed = [sender integerValue];
    NSInteger minWPMSpeed =[[NSUserDefaults standardUserDefaults] integerForKey:winKeyerMINPreferenceKey];
    NSInteger maxWPMRange = [[NSUserDefaults standardUserDefaults] integerForKey:winKeyerMAXPreferenceKey];
    NSInteger newSpeed = (speed < minWPMSpeed ? minWPMSpeed : speed);
    newSpeed = (newSpeed > minWPMSpeed + maxWPMRange ? minWPMSpeed + maxWPMRange : newSpeed);
    const unsigned char command[2] = {kWKImmediateSetWPMSpeedCommand, (unsigned char)newSpeed};
    [self.winkeyerPort sendData:bytesToData(command, 2)];
}

- (IBAction)openOrCloseWinKeyer:(id)sender
{
    if (self.winkeyerPort.isOpen) {
        [self.winkeyerPort sendData:bytesToData(kWKAdminHostCloseCommand, 2)];
        [self.winkeyerPort close];
        self.serialCommStatusColor = [NSColor redColor];
        [[NSUserDefaults standardUserDefaults] setObject:portNameNone forKey:winKeyerPORTPreferenceKey];
    } else {
        self.winkeyerPort.baudRate = @(B1200);
        self.winkeyerPort.parity = ORSSerialPortParityNone;
        self.winkeyerPort.numberOfStopBits = 1;
        self.winkeyerPort.delegate = self;
        [self.winkeyerPort open];
        if (self.winkeyerPort.isOpen) {
            [[NSUserDefaults standardUserDefaults] setObject:self.winkeyerPort.name forKey:winKeyerPORTPreferenceKey];
            NSDictionary* userInfo = @{@"CommandName": @"HostOpen"};
            ORSSerialRequest* request = [ORSSerialRequest requestWithDataToSend:bytesToData(kWKAdminHostOpenCommand, 2)
                                                                       userInfo:userInfo
                                                                timeoutInterval:1.0
                                                              responseEvaluator:^BOOL(NSData* inputData) {
                                                                  if (inputData.length != 1) return NO;
                                                                  return YES;
                                                              }];
            [self.winkeyerPort sendRequest:request];
        }
    }
}

#ifdef NOT_OBE
- (IBAction)mKeyerPortsButton:(id)sender {
	NSMenuItem *kItem;
    
	// NSLog(@"Port selection button clicked");
	if (fileDescriptor >= 0) {
		close(fileDescriptor);
	}
	kItem  = [oKeyerPortSelection selectedItem];
	devPath = [kItem title];
	fileDescriptor = [self openPort];
	if (fileDescriptor == -1) {													//port did not open - load new list of ports.
		// NSLog(@"Port from menu could not be opened.");
		[oKeyerConnectionIndicator setBackgroundColor:[NSColor redColor]];
		[oKeyerConnectionIndicator display];
	} else {
		//send host open command
		// NSLog(@"mKeyerPortButton Filedescriptor: %d", fileDescriptor);
		[self hostOpen];
		[self loadDefaults];
		[NSThread detachNewThreadSelector:@selector(readThread) toTarget:self withObject:nil];	// start the new thread.
		[oKeyerConnectionIndicator setBackgroundColor:[NSColor greenColor]];	// set the connection indicator to green to go.
		[oKeyerConnectionIndicator display];
	}
}
#endif

#pragma mark - Settings Tab Actions

- (IBAction)changeRatio:(id)sender
{
    const unsigned char ratio = (unsigned char)[[NSUserDefaults standardUserDefaults] integerForKey:winKeyerRATIOPreferenceKey];
    const unsigned char command[2] = {kWKImmediateSetDitDahRatioCommand, ratio};
    [self.winkeyerPort sendData:bytesToData(command, 2)];
}

- (IBAction) stepSettingsWeight:(id)sender {
	//Increment/Decrement weight to max 90
	[oSettingsWeightField setIntValue:[sender integerValue]];
	kCommand[kCmdLength + 1] = 0x03;
	kCommand[kCmdLength + 2] = [sender integerValue];
	kCmdLength = 2;
}

- (IBAction) stepSettingsComp:(id)sender {
	//Icrement/Decrement compensation to max 250 (mSecs)
	[oSettingsCompField setIntValue:[sender integerValue]];
	kCommand[kCmdLength + 1] = 0x11;
	kCommand[kCmdLength + 2] = [sender integerValue];
	kCmdLength = 2;
}

- (IBAction) stepSettingsLeadIn:(id)sender {
	//Increment/Decrement leadin to max 250 steps = 10 (mSecs)
	[oSettingsLeadInField setIntValue:[sender integerValue]];
	kCommand[kCmdLength + 1] = 0x04;
	kCommand[kCmdLength + 2] = [sender integerValue];
	kCommand[kCmdLength + 3] = [oSettingsTailStepper integerValue];
	kCmdLength = 3;
}

- (IBAction) stepSettings1stExt:(id)sender {
	//Increment/Decrement 1stext to max 250 mSecs
	[oSettings1stExtField setIntValue:[sender integerValue]];
	kCommand[kCmdLength + 1] = 0x10;
	kCommand[kCmdLength + 2] = [sender integerValue];
	kCmdLength = 2;
	
}

- (IBAction) stepSettingsTail:(id)sender {
	//Increment/Decrement tail to max 250 steps 10 (mSecs)
	[oSettingsTailField setIntValue:[sender integerValue]];
	kCommand[kCmdLength + 1] = 0x04;
	kCommand[kCmdLength + 2] = [sender integerValue];
	kCommand[kCmdLength + 3] = [oSettingsLeadInStepper integerValue];
	kCmdLength = 3;
}

- (IBAction) stepSettingsSample:(id)sender {
	//Increment/Decrement paddle switch point 10 to 90 .1 dit time
	[oSettingsSampleField setIntValue:[sender integerValue]];
	kCommand[kCmdLength + 1] = 0x12;
	kCommand[kCmdLength + 2] = [sender integerValue];
	kCmdLength = 2;
	
}

- (IBAction) stepSettingsFarns:(id)sender {
	//Increment Farnsworth speed to max 99
	[oSettingsFarnsField setIntValue:[sender integerValue]];
	kCommand[kCmdLength + 1] = 0x0d;
	kCommand[kCmdLength + 2] = [sender integerValue];
	kCmdLength = 2;
	
}

- (IBAction) modeSetingsIambicA:(id)sender {
	kCommand[kCmdLength + 1] = 0x0e;
	MODEREGISTER = MODEREGISTER & 0xcf;				//Clear the Keyer Mode bits of the MODEREGISTER MSB.
	//Set keyer mode iambic A
	[oSettingsIambicA setState:1];
	[oSettingsIambicB setState:0];
	[oSettingsUltimatic setState:0];
	[oSettingsUlti_Dit setState:0];
	[oSettingsUlti_Dah setState:0];
	[oSettingsBug setState:0];
	[oSettingsKeyerModeButton setTitle:@"Iambic A"];
	MODEREGISTER = MODEREGISTER | 0x10;				//OR in the Iambic B bits of the MODEREGISTER MSB.
	kCommand[kCmdLength + 2] = MODEREGISTER;
	kCmdLength = 2;
}

- (IBAction) modeSettingsIambicB:(id)sender {
	kCommand[kCmdLength + 1] = 0x0e;
	MODEREGISTER = MODEREGISTER & 0xcf;				//Clear the Keyer Mode bits of the MODEREGISTER MSB.
	//Set keyer mode iambic B
	[oSettingsIambicA setState:0];
	[oSettingsIambicB setState:1];
	[oSettingsUltimatic setState:0];
	[oSettingsUlti_Dit setState:0];
	[oSettingsUlti_Dah setState:0];
	[oSettingsBug setState:0];
	[oSettingsKeyerModeButton setTitle:@"Iambic B"];
	//MODEREGISTER default is 0x00					//Nothing to OR, this is the default
	kCommand[kCmdLength + 2] = MODEREGISTER;
	kCmdLength = 2;
}

- (IBAction) modeSettingsUltimatic:(id)sender {
	kCommand[kCmdLength + 1] = 0x0e;
	MODEREGISTER = MODEREGISTER & 0xcf;				//Clerar the Keyer Mode bits of the MODEREGISTER MSB.
	//Set keyer mode Ultimatic
	[oSettingsIambicA setState:0];
	[oSettingsIambicB setState:0];
	[oSettingsUltimatic setState:1];
	[oSettingsUlti_Dit setState:0];
	[oSettingsUlti_Dah setState:0];
	[oSettingsBug setState:0];
	[oSettingsKeyerModeButton setTitle:@"Ultimatic"];
	MODEREGISTER = MODEREGISTER | 0x40;				//OR in the Ultimatic bits of the MODEREGISTER MSB.
	kCommand[kCmdLength = 2] = MODEREGISTER;
	kCmdLength = 2;
}

- (IBAction) modeSettingsUlti_Dit:(id)sender {
	kCommand[kCmdLength = 1] = 0x09;
	PINCONFIG = PINCONFIG & 0x3f;					//Clear the Ulti_mode bits of the PINCONFIG MSB.
	//Set keyer mode dits
	[oSettingsIambicA setState:0];
	[oSettingsIambicB setState:0];
	[oSettingsUltimatic setState:0];
	[oSettingsUlti_Dit setState:1];
	[oSettingsUlti_Dah setState:0];
	[oSettingsBug setState:0];
	[oSettingsKeyerModeButton setTitle:@"Ulti Dits"];
	PINCONFIG = PINCONFIG | 0x80;					//OR in the Ulti_Dit bits of the PINCONFIG MSB.
	kCommand[kCmdLength = 2] = PINCONFIG;
	kCmdLength = 2;
}

- (IBAction) modeSettingsUlti_Dah:(id)sender {
	kCommand[kCmdLength + 1] = 0x09;
	PINCONFIG = PINCONFIG & 0x3f;					//Clear the Ulti_mode bits of the PINCONFIG MSB.
	//Set keyer mode dahs
	[oSettingsIambicA setState:0];
	[oSettingsIambicB setState:0];
	[oSettingsUltimatic setState:0];
	[oSettingsUlti_Dit setState:0];
	[oSettingsUlti_Dah setState:1];
	[oSettingsBug setState:0];
	[oSettingsKeyerModeButton setTitle:@"Ulti Dahs"];
	PINCONFIG = PINCONFIG | 0x40;					//OR in the Ulti_Dah bits of the PINCONFIG MSB.
	kCommand[kCmdLength + 2] = PINCONFIG;
	kCmdLength = 2;
}

- (IBAction) modeSettingsBug:(id)sender {
	kCommand[kCmdLength + 1] = 0x0e;
	MODEREGISTER = MODEREGISTER & 0xcf;				//Clear the Keyer Mode bits of the MODEREGISTER MSB.
	//Set keyer mode bug
	[oSettingsIambicA setState:0];
	[oSettingsIambicB setState:0];
	[oSettingsUltimatic setState:0];
	[oSettingsUlti_Dit setState:0];
	[oSettingsUlti_Dah setState:0];
	[oSettingsBug setState:1];
	[oSettingsKeyerModeButton setTitle:@"Bug"];
	MODEREGISTER = MODEREGISTER | 0x30;				//OR in the Bug bits of the MODEREGISTER MSB.
	kCommand[kCmdLength + 2] = MODEREGISTER;
	kCmdLength = 2;
}

- (IBAction) mnuSettingsHangTime_1:(id)sender {
	kCommand[kCmdLength + 1] = 0x09;
	PINCONFIG = PINCONFIG & 0xcf;					//Clear the HangTime bits of the PINCONFIG MSB.
	//Select hang time 1 word space
	[oSettingsHangTime_1 setState:1];
	[oSettingsHangTime_13 setState:0];
	[oSettingsHangTime_16 setState:0];
	[oSettingsHangTime_2 setState:0];
	[oSettingsHangTimeButton setTitle:@"1 Letter space"];
	//PINCONFIG default is 0x00						//Nothing to OR in, this is the default.
	kCommand[kCmdLength + 2] = PINCONFIG;
	kCmdLength = 2;
}

- (IBAction) mnuSettingsHangTime_13:(id)sender {
	kCommand[kCmdLength + 1] = 0x09;
	PINCONFIG = PINCONFIG & 0xcf;					//Clear the HangTime bits of the PINCONFIG MSB.
	//Select hang time 1.3 word spaces
	[oSettingsHangTime_1 setState:0];
	[oSettingsHangTime_13 setState:1];
	[oSettingsHangTime_16 setState:0];
	[oSettingsHangTime_2 setState:0];
	[oSettingsHangTimeButton setTitle:@"1.3 Letter spaces"];
	PINCONFIG = PINCONFIG | 0x10;					//OR in the 1.3 wordspace to the PINCONFIG MSB.
	kCommand[kCmdLength + 2] = PINCONFIG;
	kCmdLength = 2;
}

- (IBAction) mnuSettingsHangTime_16:(id)sender {
	kCommand[kCmdLength + 1] = 0x09;
	PINCONFIG = PINCONFIG & 0xcf;					//Clear the HangTime bits of the PINCONFIG MSB.
	//Select hang time 1.6 wordspaces
	[oSettingsHangTime_1 setState:0];
	[oSettingsHangTime_13 setState:0];
	[oSettingsHangTime_16 setState:1];
	[oSettingsHangTime_2 setState:0];
	[oSettingsHangTimeButton setTitle:@"1.6 Letter spaces"];
	PINCONFIG = PINCONFIG | 0x20;					//OR in the 1.6 wordspace to the PINCONFIG MSB.
	kCommand[kCmdLength + 2] = PINCONFIG;
	kCmdLength = 2;
}

- (IBAction) mnuSettingsHangTime_2:(id)sender {
	kCommand[kCmdLength + 1] = 0x09;
	PINCONFIG = PINCONFIG & 0xcf;					//Clear the HangTime bits of the PINCONFIG MSB.
	//Select hang time 2 word spaces
	[oSettingsHangTime_1 setState:0];
	[oSettingsHangTime_13 setState:0];
	[oSettingsHangTime_16 setState:0];
	[oSettingsHangTime_2 setState:1];
	[oSettingsHangTimeButton setTitle:@"2 Letter spaces"];
	PINCONFIG = PINCONFIG | 0x30;					//OR in the 2.0 wordspace bits to the PINCONFIG MSB.
	kCommand[kCmdLength + 2] = PINCONFIG;
	kCmdLength = 2;
}

#pragma mark - Mode Tab Actions

- (IBAction) chkModePaddleSwap:(id)sender {
	//Toggle 1 swap, 0 normal
	kCommand[kCmdLength + 1] = 0x0e;
	if ([oModeSwapChkBox state] == 0) {
		MODEREGISTER = MODEREGISTER & 0xf7;			//Clear the Paddle Swap bit of the MODEREGISTER.
	}else {
		MODEREGISTER = MODEREGISTER | 0x08;			//Set the Paddle Swap bit of the MODEREGISTER.
	}
	kCommand[kCmdLength + 2] = MODEREGISTER;
	kCmdLength = 2;
}

- (IBAction) chkModeAutoSpace:(id)sender {
	//Toggle 1 autospace 0 normal
	kCommand[kCmdLength + 1] = 0x0e;
	if ([oModeAutoSpaceChkBox state] == 0) {
		MODEREGISTER = MODEREGISTER & 0xfd;			//Clear the AutoSpace bit of the MODEREGISTER.
	} else {
		MODEREGISTER = MODEREGISTER | 0x02;			//Set the AutoSpace bit of the MODEREGISTER.
	}
	kCommand[kCmdLength + 2] = MODEREGISTER;
	kCmdLength = 2;
}

- (IBAction) chkModeCTSpace:(id)sender {
	//Toggle 1 CT space 0 normal
	kCommand[kCmdLength + 1] = 0x0e;
	if ([oModeCTSpaceChkBox state] == 0) {
		MODEREGISTER = MODEREGISTER & 0xfe;			//Clear the CTSpace bit of the MODEREGISTER.
	} else {
		MODEREGISTER = MODEREGISTER | 0x01;			//Set the CTSpace bit of the MODEREGISTER.
	}
	kCommand[kCmdLength + 2] = MODEREGISTER;
	kCmdLength = 2;
}

- (IBAction) chkModePaddleDog:(id)sender {
	//Toggle paddle watch dog on 1 off 0
	kCommand[kCmdLength + 1] = 0x0e;
	if ([oModePaddleDogChkBox state] == 0) {
		MODEREGISTER = MODEREGISTER & 0x7f;			//Clear the Paddle Watch Dog Disable bit of the MODEREGISTER.
	}else {
		MODEREGISTER = MODEREGISTER | 0x80;			//Set the Paddle Watch Dog Disable bit of the MODEREGISTER.
	}
	kCommand[kCmdLength + 2] = MODEREGISTER;
	kCmdLength = 2;
}

- (IBAction) chkModePaddleEcho:(id)sender {
	//Toggle paddle echo on 1 off 0
	kCommand[kCmdLength + 1] = 0x0e;
	if ([oModePaddleEchoChkBox state] == 0) {
		MODEREGISTER = MODEREGISTER & 0xbf;			//Clear the Paddle Echo bit of the MODEREGISTER.
	} else {
		MODEREGISTER = MODEREGISTER | 0x40;			//Set the Paddle Echo bit of the MODEREGISTER.
	}
	kCommand[kCmdLength + 2] = MODEREGISTER;
	kCmdLength = 2;
}

- (IBAction) chkModeSerialEcho:(id)sender {
	//Toggle serial echo on 1 off 0
	kCommand[kCmdLength + 1] = 0x0e;
	if ([oModeSerialEchoChkBox state] == 0) {
		MODEREGISTER = MODEREGISTER & 0xfb;			//Clear the Serial Echo bit of the MODEREGISTER.
	} else {
		MODEREGISTER = MODEREGISTER | 0x04;			//Set the Serial Echo bit of the MODEREGISTER.
	}
	kCommand[kCmdLength + 2] = MODEREGISTER;
	kCmdLength = 2;
}

- (IBAction) chkModeSideTonePaddleOnly:(id)sender {
	//Toggle SideTone with paddle only 1, paddle and serial 0
	kCommand[kCmdLength + 1] = 0x01;
	if ([oModeSTPaddleOnlyChkBox state] == TRUE) {
		kCommand[kCmdLength + 2] = SIDETONE | 0x80;
	} else {
		kCommand[kCmdLength + 2] = SIDETONE & 0x7f;
	}
	kCmdLength = 2;
}

- (IBAction)changeSpeedPot:(id)sender
{
    const unsigned char potMinimum = (unsigned char)[[NSUserDefaults standardUserDefaults] integerForKey:winKeyerMINPreferenceKey];
    const unsigned char potRange = (unsigned char)[[NSUserDefaults standardUserDefaults] integerForKey:winKeyerMAXPreferenceKey];
    const unsigned char command[4] = {kWKImmediateSetupSpeedPotCommand, potMinimum, potRange, 0xFF};
    [self.winkeyerPort sendData:bytesToData(command, 4)];
}

#ifdef NOT_OBE
- (IBAction) stepModeWPMPotMax:(id)sender {
	//increment speed pot max range to max 99
	[oModeWPMPotMax setIntValue:[sender integerValue]];
	kCommand[kCmdLength + 1] = 0x05;
	kCommand[kCmdLength + 2] = [oModeWPMPotMinStepper integerValue];
	kCommand[kCmdLength + 3] = [oModeWPMPotMaxStepper integerValue];
	kCommand[kCmdLength + 4] = 0x1f;
//	// dont leave it at max
//	kCommand[kCmdLength + 5] = 0x02;
//	kCommand[kCmdLength + 6] = [oKeyerWPMStepper integerValue];
	kCmdLength = 4;
}

- (IBAction) stepModeWPMPotMin:(id)sender {
	//Icrement speed pot min range to max value max range
	[oModeWPMPotMin setIntValue:[sender integerValue]];
	kCommand[kCmdLength + 1] = 0x05;
	kCommand[kCmdLength + 2] = [oModeWPMPotMinStepper integerValue];
	kCommand[kCmdLength + 3] = [oModeWPMPotMaxStepper integerValue];
	kCommand[kCmdLength + 4] = 0x1F;
	// dont leave it a min
	kCommand[kCmdLength + 5] = 0x02;
	kCommand[kCmdLength + 6] = [oKeyerWPMStepper integerValue];
	kCmdLength = 4;
}
#endif

#pragma mark - OutPut Tab Actions

- (IBAction) mnuOutputModePort1:(id)sender {
	//Select Port 1 Sidetone off
	kCommand[kCmdLength + 1] = 0x09;
	PINCONFIG = PINCONFIG & 0xf0;					//Clear the Port/Sidetone selection of PINCONFIG.
	[oOutputModePort1 setState:1];
	[oOutputModePort1ToneOn setState:0];
	[oOutputModePort1PTTOn setState:0];
	[oOutputModePort1ToneOnPTT setState:0];
	[oOutputModePort2 setState:0];
	[oOutputModePort2ToneOn setState:0];
	[oOutputModePort2PTTOn setState:0];
	[oOutputModePort2ToneOnPTT setState:0];
	PINCONFIG = PINCONFIG | 0x04;					//Set PINCONFIG to Port1 Sidetone OFF.
	kCommand[kCmdLength + 2] = PINCONFIG;
	kCmdLength = 2;
}

- (IBAction) mnuOutputModePort1ToneOn:(id)sender {
	//Select Port 1 Sidetone on
	kCommand[kCmdLength + 1] = 0x09;
	PINCONFIG = PINCONFIG & 0xf0;					//Clear the Port/Sidetone selection of PINCONFIG.
	[oOutputModePort1 setState:0];
	[oOutputModePort1ToneOn setState:1];
	[oOutputModePort1PTTOn setState:0];
	[oOutputModePort1ToneOnPTT setState:0];
	[oOutputModePort2 setState:0];
	[oOutputModePort2ToneOn setState:0];
	[oOutputModePort2PTTOn setState:0];
	[oOutputModePort2ToneOnPTT setState:0];
	PINCONFIG = PINCONFIG | 0x06;					//Set PINCONFIG to Port 1 Sidetone ON.
	kCommand[kCmdLength + 2] = PINCONFIG;
	kCmdLength = 2;
}

- (IBAction) mnuOutputModePort1PTTOn:(id)sender {
	//Select Port 1 PTT on
	kCommand[kCmdLength + 1] = 0x09;
	PINCONFIG = PINCONFIG & 0xf0;					//Clear the Port/Sidetone selection of PINCONFIG.
	[oOutputModePort1 setState:0];
	[oOutputModePort1ToneOn setState:0];
	[oOutputModePort1PTTOn setState:1];
	[oOutputModePort1ToneOnPTT setState:0];
	[oOutputModePort2 setState:0];
	[oOutputModePort2ToneOn setState:0];
	[oOutputModePort2PTTOn setState:0];
	[oOutputModePort2ToneOnPTT setState:0];
	PINCONFIG = PINCONFIG | 0x05;					//Set PINCONFIG to Port 1 Sidetone ON.
	kCommand[kCmdLength + 2] = PINCONFIG;
	kCmdLength = 2;
}

- (IBAction) mnuOutputModePort1ToneOnPTT:(id)sender {
	//Select Port 1 Sidetone PTT on
	kCommand[kCmdLength + 1] = 0x09;
	PINCONFIG = PINCONFIG & 0xf0;					//Clear the Port/Sidetone selection of PINCONFIG.
	[oOutputModePort1 setState:0];
	[oOutputModePort1ToneOn setState:0];
	[oOutputModePort1PTTOn setState:0];
	[oOutputModePort1PTTOn setState:0];
	[oOutputModePort1ToneOnPTT setState:1];
	[oOutputModePort2 setState:0];
	[oOutputModePort2ToneOn setState:0];
	[oOutputModePort2PTTOn setState:0];
	[oOutputModePort2ToneOnPTT setState:0];
	PINCONFIG = PINCONFIG | 0x07;					//Set PINCONFIG to Port 1 Sidetone ON.
	kCommand[kCmdLength + 2] = PINCONFIG;
	kCmdLength = 2;
}


- (IBAction) mnuOutputModePort2:(id)sender {
	//Select Port 2 Sidetone off
	kCommand[kCmdLength + 1] = 0x09;
	PINCONFIG = PINCONFIG & 0xf0;					//Clear the Port/Sidetone selection of PINCONFIG.
	[oOutputModePort1 setState:0];
	[oOutputModePort1ToneOn setState:0];
	[oOutputModePort1PTTOn setState:0];
	[oOutputModePort1ToneOnPTT setState:0];
	[oOutputModePort2 setState:1];
	[oOutputModePort2ToneOn setState:0];
	[oOutputModePort2PTTOn setState:0];
	[oOutputModePort2ToneOnPTT setState:0];
	PINCONFIG = PINCONFIG | 0x08;					//Set PINCONFIG to Port 2 Sidetone OFF.
	kCommand[kCmdLength + 2] = PINCONFIG;
	kCmdLength = 2;
}

- (IBAction) mnuOutputModePort2ToneOn:(id)sender {
	//Select Port 2 Sidetone on
	kCommand[kCmdLength + 1] = 0x09;
	PINCONFIG = PINCONFIG & 0xf0;					//Clear the Port/Sidetone selection of PINCONFIG.
	[oOutputModePort1 setState:0];
	[oOutputModePort1ToneOn setState:0];
	[oOutputModePort1PTTOn setState:0];
	[oOutputModePort1ToneOnPTT setState:0];
	[oOutputModePort2 setState:0];
	[oOutputModePort2ToneOn setState:1];
	[oOutputModePort2PTTOn setState:0];
	[oOutputModePort2ToneOnPTT setState:0];
	PINCONFIG = PINCONFIG | 0x0a;					//Set PINCONFIG to Port 2 Sidetone ON>
	kCommand[kCmdLength + 2] = PINCONFIG;
	kCmdLength = 2;
}

- (IBAction) mnuOutputModePort2PTTOn:(id)sender {
	//Select Port 2 PTT on
	kCommand[kCmdLength + 1] = 0x09;
	PINCONFIG = PINCONFIG & 0xf0;					//Clear the Port/Sidetone selection of PINCONFIG.
	[oOutputModePort1 setState:0];
	[oOutputModePort1ToneOn setState:0];
	[oOutputModePort1PTTOn setState:0];
	[oOutputModePort1ToneOnPTT setState:0];
	[oOutputModePort2 setState:0];
	[oOutputModePort2ToneOn setState:0];
	[oOutputModePort2PTTOn setState:1];
	[oOutputModePort2ToneOnPTT setState:0];
	PINCONFIG = PINCONFIG | 0x09;					//Set PINCONFIG to Port 2 Sidetone ON>
	kCommand[kCmdLength + 2] = PINCONFIG;
	kCmdLength = 2;
}

- (IBAction) mnuOutputModePort2ToneOnPTT:(id)sender {
	//Select Port 2 Sidetone on
	kCommand[kCmdLength + 1] = 0x09;
	PINCONFIG = PINCONFIG & 0xf0;					//Clear the Port/Sidetone selection of PINCONFIG.
	[oOutputModePort1 setState:0];
	[oOutputModePort1ToneOn setState:0];
	[oOutputModePort1PTTOn setState:0];
	[oOutputModePort1ToneOnPTT setState:0];
	[oOutputModePort2 setState:0];
	[oOutputModePort2ToneOn setState:0];
	[oOutputModePort2PTTOn setState:0];
	[oOutputModePort2ToneOnPTT setState:1];
	PINCONFIG = PINCONFIG | 0x0b;					//Set PINCONFIG to Port 2 Sidetone ON>
	kCommand[kCmdLength + 2] = PINCONFIG;
	kCmdLength = 2;
}

- (IBAction) mnuOutputSTFreq4k:(id)sender {
	//Select sidetone 4000Hz
	[oOutputSTFreq4k setState:1];
	[oOutputSTFreq2k setState:0];
	[oOutputSTFreq13k setState:0];
	[oOutputSTFreq1k setState:0];
	[oOutputSTFreq800 setState:0];
	[oOutputSTFreq666 setState:0];
	[oOutputSTFreq531 setState:0];
	[oOutputSTFreq500 setState:0];
	[oOutputSTFreq444 setState:0];
	[oOutputSTFreq400 setState:0];
	kCommand[kCmdLength + 1] = 0x01;
	if ([oModeSTPaddleOnlyChkBox state] == TRUE) {
		SIDETONE = 0x81;
		kCommand[kCmdLength + 2] = 0x81;
	} else {
		SIDETONE = 0x01;
		kCommand[kCmdLength + 2] = 0x01;
	}
	kCmdLength = 2;
}

- (IBAction) mnuOutputSTFreq2k:(id)sender {
	//Select sidetone 2000Hz
	[oOutputSTFreq4k setState:0];
	[oOutputSTFreq2k setState:1];
	[oOutputSTFreq13k setState:0];
	[oOutputSTFreq1k setState:0];
	[oOutputSTFreq800 setState:0];
	[oOutputSTFreq666 setState:0];
	[oOutputSTFreq531 setState:0];
	[oOutputSTFreq500 setState:0];
	[oOutputSTFreq444 setState:0];
	[oOutputSTFreq400 setState:0];
	kCommand[kCmdLength + 1] = 0x01;
	if ([oModeSTPaddleOnlyChkBox state] == TRUE) {
		SIDETONE = 0x82;
		kCommand[kCmdLength + 2] = 0x82;
	} else {
		SIDETONE = 0x02;
		kCommand[kCmdLength + 2] = 0x02;
	}
	kCmdLength = 2;
}

- (IBAction) mnuOutputSTFreq13k:(id)sender {
	//Select sidetone 1333Hz
	[oOutputSTFreq4k setState:0];
	[oOutputSTFreq2k setState:0];
	[oOutputSTFreq13k setState:1];
	[oOutputSTFreq1k setState:0];
	[oOutputSTFreq800 setState:0];
	[oOutputSTFreq666 setState:0];
	[oOutputSTFreq531 setState:0];
	[oOutputSTFreq500 setState:0];
	[oOutputSTFreq444 setState:0];
	[oOutputSTFreq400 setState:0];
	kCommand[kCmdLength + 1] = 0x01;
	if ([oModeSTPaddleOnlyChkBox state] == TRUE) {
		SIDETONE = 0x83;
		kCommand[kCmdLength + 2] = 0x83;
	} else {
		SIDETONE = 0x03;
		kCommand[kCmdLength + 2] = 0x03;
	}
	kCmdLength = 2;
}

- (IBAction) mnuOutputSTFreq1k:(id)sender {
	//Select sidetone 1000Hz
	[oOutputSTFreq4k setState:0];
	[oOutputSTFreq2k setState:0];
	[oOutputSTFreq13k setState:0];
	[oOutputSTFreq1k setState:1];
	[oOutputSTFreq800 setState:0];
	[oOutputSTFreq666 setState:0];
	[oOutputSTFreq531 setState:0];
	[oOutputSTFreq500 setState:0];
	[oOutputSTFreq444 setState:0];
	[oOutputSTFreq400 setState:0];
	kCommand[kCmdLength + 1] = 0x01;
	if ([oModeSTPaddleOnlyChkBox state] == TRUE) {
		SIDETONE = 0x84;
		kCommand[kCmdLength + 2] = 0x84;
	} else {
		SIDETONE = 0x04;
		kCommand[kCmdLength + 2] = 0x04;
	}
	kCmdLength = 2;
}

- (IBAction) mnuOutputSTFreq800:(id)sender {
	//Select sidetone 800Hz
	[oOutputSTFreq4k setState:0];
	[oOutputSTFreq2k setState:0];
	[oOutputSTFreq13k setState:0];
	[oOutputSTFreq1k setState:0];
	[oOutputSTFreq800 setState:1];
	[oOutputSTFreq666 setState:0];
	[oOutputSTFreq531 setState:0];
	[oOutputSTFreq500 setState:0];
	[oOutputSTFreq444 setState:0];
	[oOutputSTFreq400 setState:0];
	kCommand[kCmdLength + 1] = 0x01;
	if ([oModeSTPaddleOnlyChkBox state] == TRUE) {
		SIDETONE = 0x85;
		kCommand[kCmdLength + 2] = 0x85;
	} else {
		SIDETONE = 0x05;
		kCommand[kCmdLength + 2] = 0x05;
	}
	kCmdLength = 2;
}

- (IBAction) mnuOutputSTFreq666:(id)sender {
	//Select sidetone 666 Hz
	[oOutputSTFreq4k setState:0];
	[oOutputSTFreq2k setState:0];
	[oOutputSTFreq13k setState:0];
	[oOutputSTFreq1k setState:0];
	[oOutputSTFreq800 setState:0];
	[oOutputSTFreq666 setState:1];
	[oOutputSTFreq531 setState:0];
	[oOutputSTFreq500 setState:0];
	[oOutputSTFreq444 setState:0];
	[oOutputSTFreq400 setState:0];
	kCommand[kCmdLength + 1] = 0x01;
	if ([oModeSTPaddleOnlyChkBox state] == TRUE) {
		SIDETONE = 0x86;
		kCommand[kCmdLength + 2] = 0x86;
	} else {
		SIDETONE = 0x06;
		kCommand[kCmdLength + 2] = 0x06;
	}
	kCmdLength = 2;
}

- (IBAction) mnuOutputSTFreq531:(id)sender {
	//Select sidetone 531 Hz
	[oOutputSTFreq4k setState:0];
	[oOutputSTFreq2k setState:0];
	[oOutputSTFreq13k setState:0];
	[oOutputSTFreq1k setState:0];
	[oOutputSTFreq800 setState:0];
	[oOutputSTFreq666 setState:0];
	[oOutputSTFreq531 setState:1];
	[oOutputSTFreq500 setState:0];
	[oOutputSTFreq444 setState:0];
	[oOutputSTFreq400 setState:0];
	kCommand[kCmdLength + 1] = 0x01;
	if ([oModeSTPaddleOnlyChkBox state] == TRUE) {
		SIDETONE = 0x07;
		kCommand[kCmdLength + 2] = 0x87;
	} else {
		SIDETONE = 0x07;
		kCommand[kCmdLength + 2] = 0x07;
	}
	kCmdLength = 2;
}

- (IBAction) mnuOutputSTFreq500:(id)sender {
	//Select sidetone 500Hz
	[oOutputSTFreq4k setState:0];
	[oOutputSTFreq2k setState:0];
	[oOutputSTFreq13k setState:0];
	[oOutputSTFreq1k setState:0];
	[oOutputSTFreq800 setState:0];
	[oOutputSTFreq666 setState:0];
	[oOutputSTFreq531 setState:0];
	[oOutputSTFreq500 setState:1];
	[oOutputSTFreq444 setState:0];
	[oOutputSTFreq400 setState:0];
	kCommand[kCmdLength + 1] = 0x01;
	if ([oModeSTPaddleOnlyChkBox state] == TRUE) {
		SIDETONE = 0x88;
		kCommand[kCmdLength + 2] = 0x88;
	} else {
		SIDETONE = 0x08;
		kCommand[kCmdLength + 2] = 0x08;
	}
	kCmdLength = 2;
}

- (IBAction) mnuOutputSTFreq444:(id)sender {
	//Select sidetone 444Hz
	[oOutputSTFreq4k setState:0];
	[oOutputSTFreq2k setState:0];
	[oOutputSTFreq13k setState:0];
	[oOutputSTFreq1k setState:0];
	[oOutputSTFreq800 setState:0];
	[oOutputSTFreq666 setState:0];
	[oOutputSTFreq531 setState:0];
	[oOutputSTFreq500 setState:0];
	[oOutputSTFreq444 setState:1];
	[oOutputSTFreq400 setState:0];
	kCommand[kCmdLength + 1] = 0x01;
	if ([oModeSTPaddleOnlyChkBox state] == TRUE) {
		SIDETONE = 0x89;
		kCommand[kCmdLength + 2] = 0x89;
	} else {
		SIDETONE = 0x09;
		kCommand[kCmdLength + 2] = 0x09;
	}
	kCmdLength = 2;
}

- (IBAction) mnuOutputSTFreq400:(id)sender {
	//Select sidetone 400Hz
	[oOutputSTFreq4k setState:0];
	[oOutputSTFreq2k setState:0];
	[oOutputSTFreq13k setState:0];
	[oOutputSTFreq1k setState:0];
	[oOutputSTFreq800 setState:0];
	[oOutputSTFreq666 setState:0];
	[oOutputSTFreq531 setState:0];
	[oOutputSTFreq500 setState:0];
	[oOutputSTFreq444 setState:0];
	[oOutputSTFreq400 setState:1];
	kCommand[kCmdLength + 1] = 0x01;
	kCommand[kCmdLength + 2] = 0x0a;
	if ([oModeSTPaddleOnlyChkBox state] == TRUE) {
		SIDETONE = 0x8a;
		kCommand[kCmdLength + 2] = 0x8a;
	} else {
		SIDETONE = 0x0a;
		kCommand[kCmdLength + 2] = 0x0a;
	}
	kCmdLength = 2;
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

#pragma mark - NSTextViewDelegate

// oKeyerBufferDisplay Delegate

- (void) textDidChange:(NSNotification *)aNotification
{
    NSString* buffer = [oKeyerBufferDisplayField string];
    if (characterIndex < buffer.length) {
        NSString* stringToSend = [buffer substringFromIndex:characterIndex];     // extract the new data to send
        if (stringToSend.length > 32) {								// max length to WK2 chip
            stringToSend = [stringToSend substringToIndex:32];
        }
        characterIndex = characterIndex + stringToSend.length;		// update characterIndex
        stringToSend = [stringToSend uppercaseString];					// Edit the substring
        [self sendAsciiString:stringToSend];
    }
#ifdef NOT_OBE
    NSString *s;
    
    NSLog(@"KYBD %@", [oKeyerBufferDisplayField string]);
    s = [oKeyerBufferDisplayField string];
    if ([s length] < BS) {
        s = [s stringByAppendingString:@" EEEEEEEE "];
        [oKeyerBufferDisplayField setString:s];
    }
    BS = [s length];
    NSLog(@"KYBD %@", [oKeyerBufferDisplayField string]);
#endif
}

#pragma mark - Serial Comm Utilities

- (void)sendAsciiString:(NSString *)string
{
    if (self.winkeyerPort.isOpen) {
        [self.winkeyerPort sendData:[string dataUsingEncoding:NSASCIIStringEncoding]];
    } else {
        NSLog(@"%s PROGRAMMING ERROR: attempting to write %@ to closed port %@", __PRETTY_FUNCTION__, string, self.winkeyerPort.name);
    }
}

#pragma mark - ORSSerialPortDelegate

- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data
{
    if (data.length > 0) {
        for (int i = 0; i < data.length; i++) {
            unsigned char v = ((unsigned char*)data.bytes)[i] & 0xff;
            if (v < 32 || v > 0x7f ) {
                // parse the byte //
                if (v == 192) {
                    kWAIT = FALSE;
                    kBUSY = FALSE;
                    kBREAKIN = FALSE;
                    kXOFF = FALSE;
                    self.winKeyerStatusColor = [NSColor greenColor];
                } else {
                    if (v > 127 & v < 192) {
                        NSLog(@"Speed Pot = %d", v - 128);
                        if ([[NSUserDefaults standardUserDefaults] boolForKey:winKeyerLOCKPreferenceKey]) {
                            v = v - 128;
                            if (v < [oModeWPMPotMin intValue]) {
                                v = [oModeWPMPotMin intValue];
                            }
                            kCommand[kCmdLength + 1] = 0x02;
                            kCommand[kCmdLength + 2] = v;
                            kCmdLength = 2;
                            [[NSUserDefaults standardUserDefaults] setObject:@(v) forKey:winKeyerWPMPreferenceKey];
                        }
                    } else {
                        NSLog(@"STATUS");
                        if (v & 0x10) {
                            NSLog(@"     WAIT");
                            kWAIT = TRUE;
                            self.winKeyerStatusColor = [NSColor redColor];
                        } else {
                            kWAIT = FALSE;
                        }
                        if (v & 0x04) {
                            NSLog(@"     BUSY");
                            kBUSY = TRUE;
                            self.winKeyerStatusColor = [NSColor yellowColor];
                        } else {
                            kBUSY = FALSE;
                        }
                        if (v & 0x02) {
                            NSLog(@"     BREAK IN");
                            kBREAKIN = TRUE;
                        } else {
                            kBREAKIN = FALSE;
                        }
                        if (v & 0x01) {
                            NSLog(@"     XOFF");
                            kXOFF = TRUE;
                            self.winKeyerStatusColor = [NSColor redColor];
                        } else {
                            kXOFF = FALSE;
                        }
                    }
                }
                // end parse//
                //--						sprintf(tstr, "<%02X>", v);
                //--						s = tstr;
                //--						while (*s)rawBuffer[rawBytes++] = *s++;
                //--            } else {
                //--                rawBuffer[rawBytes++] = v;
                //--                buffer[bfrBytes] = v;
                //--                bfrBytes++;
                //--            }
            }
            // for debug
            //string = [[[NSString alloc]initWithBytes:rawBuffer length:rawBytes encoding:NSASCIIStringEncoding]autorelease];
            //--        string = [[NSString alloc]initWithBytes:buffer length:bfrBytes encoding:NSASCIIStringEncoding];
            //--        if ([string length] > 0) {
            //--            [self insertInput:string];
            //--        }
        }
    }
}

- (void)serialPort:(ORSSerialPort*)serialPort didReceiveResponse:(NSData*)responseData toRequest:(ORSSerialRequest*)request
{
    NSString* commandName = request.userInfo[@"CommandName"];
    if ([commandName isEqualToString:@"HostOpen"]) {
        unsigned char versionNumber = ((unsigned char*)[responseData bytes])[0];
        self.versionString = [NSString stringWithFormat:@"v%d", versionNumber];
        NSError* error = nil;
        BOOL versionIsValid = [self validateVersion:&error];
        if (versionIsValid) {
            NSDictionary* userInfo = @{@"CommandName": @"EchoTest"};
            ORSSerialRequest* request = [ORSSerialRequest requestWithDataToSend:bytesToData(kWKAdminEchoTestCommand, 3)
                                                                       userInfo:userInfo
                                                                timeoutInterval:1.0
                                                              responseEvaluator:^BOOL(NSData* inputData) {
                                                                  if (inputData.length != 1) return NO;
                                                                  unsigned char* echo = (unsigned char*)(inputData.bytes);
                                                                  if (echo[0] != 0x55) return NO;
                                                                  return YES;
                                                              }];
            [self.winkeyerPort sendRequest:request];
        } else {
            self.winKeyerStatusColor = [NSColor redColor];
            self.serialCommStatusColor = [NSColor redColor];
        }
    } else if ([commandName isEqualToString:@"EchoTest"]) {
        // Contrary to "Winkeyer2 IC v22 Interface and Operation Manual 6/6/2008", the
        // Admin Set WK2 Mode command is not recognized unless set *after* Host Mode is open.
        [self.winkeyerPort sendData:bytesToData(kWKAdminSetWK2ModeCommand, 2)];
        [self loadDefaults];
        self.serialCommStatusColor = [NSColor greenColor];
    } else {
        NSLog(@"%s unhandled request response name: %@", __PRETTY_FUNCTION__, commandName);
    }
}

- (void)serialPort:(ORSSerialPort*)serialPort requestDidTimeout:(ORSSerialRequest*)request
{
    NSString* errorDescription = [NSString stringWithFormat:@"WinKeyer command %@ timed out with no response after %.1f seconds.",
                                  request.userInfo[@"CommandName"], request.timeoutInterval];
    NSString* errorDetail = @"Confirm that the WinKeyer has a solid USB connection.";
    NSDictionary* errorDict = @{NSLocalizedDescriptionKey: errorDescription, NSLocalizedRecoverySuggestionErrorKey: errorDetail};
    NSError* error = [NSError errorWithDomain:@"com.k1gq.macwinkeyer" code:1 userInfo:errorDict];
    self.serialCommStatusColor = [NSColor redColor];
    [self.winkeyerPort close];
}

- (void)serialPortWasRemovedFromSystem:(ORSSerialPort *)serialPort
{
    if (!self.terminating && self.winkeyerPort == serialPort) {
        self.winkeyerPort = nil;
//TODO        if ([self.delegate respondsToSelector:@selector(deviceDidUnplug)]) {
//TODO            [self.delegate deviceDidUnplug];
//TODO        }
        NSAlert* alert = [[NSAlert alloc] init];
        alert.messageText = [NSString stringWithFormat:@"Serial port %@ for WinKeyer disappeared while in use.", self.winkeyerPort.name];
        alert.informativeText = @"Unplugging active USB connections is risky. You are responsible for unusual behavior or damage to equipment or data if you do it.";
        alert.alertStyle = NSCriticalAlertStyle;
        [alert runModal];
    }
}

#pragma mark -

- (BOOL)validateVersion:(NSError**)error
{
    // Version string format is vnn
    NSInteger version = [[self.versionString substringFromIndex:1] integerValue];
    if (version < 20) {
        if (error) {
            NSString* errorDescription = [NSString stringWithFormat:@"WinKeyer returned unsupported version: %ld.", version];
            NSString* errorDetail = @"Confirm that the WinKeyer version is 20 or newer.";
            NSDictionary* errorDict = @{NSLocalizedDescriptionKey: errorDescription, NSLocalizedRecoverySuggestionErrorKey: errorDetail};
            *error = [NSError errorWithDomain:@"com.k1gq.macwinkeyer" code:1 userInfo:errorDict];
        }
        [[NSUserDefaults standardUserDefaults] setObject:portNameNone forKey:winKeyerPORTPreferenceKey];
        self.versionString = @"";
        return NO;
    }
    return YES;
}

@end

