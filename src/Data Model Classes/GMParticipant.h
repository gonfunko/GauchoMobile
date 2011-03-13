//
// GMParticipant.h
// Models a participant on GauchoSpace
// Created by Group J5 for CS48
//

#import <Foundation/Foundation.h>


@interface GMParticipant : NSObject <NSCoding> {
@private
    NSString *name;
    NSString *city;
    NSString *country;
    NSDate *lastAccess;
    NSInteger userID;
    NSURL *imageURL;
    BOOL inAddressBook;
}

@property (retain) NSString *name;
@property (retain) NSString *city;
@property (retain) NSString *country;
@property (retain) NSDate *lastAccess;
@property (assign) NSInteger userID;
@property (retain) NSURL *imageURL;
@property (assign) BOOL inAddressBook;

/* Returns the last name of the participant as an NSString, based on the following heuristic:
 * Two names, separated by a space: the second name with first letter capitalized
 * Three or more names, separated by spaces:
 * 1) Second name is 3 characters or less: the second through nth names with first letter capitalized
 * 2) Second name is 4 or more characters: the second name with first letter capitalized
 * Ex: Robert Norris returns Norris, Rogier van der Weyden returns Van der Weyden, Ernest Percival Warren returns Warren
 */
- (NSString *)lastName;

//Returns a one-letter uppercase NSString corresponding to the first letter of the string resulting from a call to lastName
- (NSString *)firstCharacterOfLastName;

//Returns true if the receiver is equal to object, otherwise returns false
- (BOOL)isEqualTo:(id)object;

@end