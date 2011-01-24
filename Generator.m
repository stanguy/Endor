//
//  Generator.m
//  Endor
//
//  Created by Sebastien Tanguy on 01/23/11.
//  Copyright 2011 dthg.net. All rights reserved.
//

#import "Generator.h"
#import <YAJL/YAJL.h>

#import "City.h"
#import "Direction.h"
#import "Line.h"
#import "Stop.h"
#import "StopTime.h"


@implementation Generator


-(Generator*) initWithBaseUrl:(NSString*)url andContext:(NSManagedObjectContext*)pcontext{
    self = [super init];
    baseUrl = [url retain];
    context = [pcontext retain];
    insertedObjects = 0;
    storedStops = [NSMutableDictionary dictionaryWithCapacity:700] ; // magic
    cities = [NSMutableDictionary dictionaryWithCapacity:40];
    stopSrcId = [NSMutableDictionary dictionaryWithCapacity:700];
    return self;
}

-(void) flushContext {
    // Save the managed object context
    NSError *error = nil;    
    if (![context save:&error]) {
        NSLog(@"Error while saving\n%@",
              ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        if ( [error code] == NSValidationMultipleErrorsError ) {
            NSArray *detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
            NSUInteger i, displayErrors = [detailedErrors count];
            for( i = 0; i < displayErrors; ++i ) {
                NSLog(@"%@\n", [[detailedErrors objectAtIndex:i] localizedDescription]);
            }
        }
        exit(1);
    }
    //[context reset];
    insertedObjects = 0;
}

-(void) flushIf {
    if ( insertedObjects > 1000 ) {
        [self flushContext];
    }
}


-(NSArray*)loadRemoteJsonFor:(NSString*)pathComponent {
    NSString* path = [NSString stringWithFormat:@"%@/%@.json", baseUrl, pathComponent];
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:path]];
    NSArray* json = [data yajl_JSON];
    return json;
}

-(void)loadCities{
    NSArray* cities_data = [self loadRemoteJsonFor:@"cities"];
    NSLog( @"cities: %d", [cities_data count] );
    for( NSDictionary* container in cities_data ) {
        NSDictionary* attributes = [container objectForKey:@"city"];
        City* city = [City insertInManagedObjectContext:context];
        city.name = [attributes objectForKey:@"name"];
        city.stop_count = [NSNumber numberWithInt:0];
        [cities setValue:city forKey:[attributes objectForKey:@"id"]];
    }
}

-(void)loadStopSrcID {
    NSArray* data = [self loadRemoteJsonFor:@"stops/main_ids"];
    for( NSArray* stopInfo in data ) {
        [stopSrcId setValue:[stopInfo objectAtIndex:1]
                     forKey:[[stopInfo objectAtIndex:0] stringValue]];
    }
}

-(NSDictionary*) loadDirections:(Line*)line withId:(NSString*)dbId {
    NSArray* directions = [self loadRemoteJsonFor:[NSString stringWithFormat:@"lines/%@/headsigns", dbId]];
    NSMutableDictionary* dir_dict = [NSMutableDictionary dictionaryWithCapacity:150];
    for( NSDictionary* container in directions ) {
        NSDictionary* attributes = [container objectForKey:@"headsign"];
        Direction* direction = [Direction insertInManagedObjectContext:context];
        insertedObjects++;
        direction.headsign = [attributes objectForKey:@"name"];
        direction.line = line;
        [dir_dict setValue:direction forKey:[[attributes objectForKey:@"id"] stringValue]];
    }
    return dir_dict;
}

NSNumber* incCounter( NSNumber* num ) {
    int count = [num intValue] + 1;
    return [NSNumber numberWithInt:count];
}

-(int) loadStopTimesOfLine:(Line*)line withLineId:(NSString*)lineId atStop:(Stop*)stop withStopId:(NSString*)stopId withDirections:(NSDictionary*)dir_dict{
    NSArray* stop_times = [self loadRemoteJsonFor:[NSString stringWithFormat:@"lines/%@/stops/%@/stop_times", lineId, stopId]];
    int added_stop_times = 0;
    for( NSDictionary* container in stop_times ) {
        NSDictionary* attributes = [container objectForKey:@"stop_time"];
        StopTime* stopTime = [StopTime insertInManagedObjectContext:context];
        insertedObjects++;
        stopTime.arrival = [attributes objectForKey:@"arrival"];
        stopTime.departure = [attributes objectForKey:@"departure"];
        stopTime.calendar = [attributes objectForKey:@"calendar"];
        stopTime.trip_id = [attributes objectForKey:@"trip_id"];
        stopTime.line = line;
        stopTime.stop = stop;
        stopTime.direction = [dir_dict objectForKey:[[attributes objectForKey:@"headsign_id"] stringValue]];
        ++added_stop_times;
    }
    return added_stop_times;
}

-(void)project {
    [context setUndoManager:nil];
    [self loadCities];
    [self loadStopSrcID];
    
    
    NSArray* lines_data = [self loadRemoteJsonFor:@"lines"];
    int stop_times_added = 0;
    for( NSDictionary* container in lines_data ) {
        Line* line = [Line insertInManagedObjectContext:context];
        insertedObjects++;
        NSDictionary* attributes = [container objectForKey:@"line"];
        NSString* dbId = [attributes objectForKey:@"id"];
        line.short_name = [attributes objectForKey:@"short_name"];
        line.long_name = [attributes objectForKey:@"short_long_name"];
        line.src_id = [attributes objectForKey:@"src_id"];
        line.bgcolor = [attributes objectForKey:@"bgcolor"];
        line.fgcolor = [attributes objectForKey:@"fgcolor"];
        line.usage = [attributes objectForKey:@"usage"];
        line.has_picto = [NSNumber numberWithBool:([[attributes objectForKey:@"picto_url"] length] > 0)];
        line.forced_id = [NSNumber numberWithInt:[line.short_name intValue]];
        NSDictionary* dir_dict = [self loadDirections:line withId:dbId];
        
        NSArray* stops = [self loadRemoteJsonFor:[NSString stringWithFormat:@"lines/%@/stops", dbId]];
        for( NSDictionary* stop_container in stops ) {
            NSDictionary* stop_attributes = [stop_container objectForKey:@"stop"];
            NSString* stop_id = [[stop_attributes objectForKey:@"id"] stringValue];
            Stop* stop = [storedStops objectForKey:stop_id];
            if ( nil == stop ) {
                stop = [Stop insertInManagedObjectContext:context];
                insertedObjects++;
                stop.name = [stop_attributes objectForKey:@"name"];
                stop.src_id = [stopSrcId objectForKey:stop_id];
                stop.lat = [NSDecimalNumber decimalNumberWithDecimal:[[stop_attributes objectForKey:@"lat"] decimalValue]];
                stop.lon = [NSDecimalNumber decimalNumberWithDecimal:[[stop_attributes objectForKey:@"lon"] decimalValue]];
                City* city = [cities objectForKey:[stop_attributes objectForKey:@"city_id"]];
                stop.city = city;
                city.stop_count = incCounter( city.stop_count );
                stop.line_count = [NSNumber numberWithInt:0];
                
                [storedStops setValue:stop forKey:stop_id];
            }
            [[line stopsSet] addObject:stop];
            stop.line_count = incCounter( stop.line_count );
            stop_times_added += [self loadStopTimesOfLine:line withLineId:dbId atStop:stop withStopId:stop_id withDirections:dir_dict];
        }
        NSLog( @"stoptimes added: %d", stop_times_added );        
        [self flushIf];
    }
    NSLog( @"%d", [lines_data count] );
    [self flushContext];
}

@end
