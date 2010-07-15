/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2010 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 * 
 * WARNING: This is generated code. Modify at your own risk and without support.
 */
#import "TiBase.h"
#import "KrollBridge.h"
#import "KrollCallback.h"
#import "KrollObject.h"
#import "TiHost.h"
#import "TopTiModule.h"
#import "TiUtils.h"
#import "TiApp.h"

extern BOOL const TI_APPLICATION_ANALYTICS;

@implementation dolarparaleloObject

-(id)initWithContext:(KrollContext*)context_ host:(TiHost*)host_ context:(id<TiEvaluator>)pageContext_ baseURL:(NSURL*)baseURL_
{
	TopTiModule *module = [[[TopTiModule alloc] _initWithPageContext:pageContext_] autorelease];
	[module setHost:host_];
	[module _setBaseURL:baseURL_];
	
	pageContext = pageContext_;
	
	if (self = [super initWithTarget:module context:context_])
	{
		modules = [[NSMutableDictionary alloc] init];
		host = [host_ retain];
		
		// pre-cache a few modules we always use
		TiModule *ui = [host moduleNamed:@"UI" context:pageContext_];
		[self addModule:@"UI" module:ui];
		
		if (TI_APPLICATION_ANALYTICS)
		{
			// force analytics to load on startup
			[host moduleNamed:@"Analytics" context:pageContext_];
		}
	}
	return self;
}

#if KROLLBRIDGE_MEMORY_DEBUG==1
-(id)retain
{
	NSLog(@"RETAIN: %@ (%d)",self,[self retainCount]+1);
	return [super retain];
}
-(oneway void)release 
{
	NSLog(@"RELEASE: %@ (%d)",self,[self retainCount]-1);
	[super release];
}
#endif

-(void)dealloc
{
	RELEASE_TO_NIL(host);
	RELEASE_TO_NIL(modules);
	[super dealloc];
}

-(void)gc
{
	[modules removeAllObjects];
	[properties removeAllObjects];
}

-(id)valueForKey:(NSString *)key
{
	id module = [modules objectForKey:key];
	if (module!=nil)
	{
		return module;
	}
	module = [host moduleNamed:key context:pageContext];
	if (module!=nil)
	{
		return [self addModule:key module:module];
	}
	//go against module
	return [super valueForKey:key];
}

-(void)setValue:(id)value forKey:(NSString *)key
{
	// can't delete at the dolarparalelo level so no-op
}

-(KrollObject*)addModule:(NSString*)name module:(TiModule*)module
{
	KrollObject *ko = [[[KrollObject alloc] initWithTarget:module context:context] autorelease];
	[modules setObject:ko forKey:name];
	return ko;
}

-(TiModule*)moduleNamed:(NSString*)name context:(id<TiEvaluator>)context
{
	return [modules objectForKey:name];
}
@end


@implementation KrollBridge

-(id)init
{
	if (self = [super init])
	{
#if KROLLBRIDGE_MEMORY_DEBUG==1
		NSLog(@"INIT: %@",self);
#endif
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(didReceiveMemoryWarning:)
													 name:UIApplicationDidReceiveMemoryWarningNotification  
												   object:nil]; 
	}
	return self;
}

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	if (proxies!=nil)
	{
		SEL sel = @selector(didReceiveMemoryWarning:);
		// we have to copy during traversal since proxies can be removed during
		for (id proxy in [NSArray arrayWithArray:proxies])
		{
			if ([proxy respondsToSelector:sel])
			{
				[proxy didReceiveMemoryWarning:notification];
			}
		}
	}
}


#if KROLLBRIDGE_MEMORY_DEBUG==1
-(id)retain
{
	NSLog(@"RETAIN: %@ (%d)",self,[self retainCount]+1);
	return [super retain];
}
-(oneway void)release 
{
	NSLog(@"RELEASE: %@ (%d)",self,[self retainCount]-1);
	[super release];
}
#endif

-(void)removeProxies
{
	if (proxies!=nil)
	{
		SEL sel = @selector(contextShutdown:);
		while ([proxies count] > 0)
		{
			id proxy = [proxies objectAtIndex:0];
			[proxy retain]; // hold while we work
			[proxies removeObjectAtIndex:0];
			if ([proxy respondsToSelector:sel])
			{
				[proxy contextShutdown:self];
			}
			[proxy release];
		}
	}
	RELEASE_TO_NIL(proxies);
}

-(void)dealloc
{
#if KROLLBRIDGE_MEMORY_DEBUG==1
	NSLog(@"DEALLOC: %@",self);
#endif
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
	
	[self removeProxies];
	RELEASE_TO_NIL(preload);
	RELEASE_TO_NIL(context);
	RELEASE_TO_NIL(_dolarparalelo);
	[super dealloc];
}

