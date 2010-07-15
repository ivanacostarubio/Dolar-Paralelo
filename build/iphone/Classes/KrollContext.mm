/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2010 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 * 
 * WARNING: This is generated code. Modify at your own risk and without support.
 */
#import "TiBase.h"
#import "KrollContext.h"
#import "KrollObject.h"
#import "KrollTimer.h"
#import "KrollCallback.h"
#import "TiUtils.h"

static unsigned short KrollContextIdCounter = 0;
static unsigned short KrollContextCount = 0;

@implementation KrollInvocation

-(id)initWithTarget:(id)target_ method:(SEL)method_ withObject:(id)obj_ condition:(NSCondition*)condition_
{
	if (self = [super init])
	{
		target = [target_ retain];
		method = method_;
		obj = [obj_ retain];
		condition = [condition_ retain];
	}
	return self;
}
-(id)initWithTarget:(id)target_ method:(SEL)method_ withObject:(id)obj_ callback:(id)callback_ selector:(SEL)selector_
{
	if (self = [super init])
	{
		target = [target_ retain];
		method = method_;
		obj = [obj_ retain];
		notify = [callback_ retain];
		notifySelector = selector_;
	}
	return self;
}
-(void)dealloc
{
	[target release];
	[obj release];
	[condition release];
	[notify release];
	[super dealloc];
}
-(void)invoke:(KrollContext*)context
{
	if (target!=nil)
	{
		[target performSelector:method withObject:obj withObject:context];
	}
	if (condition!=nil)
	{
		[condition lock];
		[condition signal];
		[condition unlock];
	}
	if (notify!=nil)
	{
		[notify performSelector:notifySelector];
	}
}

@end

TiValueRef ThrowException (TiContextRef ctx, NSString *message, TiValueRef *exception)
{
	TiStringRef jsString = TiStringCreateWithUTF8CString([message UTF8String]);
	*exception = TiValueMakeString(ctx,jsString);
	TiStringRelease(jsString);
	return TiValueMakeUndefined(ctx);
}

static NSLock *timerIDLock = [[NSLock alloc] init];

static TiValueRef MakeTimer(TiContextRef context, TiObjectRef jsFunction, TiValueRef fnRef, TiObjectRef jsThis, TiValueRef durationRef, BOOL onetime)
{
	static double kjsNextTimer = 0;
	[timerIDLock lock];
	double timerID = ++kjsNextTimer;
	
	KrollContext *ctx = GetKrollContext(context);
	TiGlobalContextRef globalContext = TiContextGetGlobalContext(context);
	TiValueRef exception = NULL;
	double duration = TiValueToNumber(context, durationRef, &exception);
	if (exception!=NULL)
	{
		NSLog(@"[ERROR] timer duration conversion failed");
	}
	KrollTimer *timer = [[KrollTimer alloc] initWithContext:globalContext function:fnRef jsThis:jsThis duration:duration onetime:onetime kroll:ctx timerId:timerID];
	[ctx registerTimer:timer timerId:timerID];
	[timer start];
	[timer release];
	[timerIDLock unlock];
	return TiValueMakeNumber(context, timerID);
}

static TiValueRef ClearTimerCallback (TiContextRef jsContext, TiObjectRef jsFunction, TiObjectRef jsThis, size_t argCount,
									  const TiValueRef args[], TiValueRef* exception)
{
	if (argCount!=1)
	{
		return ThrowException(jsContext, @"invalid number of arguments", exception);
	}

	KrollContext *ctx = GetKrollContext(jsContext);
	[ctx unregisterTimer:TiValueToNumber(jsContext,args[0],NULL)];

	return TiValueMakeUndefined(jsContext);
}	
static TiValueRef SetIntervalCallback (TiContextRef jsContext, TiObjectRef jsFunction, TiObjectRef jsThis, size_t argCount,
									   const TiValueRef args[], TiValueRef* exception)
{
	//NOTE: function can be either Function or String object type
	if (argCount!=2)
	{
		return ThrowException(jsContext, @"invalid number of arguments", exception);
	}
	
	TiValueRef fnRef = args[0];
	TiValueRef durationRef = args[1];
	
	return MakeTimer(jsContext, jsFunction, fnRef, jsThis, durationRef, NO);
}

static TiValueRef SetTimeoutCallback (TiContextRef jsContext, TiObjectRef jsFunction, TiObjectRef jsThis, size_t argCount,
									  const TiValueRef args[], TiValueRef* exception)
{
	if (argCount!=2)
	{
		return ThrowException(jsContext, @"invalid number of arguments", exception);
	}
	
	TiValueRef fnRef = args[0];
	TiValueRef durationRef = args[1];
	
	return MakeTimer(jsContext, jsFunction, fnRef, jsThis, durationRef, YES);
}

