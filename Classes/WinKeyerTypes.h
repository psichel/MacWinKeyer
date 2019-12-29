//
//  WinKeyerTypes.h
//  MacWinKeyer
//
//  Created by Willard Myers on 2015-03-06.
//
//

#ifndef MacWinKeyer_WinKeyerTypes_h
#define MacWinKeyer_WinKeyerTypes_h

typedef NS_ENUM(NSInteger, WinKeyerType) {
    WinKeyerTypeSMT = 1,
    WinKeyerTypeDIP = 2,
    WinKeyerTypeDUO = 3,
    WinKeyerTypeMINI = 4
};

// Enumerated types associated with radio button matrix indicies in UI
typedef NS_ENUM(NSUInteger, SidetoneFrequencyType) {
    Sidetone400Hz = 0,
    Sidetone444Hz,
    Sidetone500Hz,
    Sidetone571Hz,
    Sidetone666Hz,
    Sidetone800Hz,
    Sidetone1000Hz,
    Sidetone1333Hz,
    Sidetone2000Hz,
    Sidetone4000Hz
};

typedef NS_ENUM(NSUInteger, PaddleModeType) {
    PaddleModeIambicB = 0,
    PaddleModeIambicA,
    PaddleModeUltimatic,
    PaddleModeBug
};

typedef NS_ENUM(NSUInteger, UltimaticPriorityType) {
    UltimaticPriorityNormal = 0,
    UltimaticPriorityDah,
    UltimaticPriorityDit
};

typedef NS_ENUM(NSUInteger, HangTimeType) {
    HangTimeShortest = 0,
    HangTimeShort,
    HangTimeLong,
    HangTimeLongest
};

typedef struct {
    uint8 magic;		//0x00
    uint8 modereg;	    //0x01
    uint8 oprrate;	    //0x02
    uint8 stconst;	    //0x03
    uint8 kweight;	    //0x04
    uint8 lead_time;	//0x05
    uint8 tail_time;	//0x06
    uint8 min_wpm;	    //0x07
    uint8 wpm_range;	//0x08
    uint8 xtnd;		    //0x09
    uint8 kcomp;		//0x0a
    uint8 farnswpm;	    //0x0b
    uint8 sampadj;	    //0x0c
    uint8 ratio;		//0x0d
    uint8 pincfg;	    //0x0e
    uint8 k12mode;	    //0x0f
    uint8 cmdwpm;	    //0x10
    uint8 freeptr;	    //0x11
    uint8 msgptr1;	    //0x12
    uint8 msgptr2;	    //0x13
    uint8 msgptr3;	    //0x14
    uint8 msgptr4;	    //0x15
    uint8 msgptr5;	    //0x16
    uint8 msgptr6;	    //0x17
    uint8 msgs[232];    //0x18
} WK2EEPROM;

typedef struct {
    uint8 modereg1;     // 0x00  1
    uint8 favewpm1;     // 0x01  2
    uint8 stconst1;     // 0x02  3
    uint8 weight1;      // 0x03  4
    uint8 lead_time1;   // 0x04  5
    uint8 tail_time1;   // 0x05  6
    uint8 minwpm1;      // 0x06  7
    uint8 wpmrange1;    // 0x07  8
    uint8 x2mode1;      // 0x08  9
    uint8 kcomp1;       // 0x09  10
    uint8 farnswpm1;    // 0x0a  11
    uint8 sampadj1;     // 0x0b  12
    uint8 ratio1;       // 0x0c  13
    uint8 pincfg1;      // 0x0d  14
    uint8 x1mode1;      // 0x0e  15
    uint8 cmdwpm1;      // 0x0f  16
    uint8 modereg2;     // 0x10  17
    uint8 favewpm2;     // 0x11  18
    uint8 stconst2;     // 0x12  19
    uint8 weight2;      // 0x13  20
    uint8 lead_time2;   // 0x14  21
    uint8 tail_time2;   // 0x15  22
    uint8 minwpm2;      // 0x16  23
    uint8 wpmrange2;    // 0x17  24
    uint8 x2mode2;      // 0x18  25
    uint8 kcomp2;       // 0x19  26
    uint8 farnswpm2;    // 0x1a  27
    uint8 sampadj2;     // 0x1b  28
    uint8 ratio2;       // 0x1c  29
    uint8 pincfg2;      // 0x1d  30
    uint8 x1mode2;      // 0x1e  31
    uint8 cmdwpm2;      // 0x1f  32
    uint8 freeptr;      // 0x00  1
    uint8 msgptr1;      // 0x01  2
    uint8 msgptr2;      // 0x02  3
    uint8 msgptr3;      // 0x03  4
    uint8 msgptr4;      // 0x04  5
    uint8 msgptr5;      // 0x05  6
    uint8 msgptr6;      // 0x06  7
    uint8 msgptr7;      // 0x07  8
    uint8 msgptr8;      // 0x08  9
    uint8 msgptr9;      // 0x09  10
    uint8 msgptr10;     // 0x0A  11
    uint8 msgptr11;     // 0x0B  12
    uint8 msgptr12;     // 0x0C  13
    uint8 mycallptr1;   // 0x0D  14
    uint8 mycallptr2;   // 0x0E  15
    uint8 msgs[241];    // 0x0F  16-256
} WK3EEPROM;

#endif