- (TiHost*)host
{
	return host;
}

- (KrollContext*) krollContext
{
	return context;
}

- (id)preloadForKey:(id)key
{
	if (preload!=nil)
	{
		return [preload objectForKey:key];
	}
	return nil;
}

- (void)boot:(id)callback url:(NSURL*)url_ preload:(NSDictionary*)preload_
{
	preload = [preload_ retain];
	[super boot:callback url:url_ preload:preload_];
	context = [[KrollContext alloc] init];
	context.delegate = self;
	[context start];
}

- (void)evalJS:(NSString*)code
{
	[context evalJS:code];
}

- (void)scriptError:(NSString*)message
{
	[[TiApp app] showModalError:message];
}

- (void)evalFileOnThread:(NSString*)path context:(KrollContext*)context_ 
{
	NSError *error = nil;
	TiValueRef exception = NULL;
	
	TiContextRef jsContext = [context_ context];
	 
	NSURL *url_ = [path hasPrefix:@"file:"] ? [NSURL URLWithString:path] : [NSURL fileURLWithPath:path];
	
	if (![path hasPrefix:@"/"] && ![path hasPrefix:@"file:"])
	{
		url_ = [NSURL URLWithString:path relativeToURL:url];
	}

	NSString *jcode = nil;
	
	if ([url_ isFileURL])
	{
		NSData *data = [TiUtils loadAppResource:url_];
		if (data==nil)
		{
			jcode = [NSString stringWithContentsOfFile:[url_ path] encoding:NSUTF8StringEncoding error:&error];
		}
		else
		{
			jcode = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
		}
	}
	else
	{
		jcode = [NSString stringWithContentsOfURL:url_ encoding:NSUTF8StringEncoding error:&error];
	}

	if (error!=nil)
	{
		NSLog(@"[ERROR] error loading path: %@, %@",path,error);
		
		// check for file not found a give a friendlier message
		if ([error code]==260 && [error domain]==NSCocoaErrorDomain)
		{
			[self scriptError:[NSString stringWithFormat:@"Could not find the file %@",[path lastPathComponent]]];
		}
		else 
		{
			[self scriptError:[NSString stringWithFormat:@"Error loading script %@. %@",[path lastPathComponent],[error description]]];
		}
		return;
	}

	NSMutableString *code = [[NSMutableString alloc] init];
	[code appendString:jcode];

	TiStringRef jsCode = TiStringCreateWithUTF8CString([code UTF8String]);
	TiStringRef jsURL = TiStringCreateWithUTF8CString([[url_ absoluteString] UTF8String]);

	// validate script
	// TODO: we do not need to do this in production app
	if (!TiCheckScriptSyntax(jsContext,jsCode,jsURL,1,&exception))
	{
		id excm = [KrollObject toID:context value:exception];
		NSLog(@"[ERROR] Syntax Error = %@",[TiUtils exceptionMessage:excm]);
		[self scriptError:[TiUtils exceptionMessage:excm]];
	}
	
	// only continue if we don't have any exceptions from above
	if (exception == NULL)
	{
		TiEvalScript(jsContext, jsCode, NULL, jsURL, 1, &exception);
		
		if (exception!=NULL)
		{
			id excm = [KrollObject toID:context value:exception];
			NSLog(@"[ERROR] Script Error = %@.",[TiUtils exceptionMessage:excm]);
			[self scriptError:[TiUtils exceptionMessage:excm]];
		}
	}

	[code release];
	TiStringRelease(jsCode);
	TiStringRelease(jsURL);
}

- (void)evalFile:(NSString*)path callback:(id)callback selector:(SEL)selector
{
	[context invokeOnThread:self method:@selector(evalFileOnThread:context:) withObject:path callback:callback selector:selector];
}

- (void)evalFile:(NSString *)file
{
	[context invokeOnThread:self method:@selector(evalFileOnThread:context:) withObject:file condition:nil];
}

- (void)fireEvent:(id)listener withObject:(id)obj remove:(BOOL)yn thisObject:(TiProxy*)thisObject_
{
	if ([listener isKindOfClass:[KrollCallback class]])
	{
		[context invokeEvent:listener args:[NSArray arrayWithObject:obj] thisObject:thisObject_];
	}
	else 
	{
		NSLog(@"[ERROR] listener callback is of a non-supported type: %@",[listener class]);
	}

}

-(void)injectPatches
{
	// called to inject any dolarparalelo patches in JS before a context is loaded... nice for 
	// setting up backwards compat type APIs
	
	NSMutableString *js = [[NSMutableString alloc] init];
	[js appendString:@"function alert(msg) { Ti.UI.createAlertDialog({title:'Alert',message:msg}).show(); };"];
	[self evalJS:js];
	[js release];
}

