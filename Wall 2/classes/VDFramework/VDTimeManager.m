//
//  VDTimeManager.mm
//  vietradio
//
//  Created by DoLam on 2/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VDTimeManager.h"


@implementation VDTimeManager

- (void)startTimerMinuteChanged
{
	int ti = [NSDate timeIntervalSinceReferenceDate];
	int nSecToNextMinute = 60 - (ti % 60) + 1;
	// Check on timer schedule for first minute
	VDTIMEMANAGER_SAFE_ENDTIMER(mTimerMinuteChanged);
	
	mTimerMinuteChanged = [NSTimer scheduledTimerWithTimeInterval:nSecToNextMinute target:self 
															   selector:@selector(onTimerFirstMinuteChanged) userInfo:nil repeats:YES];
}

- (void)notifyMinuteChanged
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotifyVDTimeManager_CurrentTimeMinuteChanged object:self];
}

- (void)onTimerFirstMinuteChanged
{
	VDTIMEMANAGER_SAFE_ENDTIMER(mTimerMinuteChanged);
	// Check onTimer schedule every minutes
	mTimerMinuteChanged= [NSTimer scheduledTimerWithTimeInterval:60 target:self 
															   selector:@selector(notifyMinuteChanged) userInfo:nil repeats:YES];
	[self notifyMinuteChanged];
	
}

- (void)stopTimerMinuteChanged
{
	VDTIMEMANAGER_SAFE_ENDTIMER(mTimerMinuteChanged);
}

- (void)dealloc
{
	[super dealloc];
	VDTIMEMANAGER_SAFE_ENDTIMER(mTimerMinuteChanged);
}
@end
