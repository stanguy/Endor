// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Poi.h instead.

#import <CoreData/CoreData.h>


extern const struct PoiAttributes {
	__unsafe_unretained NSString *address;
	__unsafe_unretained NSString *lat;
	__unsafe_unretained NSString *lon;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *type;
} PoiAttributes;

extern const struct PoiRelationships {
} PoiRelationships;

extern const struct PoiFetchedProperties {
} PoiFetchedProperties;








@interface PoiID : NSManagedObjectID {}
@end

@interface _Poi : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PoiID*)objectID;





@property (nonatomic, strong) NSString* address;



//- (BOOL)validateAddress:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* lat;



@property float latValue;
- (float)latValue;
- (void)setLatValue:(float)value_;

//- (BOOL)validateLat:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* lon;



@property float lonValue;
- (float)lonValue;
- (void)setLonValue:(float)value_;

//- (BOOL)validateLon:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* type;



//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;






@end

@interface _Poi (CoreDataGeneratedAccessors)

@end

@interface _Poi (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAddress;
- (void)setPrimitiveAddress:(NSString*)value;




- (NSNumber*)primitiveLat;
- (void)setPrimitiveLat:(NSNumber*)value;

- (float)primitiveLatValue;
- (void)setPrimitiveLatValue:(float)value_;




- (NSNumber*)primitiveLon;
- (void)setPrimitiveLon:(NSNumber*)value;

- (float)primitiveLonValue;
- (void)setPrimitiveLonValue:(float)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveType;
- (void)setPrimitiveType:(NSString*)value;




@end
