// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Polyline.m instead.

#import "_Polyline.h"

const struct PolylineAttributes PolylineAttributes = {
	.path = @"path",
};

const struct PolylineRelationships PolylineRelationships = {
	.line = @"line",
};

const struct PolylineFetchedProperties PolylineFetchedProperties = {
};

@implementation PolylineID
@end

@implementation _Polyline

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Polyline" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Polyline";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Polyline" inManagedObjectContext:moc_];
}

- (PolylineID*)objectID {
	return (PolylineID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic path;






@dynamic line;

	






@end
