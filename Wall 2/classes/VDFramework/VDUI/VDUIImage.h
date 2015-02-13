//
//  VDUIImage.h
//  VDFramework
//
//  Created by dolam on 9/21/10.
//  Copyright 2010 VietDorje. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (TPAdditions)
- (UIImage*)imageScaledToSize:(CGSize)size;
@end

@interface VDUIImage : UIImage 
{
    
}

- (UIImage*)imageScaledToSize:(CGSize)size;

@end
