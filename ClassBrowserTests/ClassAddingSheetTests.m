//See COPYING for licence details.

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "IKBClassNameSheetController.h"
#import "IKBNameEntrySheetController.h"
#import "IKBObjectiveCClass.h"

@interface ClassAddingSheetTests : XCTestCase

@end

@implementation ClassAddingSheetTests
{
    IKBClassNameSheetController *_classNameSheet;
}

- (void)setUp
{
    _classNameSheet = [[IKBClassNameSheetController alloc] initWithWindowNibName:NSStringFromClass([IKBNameEntrySheetController class])];
}

- (void)testEmptyClassNamesAreNotAccepted
{
    _classNameSheet.textEntered = @"";
    XCTAssertFalse([_classNameSheet isEntryValid]);
}

- (void)testClassNameWithASCIILettersIsAccepted
{
    _classNameSheet.textEntered = @"IKBNewClass";
    XCTAssertTrue([_classNameSheet isEntryValid]);
}

- (void)testClassNameContainingNumbersAndUnderscoresIsAccepted
{
    _classNameSheet.textEntered = @"IKB_New_Class_0";
    XCTAssertTrue([_classNameSheet isEntryValid]);
}

- (void)testClassNameBeginningWithANumberIsRejected
{
    _classNameSheet.textEntered = @"1NewClass";
    XCTAssertFalse([_classNameSheet isEntryValid]);
}

- (void)testClassNameContainingNonASCIICharacterIsRejected
{
    _classNameSheet.textEntered = @"IKBNewClåss";
    XCTAssertFalse([_classNameSheet isEntryValid]);
}

- (void)testEntryCreationResultsInAnNSObjectSubclass
{
    _classNameSheet.textEntered = @"IKBNewClass";
    [_classNameSheet createEntry:nil];
    IKBObjectiveCClass *createdClass = _classNameSheet.createdClass;
    XCTAssertEqualObjects(createdClass.name, @"IKBNewClass");
    XCTAssertEqualObjects(createdClass.superclassName, @"NSObject");
}

@end
