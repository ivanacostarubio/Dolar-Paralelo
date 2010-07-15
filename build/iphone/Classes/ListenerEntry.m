/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2010 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 * 
 * WARNING: This is generated code. Modify at your own risk and without support.
 */
#import "ListenerEntry.h"


@implementation ListenerEntry

-(void)contextShutdown:(NSNotification*)note
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kKrollShutdownNotification object:context];
	removed=YES;
	if (type!=nil)
	{
		[proxy removeEventListener:[NSArray arrayWithObjects:type,listener,nil]];
	}
	RELEASE_TO_NIL(context);
}

-(id)initWithListener:(id)listener_ context:(id<TiEvaluator>)context_ proxy:(TiProxy*)proxy_ type:(NSString*)type_
{
	if (self = [super init])
	{
		assert(context_);
		listener = [listener_ retain];
		context = [context_ retain];
		proxy = [proxy_ retain];
		type = [type_ retain];
		// since a context can get shutdown while we're holding him.. we listener for shutdown events so we can automatically remove ourselves
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextShutdown:) name:kKrollShutdownNotification object:context];
	}
	return self;
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kKrollShutdownNotification object:context];
	RELEASE_TO_NIL(listener);
	RELEASE_TO_NIL(type);
	RELEASE_TO_NIL(context);
	RELEASE_TO_NIL(proxy);
	[super dealloc];
}

-(id<TiEvaluator>)context
{
	return context;
}

-(id)listener
{
	return listener;
}

@end
