/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2010 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 * 
 * WARNING: This is generated code. Modify at your own risk and without support.
 */
#ifdef USE_TI_UIIPHONENAVIGATIONGROUP

#import "TiUIiPhoneNavigationGroup.h"
#import "TiUtils.h"
#import "TiWindowProxy.h"

@implementation TiUIiPhoneNavigationGroup

-(void)dealloc
{
	RELEASE_TO_NIL(controller);
	[super dealloc];
}

-(UINavigationController*)controller
{
	if (controller==nil)
	{
		TiWindowProxy* windowProxy = [self.proxy valueForKey:@"window"];
		if (windowProxy==nil)
		{
			[self throwException:@"window property required" subreason:nil location:CODELOCATION];
		}
		UIViewController *rootController = [windowProxy controller];	
		controller = [[UINavigationController alloc] initWithRootViewController:rootController];
		[controller setDelegate:self];
		windowProxy.navController = controller;
		[self addSubview:controller.view];
       [controller.view addSubview:[windowProxy view]];
		[windowProxy setupWindowDecorations];
		current = windowProxy;
		root = windowProxy;
	}
	return controller;
}

-(void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
	if (controller!=nil)
	{
		[TiUtils setView:controller.view positionRect:bounds];
	}
}

#pragma mark Public APIs

-(void)setWindow_:(id)window
{
	[self controller];
}

-(void)open:(TiWindowProxy*)window withObject:(NSDictionary*)properties
{
	BOOL animated = [TiUtils boolValue:@"animated" properties:properties def:YES];
	UIViewController *viewController = [window controller];
	current = window;
	opening = YES;
	[controller pushViewController:viewController animated:animated];
    [window setupWindowDecorations];
}

-(void)close:(TiWindowProxy*)window withObject:(NSDictionary*)properties
{
	[window retain];
	[window close:nil];
	[window autorelease];
}

#pragma mark Delegate 

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    TiWindowProxy *newWindow = [(TiWindowViewController*)viewController proxy];
    [newWindow setupWindowDecorations];
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	TiWindowViewController *wincontroller = (TiWindowViewController*)viewController;
	TiWindowProxy *newWindow = [wincontroller proxy];
	if (newWindow==current || newWindow==root)
	{
		return;
	}
	
	if (newWindow!=current)
	{
		if (current!=root && opening==NO)
		{
			[self close:current withObject:nil];
		}
		current = newWindow;
	}
	opening = NO;
}


@end

#endif