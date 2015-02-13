/*
 *  vntts.h
 *  vnspeech
 *
 *  Created by bm on 5/13/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>


extern "C"{
    bool vntts(NSString* strInput, char* wavFilePath, int nVolume,NSString* sPath);}
extern "C"{ char* g_lpszVNTTSDataPath;}