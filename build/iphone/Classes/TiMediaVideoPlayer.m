/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2010 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 * 
 * WARNING: This is generated code. Modify at your own risk and without support.
 */
#ifdef USE_TI_MEDIA

#import "TiMediaVideoPlayer.h"
#import "TiUtils.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2

@implementation TiMediaVideoPlayer

-(id)initWithPlayer:(MPMoviePlayerController*)controller_
{
	if (self = [super initWithFrame:CGRectZero])
	{
		[self setMovie:controller_];
	}
	return self;
}

-(void)setMovie:(MPMoviePlayerController*)controller_
{
	if (controller!=nil)
	{
		[[controller view] removeFromSuperview];
	}
	RELEASE_TO_NIL(controller);
	controller = [controller_ retain];
	[self addSubview:[controller view]];
	[self sendSubviewToBack:[controller view]];
}

-(void)dealloc
{
	if (controller!=nil)
	{
		[[controller view] removeFromSuperview];
	}
	RELEASE_TO_NIL(controller);
	[super dealloc];
}

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
	self.frame = CGRectIntegral(self.frame);
	[TiUtils setView:[controller view] positionRect:bounds];
}

@end

#endif

#endif