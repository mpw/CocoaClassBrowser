//See COPYING for licence details.

#import "IKBObjectiveCClass.h"

@implementation IKBObjectiveCClass

- (instancetype)initWithName:(NSString *)name superclass:(NSString *)superclass
{
    NSParameterAssert(name != nil);
    self = [super init];
    if (self) {
        _name = [name copy];
        _superclassName = [superclass copy];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_superclassName forKey:@"superclass"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _name = [[aDecoder decodeObjectForKey:@"name"] copy];
        _superclassName = [[aDecoder decodeObjectForKey:@"superclass"] copy];
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object respondsToSelector:@selector(name)] &&
        [object respondsToSelector:@selector(superclassName)]) {
        return [[object name] isEqual:_name] &&
        [[object superclassName] isEqual:_superclassName];
    }
    return NO;
}
@end
