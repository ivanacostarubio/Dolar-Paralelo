/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2010 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 * 
 * WARNING: This is generated code. Modify at your own risk and without support.
 */
#ifdef USE_TI_UITABLEVIEW
#define USE_TI_UISEARCHBAR
#endif

#ifdef USE_TI_UISEARCHBAR

#import "TiViewProxy.h"

@interface TiUISearchBarProxy : TiViewProxy {
}

-(void)setDelegate:(id<UISearchBarDelegate>)delegate;
-(UISearchBar*)searchBar;

@end

#endif