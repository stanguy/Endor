// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Line.h instead.

#import <CoreData/CoreData.h>


@class Stop;
@class StopTime;
@class Direction;









@interface LineID : NSManagedObjectID {}
@end

@interface _Line : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (LineID*)objectID;



@property (nonatomic, retain) NSNumber *has_picto;

@property BOOL has_pictoValue;
- (BOOL)has_pictoValue;
- (void)setHas_pictoValue:(BOOL)value_;

//- (BOOL)validateHas_picto:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *long_name;

//- (BOOL)validateLong_name:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *fgcolor;

//- (BOOL)validateFgcolor:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *short_name;

//- (BOOL)validateShort_name:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *bgcolor;

//- (BOOL)validateBgcolor:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *forced_id;

@property short forced_idValue;
- (short)forced_idValue;
- (void)setForced_idValue:(short)value_;

//- (BOOL)validateForced_id:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *usage;

//- (BOOL)validateUsage:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* stops;
- (NSMutableSet*)stopsSet;



@property (nonatomic, retain) NSSet* stop_times;
- (NSMutableSet*)stop_timesSet;



@property (nonatomic, retain) NSSet* headsigns;
- (NSMutableSet*)headsignsSet;




@end

@interface _Line (CoreDataGeneratedAccessors)

- (void)addStops:(NSSet*)value_;
- (void)removeStops:(NSSet*)value_;
- (void)addStopsObject:(Stop*)value_;
- (void)removeStopsObject:(Stop*)value_;

- (void)addStop_times:(NSSet*)value_;
- (void)removeStop_times:(NSSet*)value_;
- (void)addStop_timesObject:(StopTime*)value_;
- (void)removeStop_timesObject:(StopTime*)value_;

- (void)addHeadsigns:(NSSet*)value_;
- (void)removeHeadsigns:(NSSet*)value_;
- (void)addHeadsignsObject:(Direction*)value_;
- (void)removeHeadsignsObject:(Direction*)value_;

@end

@interface _Line (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveHas_picto;
- (void)setPrimitiveHas_picto:(NSNumber*)value;

- (BOOL)primitiveHas_pictoValue;
- (void)setPrimitiveHas_pictoValue:(BOOL)value_;


- (NSString*)primitiveLong_name;
- (void)setPrimitiveLong_name:(NSString*)value;


- (NSString*)primitiveFgcolor;
- (void)setPrimitiveFgcolor:(NSString*)value;


- (NSString*)primitiveShort_name;
- (void)setPrimitiveShort_name:(NSString*)value;


- (NSString*)primitiveBgcolor;
- (void)setPrimitiveBgcolor:(NSString*)value;


- (NSNumber*)primitiveForced_id;
- (void)setPrimitiveForced_id:(NSNumber*)value;

- (short)primitiveForced_idValue;
- (void)setPrimitiveForced_idValue:(short)value_;


- (NSString*)primitiveUsage;
- (void)setPrimitiveUsage:(NSString*)value;




- (NSMutableSet*)primitiveStops;
- (void)setPrimitiveStops:(NSMutableSet*)value;



- (NSMutableSet*)primitiveStop_times;
- (void)setPrimitiveStop_times:(NSMutableSet*)value;



- (NSMutableSet*)primitiveHeadsigns;
- (void)setPrimitiveHeadsigns:(NSMutableSet*)value;


@end