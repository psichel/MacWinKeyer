//
//  WinKeyerHostModePreferences.m
//  MacWinKeyer
//
//  Created by Willard Myers on 2017-04-20.
//
//

#import "WinKeyerHostModePreferences.h"

@implementation WinKeyerHostModePreferences

- (NSString *)preferenceIdentifier;
{
    return @"WinKeyerHostModePreferences";
}

- (NSString *)preferenceTitle
{
    return NSLocalizedString(@"Host Mode", @"Title of 'Host Mode' preference pane");
}

- (NSImage *)preferenceIcon
{
    return [NSImage imageNamed:@"PreferencesWinKeyerIcon"];
}

- (NSString *)preferenceToolTip
{
    return NSLocalizedString(@"Settings when connected to your WinKeyer", @"Tooltip of 'WinKeyer Host Mode' preference pane");
}

@end
