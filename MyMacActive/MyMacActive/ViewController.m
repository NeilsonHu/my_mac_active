//
//  ViewController.m
//  MyMacActive
//
//  Created by neilson on 2022-03-18.
//

#include <IOKit/pwr_mgt/IOPMLib.h>
#import "ViewController.h"

#define MyLog(x) [self _printAndChangeText:x]

@interface ViewController () {
    IBOutlet NSSwitch *switchButton;
    IBOutlet NSTextField *textLabel;
    IOPMAssertionID assertionID;
}
@end

@implementation ViewController

#pragma mark - override lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    textLabel.editable = NO;
    [textLabel setStringValue:@"Switch to active"];
}

#pragma mark - public methods

- (void)applicationWillTerminate {
    IOPMAssertionRelease(assertionID);
}

#pragma mark - private methods

- (void)_printAndChangeText:(NSString *)string {
    NSLog(@"%@", string);
    [textLabel setStringValue:string];
}

#pragma mark - IBAction methods

- (IBAction)onSwitchButtonChangedValue:(NSSwitch *)sender {
    // NOTE: IOPMAssertionCreateWithName limits the string to 128 characters.
    CFStringRef reasonForActivity= CFSTR("Active By Custom");

    if (sender.state == NSControlStateValueOff /*0*/) {
        IOReturn success = IOPMAssertionRelease(assertionID);
        // The system will be able to sleep again.
        if (success == kIOReturnSuccess) {
            MyLog(@"Auto Sleep Enabled.");
        } else {
            sender.state = NSControlStateValueOn;
            MyLog(@"Keep Active...");
        }
    } else if (sender.state == NSControlStateValueOn /*1*/) {
        IOReturn success = IOPMAssertionCreateWithName(kIOPMAssertPreventUserIdleDisplaySleep,
                                                       kIOPMAssertionLevelOn,
                                                       reasonForActivity,
                                                       &assertionID);
        if (success == kIOReturnSuccess) {
            MyLog(@"Keep Active...");
        } else {
            sender.state = NSControlStateValueOff;
            MyLog(@"Auto Sleep Enabled.");
        }
    }
}

@end
