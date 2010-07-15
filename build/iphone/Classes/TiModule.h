/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2010 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 * 
 * WARNING: This is generated code. Modify at your own risk and without support.
 */
#import "TiUtils.h"
#import "TiEvaluator.h"

@class TiHost;

@interface TiModule : TiProxy 
{
@protected
	TiHost *host;
@private
	CFMutableDictionaryRef classNameLookup;
}

-(void)setPageContext:(id<TiEvaluator>)evaluator;
-(void)setHost:(TiHost*)host;
-(id)createProxy:(NSArray*)args forName:(NSString*)name context:(id<TiEvaluator>)evaluator;
-(void)startup;
-(void)shutdown:(id)sender;

@end