@implementation KrollEval

-(id)initWithCode:(NSString*)code_
{
	if (self = [super init])
	{
		code = [code_ copy];
	}
	return self;
}
-(void)dealloc
{
	[code release];
	[super dealloc];
}
-(void)invoke:(KrollContext*)context
{
	// evaluate our code in the Global Context
	TiStringRef js = TiStringCreateWithUTF8CString([code UTF8String]); 
	TiObjectRef global = TiContextGetGlobalObject([context context]);
	
	TiValueRef exception = NULL;
	
	TiEvalScript([context context], js, global, NULL, 1, &exception);

	if (exception!=NULL)
	{
		id excm = [KrollObject toID:context value:exception];
		NSLog(@"[ERROR] Script Error = %@",[TiUtils exceptionMessage:excm]);
		fflush(stderr);
	}
	
	TiStringRelease(js);
}

@end

@implementation KrollEvent

-(id)initWithCallback:(KrollCallback*)callback_ args:(NSArray*)args_ thisObject:(id)thisObject_
{
	if (self = [super init])
	{
		callback = [callback_ retain];
		args = [args_ retain];
		thisObject = [thisObject_ retain];
	}
	return self;
}
-(void)dealloc
{
	[thisObject release];
	[callback release];
	[args release];
	[super dealloc];
}
-(void)invoke:(KrollContext*)context
{
	[callback call:args thisObject:thisObject];
}
@end


@implementation KrollContext

@synthesize delegate;

-(NSString*)threadName
{
	return [NSString stringWithFormat:@"KrollContext<%@>",contextId];
}

-(id)init
{
	if (self = [super init])
	{
#if CONTEXT_MEMORY_DEBUG==1
		NSLog(@"INIT: %@",self);
#endif
		contextId = [[NSString stringWithFormat:@"kroll$%d",++KrollContextIdCounter] copy];
		condition = [[NSCondition alloc] init];
		queue = [[NSMutableArray alloc] init];
		timerLock = [[NSRecursiveLock alloc] init];
		[timerLock setName:[NSString stringWithFormat:@"%@ Timer Lock",[self threadName]]];
		lock = [[NSRecursiveLock alloc] init];
		[lock setName:[NSString stringWithFormat:@"%@ Lock",[self threadName]]];
		stopped = YES;
		KrollContextCount++;
	}
	return self;
}

-(void)destroy
{
#if CONTEXT_MEMORY_DEBUG==1
	NSLog(@"DESTROY: %@",self);
#endif
	[self stop];
	RELEASE_TO_NIL(condition);
	if (queue!=nil)
	{
		[queue removeAllObjects];
	}		
	RELEASE_TO_NIL(queue);
	RELEASE_TO_NIL(contextId);
	if (timerLock!=nil)
	{
		[timerLock lock];
		if (timers!=nil)
		{
			[timers removeAllObjects];
		}
		[timerLock unlock];
	}
	RELEASE_TO_NIL(timers);
	RELEASE_TO_NIL(lock);
	RELEASE_TO_NIL(timerLock);
}

#if CONTEXT_MEMORY_DEBUG==1
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
#if CONTEXT_MEMORY_DEBUG==1
	NSLog(@"DEALLOC: %@",self);
#endif
	assert(!destroyed);
	destroyed = YES;
	[self destroy];
	KrollContextCount--;
	[super dealloc];
}

-(NSString*)contextId
{
	return [[contextId retain] autorelease];
}

-(void)registerTimer:(id)timer timerId:(double)timerId
{
	[timerLock lock];
	if (timers==nil)
	{
		timers = [[NSMutableDictionary alloc] init];
	}
	NSString *key = [[NSNumber numberWithDouble:timerId] stringValue];
	[timers setObject:timer forKey:key];
	[timerLock unlock];
}

-(void)unregisterTimer:(double)timerId
{
	[timerLock lock];
	if (timers!=nil)
	{
		NSString *timer = [[NSNumber numberWithDouble:timerId] stringValue];
		KrollTimer *t = [timers objectForKey:timer];
		if (t!=nil)
		{
			[[t retain] autorelease];
			[timers removeObjectForKey:timer];
			[t cancel];
		}
		if ([timers count]==0)
		{
			// don't waste memory if we don't have any timers
			RELEASE_TO_NIL(timers);
		}
	}
	[timerLock unlock];
}

