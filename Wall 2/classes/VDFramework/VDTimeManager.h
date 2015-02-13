//
//  VDTimeManager.h
//  vietradio
//
//  Created by DoLam on 2/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#ifndef VDTIMEMANAGER_SAFE_ENDTIMER
#define VDTIMEMANAGER_SAFE_ENDTIMER(p) if( p != nil ){ [p invalidate]; p = nil; }
#endif
#define kNotifyVDTimeManager_CurrentTimeMinuteChanged	@"notifyVDTimeManager_CurrentTimeMinuteChanged"

@interface VDTimeManager : NSObject 
{
	NSTimer *mTimerMinuteChanged;
}
- (void)startTimerMinuteChanged;
- (void)stopTimerMinuteChanged;

@end
