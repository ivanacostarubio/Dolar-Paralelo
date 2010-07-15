/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2010 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 * 
 * WARNING: This is generated code. Modify at your own risk and without support.
 */
#import <Foundation/Foundation.h>
#import "KrollContext.h"

@class TiHost;

@protocol TiEvaluator <NSObject>

- (TiHost*)host;

- (void)evalJS:(NSString*)code;

- (void)evalFile:(NSString*)file;

- (void)fireEvent:(id)listener withObject:(id)obj remove:(BOOL)yn thisObject:(id)thisObject_;

- (id)preloadForKey:(id)key;

- (KrollContext*)krollContext;

- (void)registerProxy:(id)proxy;

- (void)unregisterProxy:(id)proxy;


@end
