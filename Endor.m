//
//  Endor.m
//  Endor
//
//  Created by Sebastien Tanguy on 01/23/11.
//  Copyright dthg.net 2011 . All rights reserved.
//

#import <objc/objc-auto.h>
#import "Generator.h"


NSManagedObjectModel *managedObjectModel();
NSManagedObjectContext *managedObjectContext();


int main (int argc, const char * argv[]) {
	
    objc_startCollectorThread();
	
	// Create the managed object context
    NSManagedObjectContext *context = managedObjectContext();
	
    // Custom code here...

    if ( argc != 2 ) {
        NSLog( @"Usage: %s http://server/dump/", argv[0] );
        exit( 1 );
    }
    NSString* BASE_URL = [NSString stringWithUTF8String:argv[1]];

    Generator* generator = [[Generator alloc] initWithBaseUrl:BASE_URL andContext:context];
    [generator project];
    
    // Save the managed object context
    NSError *error = nil;    
    if (![context save:&error]) {
        NSLog(@"Error while saving\n%@",
              ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        exit(1);
    }
    return 0;
}



NSManagedObjectModel *managedObjectModel() {
    
    static NSManagedObjectModel *model = nil;
    
    if (model != nil) {
        return model;
    }
    
    NSString *path = [[[NSProcessInfo processInfo] arguments] objectAtIndex:0];
    path = [path stringByDeletingLastPathComponent];
    NSURL *modelURL = [NSURL fileURLWithPath:[path stringByAppendingPathComponent:@"Transit.mom"]];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return model;
}



NSManagedObjectContext *managedObjectContext() {
	
    static NSManagedObjectContext *context = nil;
    if (context != nil) {
        return context;
    }
    
    context = [[NSManagedObjectContext alloc] init];
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: managedObjectModel()];
    [context setPersistentStoreCoordinator: coordinator];
    
    NSString *STORE_TYPE = NSSQLiteStoreType;
	
    NSString *path = [[[NSProcessInfo processInfo] arguments] objectAtIndex:0];
    path = [path stringByDeletingPathExtension];
    path = [path stringByAppendingPathExtension:@"sqlite"];
    unlink( [path UTF8String] );
    NSURL *url = [NSURL fileURLWithPath:path];
    
    NSError *error;
    NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:nil error:&error];
    
    if (newStore == nil) {
        NSLog(@"Store Configuration Failure\n%@",
              ([error localizedDescription] != nil) ?
              [error localizedDescription] : @"Unknown Error");
    }
    
    return context;
}

