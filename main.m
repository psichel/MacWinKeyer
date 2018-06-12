//
//  main.m
//  WK24Mac
//
//  Created by James  T. Rogers on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
// K1GQ Renamed MacWinKeyer

#import <Cocoa/Cocoa.h>
#import "Preferences.h"

int main(int argc, char *argv[])
{
    [Preferences registerPreferenceDefaults];
    return NSApplicationMain(argc,  (const char **) argv);
}
