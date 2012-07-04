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
#import "ClosePoi.h"
#import "Direction.h"
#import "Line.h"
#import "Poi.h"
#import "Polyline.h"
#import "Stop.h"
#import "StopAlias.h"
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
    stopOldSrcId = [NSMutableDictionary dictionaryWithCapacity:700];
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
    if ( insertedObjects > 10000 ) {
        [self flushContext];
    }
}


-(id)loadRemoteJsonFor:(NSString*)pathComponent {
    NSString* path = [NSString stringWithFormat:@"%@/%@.json", baseUrl, pathComponent];
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:path]];
    id json = [data yajl_JSON];
    return json;
}

-(void)loadCities{
    NSArray* cities_data = [self loadRemoteJsonFor:@"cities"];
    NSLog( @"cities: %lu", [cities_data count] );
    for( NSDictionary* attributes in cities_data ) {
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
        [stopOldSrcId setValue:[stopInfo objectAtIndex:2]
                     forKey:[[stopInfo objectAtIndex:0] stringValue]];
    }
}

-(NSDictionary*) loadDirections:(Line*)line withId:(NSString*)dbId {
    NSArray* directions = [self loadRemoteJsonFor:[NSString stringWithFormat:@"lines/%@/headsigns", dbId]];
    NSMutableDictionary* dir_dict = [NSMutableDictionary dictionaryWithCapacity:150];
    for( NSDictionary* attributes in directions ) {
        Direction* direction = [Direction insertInManagedObjectContext:context];
        insertedObjects++;
        direction.headsign = [attributes objectForKey:@"name"];
        direction.line = line;
        [dir_dict setValue:direction forKey:[[attributes objectForKey:@"id"] stringValue]];
    }
    return dir_dict;
}

-(void) loadPolylines:(Line*)line withId:(NSString*)dbId {
    NSArray* polylines = [self loadRemoteJsonFor:[NSString stringWithFormat:@"lines/%@/polylines", dbId]];
    for( NSDictionary* attributes in polylines ) {
        Polyline* polyline = [Polyline insertInManagedObjectContext:context];
        insertedObjects++;
        polyline.path = [attributes objectForKey:@"path"];
        polyline.line = line;
    }
}

-(NSDictionary*) loadTrips:(NSString*)dbId {
    NSArray* tripsData = [self loadRemoteJsonFor:[NSString stringWithFormat:@"lines/%@/bearings", dbId]];
    NSMutableDictionary* trips = [NSMutableDictionary dictionaryWithCapacity:530];
    for( NSDictionary* trip in tripsData ) {
        NSString* bearing = [trip objectForKey:@"br"] ;
        if ( bearing != nil && bearing != (id)[NSNull null]) {
            [trips setValue:bearing forKey:[[trip objectForKey:@"id"] stringValue] ];
        }
    }
    return trips;
}


NSNumber* incCounter( NSNumber* num ) {
    int count = [num intValue] + 1;
    return [NSNumber numberWithInt:count];
}

-(int) loadStopTimesOfLine:(Line*)line withLineId:(NSString*)lineId atStop:(Stop*)stop withStopId:(NSString*)stopId withDirections:(NSDictionary*)dir_dict withBearings:(NSDictionary*)trips{
    NSArray* stop_times = [self loadRemoteJsonFor:[NSString stringWithFormat:@"lines/%@/stops/%@/stop_times", lineId, stopId]];
    int added_stop_times = 0;
    for( NSDictionary* attributes in stop_times ) {
        StopTime* stopTime = [StopTime insertInManagedObjectContext:context];
        insertedObjects++;
        stopTime.arrival = [attributes objectForKey:@"arrival"];
        stopTime.departure = [attributes objectForKey:@"departure"];
        stopTime.calendar = [attributes objectForKey:@"calendar"];
        stopTime.trip_id = [attributes objectForKey:@"trip_id"];
        stopTime.stop_sequence = [attributes objectForKey:@"stop_sequence"];
        NSString* bearing = [trips objectForKey:[stopTime.trip_id stringValue]];
        if( bearing != nil && ( bearing != (id)[NSNull null] ) ){
            stopTime.trip_bearing = bearing;
        }
        stopTime.line = line;
        stopTime.stop = stop;
        stopTime.direction = [dir_dict objectForKey:[[attributes objectForKey:@"headsign_id"] stringValue]];
        ++added_stop_times;
    }
    return added_stop_times;
}

void incTypeCounter(Stop* stop, NSString* name ) {
    NSString* attrName = [NSString stringWithFormat:@"%@_count", name];
    int count = [[stop valueForKey:attrName] intValue]+1;
    [stop setValue:[NSNumber numberWithInt:count] forKey:attrName];
}

-(void) loadStopAliasesFor: (Stop*)stop withId:(NSString*) stop_id {
    NSArray* stop_aliases = [self loadRemoteJsonFor:[NSString stringWithFormat:@"stops/%@/stop_aliases", stop_id]];
    for( NSDictionary* attributes in stop_aliases ) {
        StopAlias* stopAlias = [StopAlias insertInManagedObjectContext:context];
        insertedObjects++;
        stopAlias.src_code = [attributes objectForKey:@"src_code"];
        stopAlias.src_id = [attributes objectForKey:@"src_id"];
        id old_src_id = [attributes objectForKey:@"old_src_id"];
        if ( old_src_id != [NSNull null] ) {
            stopAlias.old_src_id = old_src_id;
        }
        stopAlias.stop = stop;
    }
}

