//See COPYING for licence details.

#import "IKBSourceRepository.h"
#import "IKBObjectiveCMethod.h"

@implementation IKBSourceRepository
{
    NSMutableSet *_methods;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _methods = [NSMutableSet set];
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

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_methods forKey:@"methods"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _methods = [[aDecoder decodeObjectForKey:@"methods"] mutableCopy];
    }
    return self;
}

@end
