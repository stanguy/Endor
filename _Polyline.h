// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Polyline.h instead.

#import <CoreData/CoreData.h>


extern const struct PolylineAttributes {
	__unsafe_unretained NSString *path;
} PolylineAttributes;

extern const struct PolylineRelationships {
	__unsafe_unretained NSString *line;
} PolylineRelationships;

extern const struct PolylineFetchedProperties {
} PolylineFetchedProperties;

@class Line;



@interface PolylineID : NSManagedObjectID {}
@end

@interface _Polyline : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PolylineID*)objectID;





@property (nonatomic, strong) NSString* path;



//- (BOOL)validatePath:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Line *line;

//- (BOOL)validateLine:(id*)value_ error:(NSError**)error_;





@end

@interface _Polyline (CoreDataGeneratedAccessors)

@end

@interface _Polyline (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitivePath;
- (void)setPrimitivePath:(NSString*)value;





- (Line*)primitiveLine;
- (void)setPrimitiveLine:(Line*)value;


@end