-(void)loadProximity {
    NSMutableDictionary* stored_pois = [NSMutableDictionary dictionaryWithCapacity:230];
    for( NSString* stop_id in [storedStops allKeys] ) {
        Stop* stop = [storedStops objectForKey:stop_id];
        NSDictionary* stop_pois = [self loadRemoteJsonFor:[NSString stringWithFormat:@"stops/%@/close", stop_id]];
        for( NSString* poi_name in [stop_pois allKeys] ) {
            NSArray* pois = [stop_pois objectForKey:poi_name];
            for( NSDictionary* jspoi in pois ) {
                NSString* key = [NSString stringWithFormat:@"%@-%@", 
                                 poi_name, [jspoi objectForKey:@"id"]];
                Poi* poi = [stored_pois objectForKey:key];
                if ( nil == poi ) {
                    poi = [Poi insertInManagedObjectContext:context];
                    poi.name = [jspoi objectForKey:@"name"];
                    id address = [jspoi objectForKey:@"address"];
                    if( address != nil && ( address != (id)[NSNull null] ) ){
                        poi.address = address;
                    }
                    poi.lat = [NSDecimalNumber decimalNumberWithDecimal:[[jspoi objectForKey:@"lat"] decimalValue]];
                    poi.lon = [NSDecimalNumber decimalNumberWithDecimal:[[jspoi objectForKey:@"lon"] decimalValue]];
                    poi.type = poi_name;
                    [stored_pois setObject:poi forKey:key];
                }
                ClosePoi* cpoi = [ClosePoi insertInManagedObjectContext:context];
                cpoi.poi = poi;
                cpoi.distance = [jspoi objectForKey:@"distance"];
                [[stop close_poisSet] addObject:cpoi];
                incTypeCounter( stop, poi_name );
            }
        }
    }
}

-(void)project {
    [context setUndoManager:nil];
    [self loadCities];
    [self loadStopSrcID];
    
    
    NSArray* lines_data = [self loadRemoteJsonFor:@"lines"];
    int stop_times_added = 0;
    for( NSDictionary* attributes in lines_data ) {
        Line* line = [Line insertInManagedObjectContext:context];
        insertedObjects++;
        NSString* dbId = [attributes objectForKey:@"id"];
        line.short_name = [attributes objectForKey:@"short_name"];
        line.long_name = [attributes objectForKey:@"short_long_name"];
        line.src_id = [attributes objectForKey:@"src_id"];
        if ( line.src_id == (id)[NSNull null] ) {
            NSLog( @"Invalid src_id for %@", line.long_name );
        }
        line.bgcolor = [attributes objectForKey:@"bgcolor"];
        line.fgcolor = [attributes objectForKey:@"fgcolor"];
        line.usage = [attributes objectForKey:@"usage"];
        id old_line_id = [attributes objectForKey:@"old_src_id"];
        if ( old_line_id != [NSNull null] ) {
            line.old_src_id = old_line_id;
        }
        id picto_url = [attributes objectForKey:@"picto_url"];
        if ( picto_url != (id)[NSNull null] ) {
            id picto_url_url = [picto_url objectForKey:@"url"];
            if ( picto_url_url != (id)[NSNull null] ) {
                line.has_picto = [NSNumber numberWithBool:([picto_url_url length] > 0)];
            } else {
                line.has_picto = [NSNumber numberWithBool:NO];
            }
        } else {
            line.has_picto = [NSNumber numberWithBool:NO];
        }
        line.forced_id = [NSNumber numberWithInt:[line.short_name intValue]];
        line.accessible = [attributes objectForKey:@"accessible"];
        NSDictionary* dir_dict = [self loadDirections:line withId:dbId];
        [self loadPolylines:line withId:dbId];
        
        NSDictionary* trips = [self loadTrips:dbId];
        
        NSArray* stops = [self loadRemoteJsonFor:[NSString stringWithFormat:@"lines/%@/stops", dbId]];
        for( NSDictionary* stop_attributes in stops ) {
            NSString* stop_id = [[stop_attributes objectForKey:@"id"] stringValue];
            Stop* stop = [storedStops objectForKey:stop_id];
            if ( nil == stop ) {
                stop = [Stop insertInManagedObjectContext:context];
                insertedObjects++;
                stop.name = [stop_attributes objectForKey:@"name"];
                stop.src_id = [stopSrcId objectForKey:stop_id];
                if ( stop.src_id == (id)[NSNull null] ) {
                    NSLog( @"Wrong src_id for stop %@", stop.name );
                }
                id old_id = [stopOldSrcId objectForKey:stop_id];
                if ( old_id != [NSNull null] ) {
                    stop.old_src_id = old_id;
                }
                if ( [stop_attributes objectForKey:@"lat"] != [NSNull null]) {
                    stop.lat = [NSDecimalNumber decimalNumberWithDecimal:[[stop_attributes objectForKey:@"lat"] decimalValue]];
                    stop.lon = [NSDecimalNumber decimalNumberWithDecimal:[[stop_attributes objectForKey:@"lon"] decimalValue]];
                }
                stop.slug = [stop_attributes objectForKey:@"slug"];
                stop.accessible = [stop_attributes objectForKey:@"accessible"];
                City* city = [cities objectForKey:[stop_attributes objectForKey:@"city_id"]];
                stop.city = city;
                city.stop_count = incCounter( city.stop_count );
                stop.line_count = [NSNumber numberWithInt:0];
                [self loadStopAliasesFor:stop withId:(NSString*)stop_id];
                [storedStops setValue:stop forKey:stop_id];
            }
            [[line stopsSet] addObject:stop];
            stop.line_count = incCounter( stop.line_count );
            stop_times_added += [self loadStopTimesOfLine:line withLineId:dbId atStop:stop withStopId:stop_id withDirections:dir_dict withBearings:trips];
        }
        NSLog( @"stoptimes added: %d", stop_times_added );        
        [self flushIf];
    }
    NSLog( @"%lu lines", [lines_data count] );
    [self loadProximity];
    [self flushContext];
}

@end
