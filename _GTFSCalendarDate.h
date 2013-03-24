// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to GTFSCalendarDate.h instead.

#import <CoreData/CoreData.h>


extern const struct GTFSCalendarDateAttributes {
	__unsafe_unretained NSString *exception_date;
	__unsafe_unretained NSString *is_exclusion;
} GTFSCalendarDateAttributes;

extern const struct GTFSCalendarDateRelationships {
	__unsafe_unretained NSString *calendar;
} GTFSCalendarDateRelationships;

extern const struct GTFSCalendarDateFetchedProperties {
} GTFSCalendarDateFetchedProperties;

@class GTFSCalendar;




@interface GTFSCalendarDateID : NSManagedObjectID {}
@end

@interface _GTFSCalendarDate : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (GTFSCalendarDateID*)objectID;





@property (nonatomic, strong) NSDate* exception_date;



//- (BOOL)validateException_date:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* is_exclusion;



@property BOOL is_exclusionValue;
- (BOOL)is_exclusionValue;
- (void)setIs_exclusionValue:(BOOL)value_;

//- (BOOL)validateIs_exclusion:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) GTFSCalendar *calendar;

//- (BOOL)validateCalendar:(id*)value_ error:(NSError**)error_;





@end

@interface _GTFSCalendarDate (CoreDataGeneratedAccessors)

@end

@interface _GTFSCalendarDate (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveException_date;
- (void)setPrimitiveException_date:(NSDate*)value;




- (NSNumber*)primitiveIs_exclusion;
- (void)setPrimitiveIs_exclusion:(NSNumber*)value;

- (BOOL)primitiveIs_exclusionValue;
- (void)setPrimitiveIs_exclusionValue:(BOOL)value_;





- (GTFSCalendar*)primitiveCalendar;
- (void)setPrimitiveCalendar:(GTFSCalendar*)value;


@end
