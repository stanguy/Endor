//
//  Generator.h
//  Endor
//
//  Created by Sebastien Tanguy on 01/23/11.
//  Copyright 2011 dthg.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Generator : NSObject {

    NSString* baseUrl;
    NSMutableDictionary* storedStops;
    NSDictionary* cities;
    NSDictionary* stopSrcId;
    NSDictionary* stopOldSrcId;
    
    NSManagedObjectContext* context;
    
    int insertedObjects;
    
}

-(Generator*) initWithBaseUrl:(NSString*)url andContext:(NSManagedObjectContext*)pcontext;
-(void)project;

@end