-(void)start
{
	if (stopped!=YES)
	{
		@throw [NSException exceptionWithName:@"org.dolarparalelo.kroll" 
									   reason:@"already started"
									 userInfo:nil];
	}
	stopped = NO;
	[NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
}

-(void)stop
{
	if (stopped == NO)
	{
		[condition lock];
		stopped = YES;
		[condition signal];
		[condition unlock];
	}
}

-(BOOL)running
{
	return stopped==NO;
}

-(TiGlobalContextRef)context
{
	return context;
}

#ifdef DEBUG
-(int)queueCount
{
	return [queue count];
}
#endif


-(BOOL)isKJSThread
{
	NSString *name = [[NSThread currentThread] name];
	return [name isEqualToString:[self threadName]];
}

-(void)invoke:(id)object
{
	[object invoke:self];
}

-(void)enqueue:(id)obj
{
	BOOL mythread = [self isKJSThread];
	
	if (!mythread) 
	{
		[lock lock];
	}
	
	[queue addObject:obj];
	
	if (!mythread)
	{
		[lock unlock];
		[condition lock];
		[condition signal];
		[condition unlock];
	}
}

-(void)evalJS:(NSString*)code
{
	KrollEval *eval = [[[KrollEval alloc] initWithCode:code] autorelease];
	if ([self isKJSThread])
	{
		[eval invoke:self];
		return;
	}
	[self enqueue:eval];
}

-(void)invokeOnThread:(id)callback_ method:(SEL)method_ withObject:(id)obj condition:(NSCondition*)condition_
{
	KrollInvocation *invocation = [[[KrollInvocation alloc] initWithTarget:callback_ method:method_ withObject:obj condition:condition_] autorelease];
	if ([self isKJSThread])
	{
		[invocation invoke:self];
		return;
	}
	[self enqueue:invocation];
}

-(void)invokeOnThread:(id)callback_ method:(SEL)method_ withObject:(id)obj callback:(id)callback selector:(SEL)selector_
{
	KrollInvocation *invocation = [[[KrollInvocation alloc] initWithTarget:callback_ method:method_ withObject:obj callback:callback selector:selector_] autorelease];
	if ([self isKJSThread])
	{
		[invocation invoke:self];
		return;
	}
	[self enqueue:invocation];
}

-(void)invokeEvent:(KrollCallback*)callback_ args:(NSArray*)args_ thisObject:(id)thisObject_
{
	KrollEvent *event = [[[KrollEvent alloc] initWithCallback:callback_ args:args_ thisObject:thisObject_] autorelease];
	[self enqueue:event];
}

- (void)bindCallback:(NSString*)name callback:(TiObjectCallAsFunctionCallback)fn
{
	// create the invoker bridge
	TiStringRef invokerFnName = TiStringCreateWithUTF8CString([name UTF8String]);
	TiValueRef invoker = TiObjectMakeFunctionWithCallback(context, NULL, fn);
	if (invoker)
	{
		TiObjectRef global = TiContextGetGlobalObject(context); 
		TiObjectSetProperty(context, global,   
							invokerFnName, invoker,   
							kTiPropertyAttributeReadOnly | kTiPropertyAttributeDontDelete,   
							NULL); 
	}
	TiStringRelease(invokerFnName);	
}

-(void)gc
{
	// don't worry about locking, not that important
	gcrequest = YES;
}

-(void)main
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[[NSThread currentThread] setName:[self threadName]];
	
	context = TiGlobalContextCreate(NULL);
	TiObjectRef globalRef = TiContextGetGlobalObject(context);
		
	TiGlobalContextRetain(context);
	
	// we register an empty kroll string that allows us to pluck out this instance
	KrollObject *kroll = [[KrollObject alloc] initWithTarget:nil context:self];
	TiValueRef krollRef = [KrollObject toValue:self value:kroll];
	TiStringRef prop = TiStringCreateWithUTF8CString("Kroll");
	TiObjectSetProperty(context, globalRef, prop, krollRef, NULL, NULL);
	TiObjectRef krollObj = TiValueToObject(context, krollRef, NULL);
	bool set = TiObjectSetPrivate(krollObj, self);
	assert(set);
	[kroll release];
	
	[self bindCallback:@"setTimeout" callback:&SetTimeoutCallback];
	[self bindCallback:@"setInterval" callback:&SetIntervalCallback];
	[self bindCallback:@"clearTimeout" callback:&ClearTimerCallback];
	[self bindCallback:@"clearInterval" callback:&ClearTimerCallback];

	if (delegate!=nil && [delegate respondsToSelector:@selector(willStartNewContext:)])
	{
		[delegate performSelector:@selector(willStartNewContext:) withObject:self];
	}
	
	unsigned int loopCount = 0;
	#define GC_LOOP_COUNT 5
	
	if (delegate!=nil && [delegate respondsToSelector:@selector(didStartNewContext:)])
	{
		[delegate performSelector:@selector(didStartNewContext:) withObject:self];
	}
	
	BOOL exit_after_flush = NO;
	
	while(1)
	{
		loopCount++;
		
		// we're stopped, we need to check to see if we have stuff that needs to
		// be executed before we can exit.  if we have stuff in the queue, we 
		// process just those events and then we immediately exit and clean up
		// otherwise, we can just exit immediately from here
		if (stopped)
		{
			exit_after_flush = YES;
			int queue_count = 0;
			
			[lock lock];
			queue_count = [queue count];
			[lock unlock];

			// we're stopped, nothing in the queue, time to bail
			if (queue_count==0)
			{
				break;
			}
		}
		
		NSAutoreleasePool *pool_ = [[NSAutoreleasePool alloc] init];
		
		// we have a pending GC request to try and reclaim memory
		if (gcrequest)
		{
#if CONTEXT_DEBUG == 1	
			NSLog(@"CONTEXT<%@>: forced garbage collection requested",self);
#endif
			TiGarbageCollect(context);
			loopCount = 0;
			gcrequest = NO;
		}
		
		BOOL stuff_in_queue = YES;
		
		// as long as we have stuff in the queue to process, we 
		// run our thread event pump and process events
		while (stuff_in_queue)
		{
			// don't hold the queue lock
			// while we're processing an event so we 
			// can't deadlock on recursive callbacks
			id entry = nil;
			[lock lock];
#if CONTEXT_DEBUG == 1	
			int queueSize = [queue count];
#endif
			if ([queue count] == 0)
			{
				stuff_in_queue = NO;
			}
			else 
			{
				entry = [queue objectAtIndex:0];
			}
			[lock unlock];
			if (entry!=nil)
			{
				@try 
				{
#if CONTEXT_DEBUG == 1	
					NSLog(@"CONTEXT<%@>: before action event invoke: %@, queue size: %d",self,entry,queueSize-1);
#endif
					[self invoke:entry];
#if CONTEXT_DEBUG == 1	
					NSLog(@"CONTEXT<%@>: after action event invoke: %@",self,entry);
#endif
				}
				@catch (NSException * e) 
				{
					// this should never happen as we raise a JS exception inside the 
					// method above but this is a guard anyway
					NSLog(@"[ERROR] application raised an exception. %@",e);
				}
				@finally 
				{
					[lock lock];
					[queue removeObjectAtIndex:0];
					[lock unlock];
				}				
			}
		}

		
		// TODO: experiment, attempt to collect more often than usual given our environment
		if (loopCount == GC_LOOP_COUNT)
		{
#if CONTEXT_DEBUG == 1	
			NSLog(@"CONTEXT<%@>: garbage collecting after loop count of %d exceeded (count=%d)",self,loopCount,KrollContextCount);
#endif
			TiGarbageCollect(context);
			loopCount = 0;
		}
		
		[pool_ drain];

		// check to see if we're already stopped and in the flush queue state, in which case,
		// we can now immediately exit
		if (exit_after_flush)
		{
			break;
		}
		
		
#if CONTEXT_DEBUG == 1	
		NSLog(@"CONTEXT<%@>: waiting for new event (count=%d)",self,KrollContextCount);
#endif
		
		[condition lock];
		[lock lock];
		int queue_count = [queue count];

		[lock unlock];
		if (queue_count == 0)
		{
			[condition wait];		
		}
		[condition unlock]; 
		
#if CONTEXT_DEBUG == 1	
		NSLog(@"CONTEXT<%@>: woke up for new event (count=%d)",self,KrollContextCount);
#endif
	}
	
	// call before we start the shutdown while context and timers are alive
	if (delegate!=nil && [delegate respondsToSelector:@selector(willStopNewContext:)])
	{
		[delegate performSelector:@selector(willStopNewContext:) withObject:self];
	}	
	
	[timerLock lock];
	// stop any running timers
	if (timers!=nil && [timers count]>0)
	{
		for (id timerId in [NSDictionary dictionaryWithDictionary:timers])
		{
			KrollTimer *t = [timers objectForKey:timerId];
			[t cancel];
		}
		[timers removeAllObjects];
	}
	[timerLock unlock]; 
	
	
	// now we can notify listeners we're done
	if (delegate!=nil && [delegate respondsToSelector:@selector(didStopNewContext:)])
	{
		[delegate performSelector:@selector(didStopNewContext:) withObject:self];
	}


#if CONTEXT_MEMORY_DEBUG==1
	NSLog(@"SHUTDOWN: %@",self);
	NSLog(@"KROLL RETAIN COUNT: %d",[kroll retainCount]);
#endif
	
	[self destroy];

	// cause the global context to be released and all objects internally to be finalized
	TiGlobalContextRelease(context);
	
	[kroll autorelease];
	[pool release];
}

@end
