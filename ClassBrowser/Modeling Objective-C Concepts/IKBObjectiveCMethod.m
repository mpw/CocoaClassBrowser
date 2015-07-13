//See COPYING for licence details.

#import "IKBObjectiveCMethod.h"


@implementation IKBObjectiveCMethod

/**
 * You could probably imagine using clang to do a more robust version of this.
 */
- (NSString *)canonicalName
{
    NSString *declaration = self.declaration;
    NSAssert([declaration hasPrefix:@"-"] ||
             [declaration hasPrefix:@"+"],
             @"expected %@ to begin with - or +", declaration);
    NSAssert([declaration length] > 1, @"expected %@ to be long enough to represent a method declaration", declaration);
    __block NSString *canonicalName = [declaration substringToIndex:1];
    __block NSInteger parenthesisDepth = 0;
    __block BOOL betweenColonAndWhitespace = NO;
    __block BOOL betweenColonAndOpeningParenthesis = NO;
    [declaration enumerateSubstringsInRange:NSMakeRange(1, [declaration length] - 1)
                                    options:NSStringEnumerationByComposedCharacterSequences
                                 usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                     if ([substring rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location != NSNotFound) {
                                         if (parenthesisDepth == 0 && betweenColonAndOpeningParenthesis == NO) {
                                             betweenColonAndWhitespace = NO;
                                         }
                                         return;
                                     }
                                     if ([substring isEqualToString:@"("]) {
                                         betweenColonAndOpeningParenthesis = NO;
                                         parenthesisDepth += 1;
                                         return;
                                     }
                                     if ([substring isEqualToString:@")"]) {
                                         parenthesisDepth -= 1;
                                         return;
                                     }
                                     if ([substring isEqualToString:@":"]) {
                                         betweenColonAndWhitespace = YES;
                                         betweenColonAndOpeningParenthesis = YES;
                                         canonicalName = [canonicalName stringByAppendingString:substring];
                                         return;
                                     }
                                     if (parenthesisDepth == 0 && !betweenColonAndWhitespace) {
                                         canonicalName = [canonicalName stringByAppendingString:substring];
                                         return;
                                     }
                                 }];
    return canonicalName;
}

@end