-(void)shutdown
{
#if KROLLBRIDGE_MEMORY_DEBUG==1
	NSLog(@"DESTROY: %@",self);
#endif
	
	if (shutdown==NO)
	{
		shutdown = YES;
		// fire a notification event to our listeners
		NSNotification *notification = [NSNotification notificationWithName:kKrollShutdownNotification object:self];
		[[NSNotificationCenter defaultCenter] postNotification:notification];
		
		[context stop];
	}
}

-(void)gc
{
	[context gc];
	[_dolarparalelo gc];
}

#pragma mark Delegate

-(void)willStartNewContext:(KrollContext*)kroll
{
}

-(void)didStartNewContext:(KrollContext*)kroll
{
	// create dolarparalelo global object
	NSString *basePath = (url==nil) ? [[NSBundle mainBundle] resourcePath] : [[url path] stringByDeletingLastPathComponent];
	_dolarparalelo = [[dolarparaleloObject alloc] initWithContext:kroll host:host context:self baseURL:[NSURL fileURLWithPath:basePath]];
	TiContextRef jsContext = [kroll context];
	TiValueRef tiRef = [KrollObject toValue:kroll value:_dolarparalelo];

	NSString *_dolarparaleloNS = [NSString stringWithFormat:@"T%sanium","it"];
	TiStringRef prop = TiStringCreateWithUTF8CString([_dolarparaleloNS UTF8String]);
	TiStringRef prop2 = TiStringCreateWithUTF8CString([[NSString stringWithFormat:@"%si","T"] UTF8String]);
	TiObjectRef globalRef = TiContextGetGlobalObject(jsContext);
	TiObjectSetProperty(jsContext, globalRef, prop, tiRef, NULL, NULL);
	TiObjectSetProperty(jsContext, globalRef, prop2, tiRef, NULL, NULL);
	TiStringRelease(prop);
	TiStringRelease(prop2);	
	
	// this is so that the compiled namespace will also get compiled in and linked
	// during compile this will be replaced with the project name and won't match above
	// but in xcode (not the project version) it'll be the same and we can ignore
	NSString *compiledNS = @"dolarparalelo";
	if (![compiledNS isEqualToString:_dolarparaleloNS])
	{
		TiStringRef prop3 = TiStringCreateWithUTF8CString([compiledNS UTF8String]);
		TiObjectSetProperty(jsContext, globalRef, prop3, tiRef, NULL, NULL);
		TiStringRelease(prop3);	
	}
	
	//if we have a preload dictionary, register those static key/values into our UI namespace
	//in the future we may support another top-level module but for now UI is only needed
	if (preload!=nil)
	{
		KrollObject *ti = (KrollObject*)[_dolarparalelo valueForKey:@"UI"];
		for (id key in preload)
		{
			id target = [preload objectForKey:key];
			KrollObject *ko = [[KrollObject alloc] initWithTarget:target context:context];
			[ti setStaticValue:ko forKey:key];
			[ko release];
		}
		[self injectPatches];
		[self evalFile:[url path] callback:self selector:@selector(booted)];	
	}
	else 
	{
		// now load the app.js file and get started
		NSURL *startURL = [host startURL];
		[self injectPatches];
		[self evalFile:[startURL absoluteString] callback:self selector:@selector(booted)];
	}
}

-(void)willStopNewContext:(KrollContext*)kroll
{
	if (shutdown==NO)
	{
		shutdown = YES;
		// fire a notification event to our listeners
		NSNotification *notification = [NSNotification notificationWithName:kKrollShutdownNotification object:self];
		[[NSNotificationCenter defaultCenter] postNotification:notification];
	}
	[_dolarparalelo gc];
}

-(void)didStopNewContext:(KrollContext*)kroll
{
	[self removeProxies];
	RELEASE_TO_NIL(_dolarparalelo);
	RELEASE_TO_NIL(context);
	RELEASE_TO_NIL(preload);
}

- (void)registerProxy:(id)proxy 
{
	if (proxies==nil)
	{ 
		CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
		callbacks.retain = NULL;
		callbacks.release = NULL; 
		proxies = (NSMutableArray*)CFArrayCreateMutable(nil, 50, &callbacks);
	}
	[proxies addObject:proxy];
}

- (void)unregisterProxy:(id)proxy
{
	if (proxies!=nil)
	{
		[proxies removeObject:proxy];
		if ([proxies count]==0)
		{
			RELEASE_TO_NIL(proxies);
		}
	}
}


@end