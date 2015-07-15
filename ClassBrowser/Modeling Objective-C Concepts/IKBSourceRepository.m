//See COPYING for licence details.

#import "IKBSourceRepository.h"
#import "IKBObjectiveCMethod.h"

@implementation IKBSourceRepository
{
    NSMutableSet *_methods;
    NSMutableSet *_classes;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _methods = [NSMutableSet set];
        _classes = [NSMutableSet set];
    }
    return self;
}

- (void)addMethod:(IKBObjectiveCMethod *)method
{
    [_methods addObject:method];
}

- (NSArray *)allMethods
{
    return [_methods allObjects];
}

- (NSArray *)methodsForClassNamed:(NSString *)className
{
    //there will be more efficient ways of dealing with this
    NSMutableArray *methods = [NSMutableArray array];
    [_methods enumerateObjectsUsingBlock:^(IKBObjectiveCMethod *method, BOOL *stop) {
        if ([method.className isEqualToString:className]) {
            [methods addObject:method];
        }
    }];
    return [methods copy];
}

- (void)addClass:(IKBObjectiveCClass *)aClass
{
    [_classes addObject:aClass];
}

- (NSArray *)allClasses
{
    return [_classes allObjects];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_methods forKey:@"methods"];
    [aCoder encodeObject:_classes forKey:@"classes"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _methods = [[aDecoder decodeObjectForKey:@"methods"] mutableCopy];
        _classes = [[aDecoder decodeObjectForKey:@"classes"] mutableCopy];
    }
    return self;
}

@end
