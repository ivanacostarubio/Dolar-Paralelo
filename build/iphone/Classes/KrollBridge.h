/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2010 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 * 
 * WARNING: This is generated code. Modify at your own risk and without support.
 */

#import <Foundation/Foundation.h>
#import "Bridge.h"
#import "Ti.h"
#import "TiEvaluator.h"
#import "TiProxy.h"
#import "KrollContext.h"
#import "KrollObject.h"
#import "TiModule.h"

@interface dolarparaleloObject : KrollObject {
@private
	NSMutableDictionary *modules;
	TiHost *host;
	id<TiEvaluator> pageContext;
}
-(id)initWithContext:(KrollContext*)context_ host:(TiHost*)host_ context:(id<TiEvaluator>)context baseURL:(NSURL*)baseURL_;
-(KrollObject*)addModule:(NSString*)name module:(TiModule*)module;
-(TiModule*)moduleNamed:(NSString*)name context:(id<TiEvaluator>)context;
@end


@interface KrollBridge : Bridge<TiEvaluator,KrollDelegate> {
@private
	KrollContext *context;
	NSDictionary *preload;
	dolarparaleloObject *_dolarparalelo;
	BOOL shutdown;
	NSMutableArray *proxies;
}
- (void)boot:(id)callback url:(NSURL*)url preload:(NSDictionary*)preload;
- (void)evalJS:(NSString*)code;

- (void)fireEvent:(id)listener withObject:(id)obj remove:(BOOL)yn thisObject:(TiProxy*)thisObject;
- (id)preloadForKey:(id)key;
- (KrollContext*)krollContext;

@end


