//See COPYING for licence details.

#import <Cocoa/Cocoa.h>

@protocol IKBClassList;

@interface IKBClassBrowserSource : NSObject <NSBrowserDelegate>

- (instancetype)initWithClassList:(id <IKBClassList>)list;
- (void)browser:(NSBrowser *)browser didSelectRow:(NSInteger)row inColumn:(NSInteger)column;
- (NSString *)selectedClassGroup;
- (NSString *)selectedClass;

@end
