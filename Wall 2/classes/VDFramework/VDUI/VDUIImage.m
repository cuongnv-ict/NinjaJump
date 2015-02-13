//
//  VDUIImage.m
//  VDFramework
//
//  Created by dolam on 9/21/10.
//  Copyright 2010 VietDorje. All rights reserved.
//

#import "VDUIImage.h"
#import "VDUtilities.h"

@implementation UIImage (TPAdditions)
- (UIImage*)imageScaledToSize:(CGSize)size 
{
	float fscale = 1;
	if([self respondsToSelector:@selector(scale)])
		fscale = self.scale;
	size.width *= fscale;
	size.height *= fscale;
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (fscale == 2.0 && [UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)])
		return [UIImage imageWithCGImage:image.CGImage scale:2.0 orientation:UIImageOrientationUp];
	else 
		return [UIImage imageWithCGImage:image.CGImage];
	
}
@end

@implementation VDUIImage

-(id)initWithContentsOfFile:(NSString *)path
{
    path = [path stringByDeletingPathExtension];
	NSString* pathTemp = path;
    
	if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
		pathTemp = [pathTemp stringByAppendingString:@"-ipad"];
    else if ([VDUtilities isiPhone5Screen])
        pathTemp = [pathTemp stringByAppendingString:@"-568"];
    
    if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0)
        pathTemp = [pathTemp stringByAppendingString:@"@2x"];
    
    pathTemp = [pathTemp stringByAppendingString:@".png"];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && 
        ![[NSFileManager defaultManager] fileExistsAtPath:pathTemp])
    {
        // If image iPad @2x not exist, replace by image iPad
        // If image iPad not exist, replace by image iPhone @2x
        pathTemp = [path stringByAppendingString:@"-ipad.png"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:pathTemp])
            pathTemp = [path stringByAppendingString:@"@2x.png"];
    }  
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathTemp])
        pathTemp = [path stringByAppendingString:@"@2x.png"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathTemp])
        pathTemp = [path stringByAppendingString:@".png"];
    
    return [super initWithContentsOfFile:pathTemp];
}

+ (UIImage*)imageWithContentsOfFile:(NSString *)path
{
	path = [path stringByDeletingPathExtension];
	NSString* pathTemp = path;
    
	UIImage* retImage = nil;
	
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
		pathTemp = [pathTemp stringByAppendingString:@"-ipad"];
    if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0)
        pathTemp = [pathTemp stringByAppendingString:@"@2x"];
    
    pathTemp = [pathTemp stringByAppendingString:@".png"];
    
    // If image iPad not exist, replace by iphone @2x image
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && 
        ![[NSFileManager defaultManager] fileExistsAtPath:pathTemp])
    {
        // If image iPad @2x not exist, replace by image iPad
        // If image iPad not exist, replace by image iPhone @2x
        pathTemp = [path stringByAppendingString:@"-ipad.png"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:pathTemp])
        {
            pathTemp = [path stringByAppendingString:@"@2x.png"];
            retImage = [super imageWithContentsOfFile:pathTemp];
            if (!retImage)
                retImage = [super imageWithContentsOfFile:[path stringByAppendingString:@".png"]];
            retImage = [UIImage imageWithCGImage:[retImage CGImage] scale:1.0 orientation:UIImageOrientationUp];
            
            return retImage;
        }
    }
    
    retImage = [super imageWithContentsOfFile:pathTemp];
    if (!retImage)
        retImage = [super imageWithContentsOfFile:[path stringByAppendingString:@".png"]];
 
    if (!retImage)
        retImage = [super imageWithContentsOfFile:[path stringByAppendingString:@".jpg"]];
  
    if (!retImage)
        retImage = [super imageWithContentsOfFile:path];

    return retImage;
}

// Overrides the initWithImage method to handle @2x files
+ (UIImage*)imageNamed:(NSString*) path
{
    path = [path stringByDeletingPathExtension];
	NSString* pathTemp = path;
    
	UIImage* retImage = nil;
	
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
		pathTemp = [pathTemp stringByAppendingString:@"-ipad"];
    
    //if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0)
    //    pathTemp = [pathTemp stringByAppendingString:@"@2x"];

    pathTemp = [pathTemp stringByAppendingString:@".png"];
    retImage = [super imageNamed:pathTemp];
    
    
    // If image iPad not exist, replace by iphone @2x image
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && !retImage)
    {
        if([UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0)
        {
            pathTemp = [path stringByAppendingString:@"@2x.png"];
            retImage = [super imageNamed:pathTemp];
        }
        
        if (!retImage)
            retImage = [super imageNamed:[path stringByAppendingString:@".png"]];
      
      
        if (retImage)
        {
            float fScreenlScale = 1.0;
            float flImageScale = 1.0;
            
            if([UIScreen instancesRespondToSelector:@selector(scale)])
                fScreenlScale = [[UIScreen mainScreen] scale];
            if([UIImage instancesRespondToSelector:@selector(scale)])
                flImageScale = [retImage scale];
            if (flImageScale < 1.0) flImageScale = 1;
            
            if (fScreenlScale != flImageScale)
                retImage = [UIImage imageWithCGImage:[retImage CGImage] scale:fScreenlScale orientation:UIImageOrientationUp];
        }

            
    }
    else if (!retImage)
    {
        pathTemp = [path stringByAppendingString:@".png"];
        retImage = [super imageNamed:pathTemp];
    }
    
    if (!retImage)
        retImage = [super imageNamed:[path stringByAppendingString:@".jpg"]];

//    if (retImage)
//    {
//        float fScreenlScale = 1.0;
//        float flImageScale = 1.0;
//        
//        if([UIScreen instancesRespondToSelector:@selector(scale)])
//            fScreenlScale = [[UIScreen mainScreen] scale];
//        if([UIImage instancesRespondToSelector:@selector(scale)])
//            flImageScale = [retImage scale];
//        if (flImageScale < 1.0) flImageScale = 1;
//        
//        if (fScreenlScale != flImageScale)
//            retImage = [UIImage imageWithCGImage:[retImage CGImage] scale:fScreenlScale orientation:UIImageOrientationUp];
//    }

    
    return retImage;
}


/*
 // Overrides the initWithImage method to handle @2x files
 + (UIImage*)imageNamed:(NSString*) path
 {
 path = [path stringByDeletingPathExtension];
 NSString* pathTemp = nil;
 UIImage* retImage = nil;
 // Load image for iPad
 if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
 {
 pathTemp = [path stringByAppendingString:@"-ipad.png"];
 retImage =[super imageNamed:pathTemp];
 if (retImage)
 return retImage;
 
 // If image iPad not exist, replace by @2x image
 pathTemp = [path stringByAppendingString:@"@2x.png"];
 retImage =[super imageNamed:pathTemp];
 
 if (retImage)
 {
 float fScreenlScale = 1.0;
 float flImageScale = 1.0;
 
 if([UIScreen instancesRespondToSelector:@selector(scale)])
 fScreenlScale = [[UIScreen mainScreen] scale];
 if([UIImage instancesRespondToSelector:@selector(scale)])
 flImageScale = [retImage scale];
 if (flImageScale < 1.0) flImageScale = 1;
 
 if (fScreenlScale != flImageScale)
 retImage = [UIImage imageWithCGImage:[retImage CGImage] scale:fScreenlScale orientation:UIImageOrientationUp];
 }
 
 if (retImage)
 return retImage;
 }
 
 pathTemp = [path stringByAppendingString:@".png"];
 return [super imageNamed:pathTemp];
 }
 */

//free memory
-(void) dealloc{
	[super dealloc];
}


@end
