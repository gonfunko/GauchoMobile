//
// GMCourse.h
// Models a course on GauchoSpace
// Created by Group J5 for CS48
//

#import <Foundation/Foundation.h>
#import "GMOfficeHours.h"
#import "GMQuarter.h"
#import "GMParticipant.h"
#import "GMGrade.h"
#import "GMAssignment.h"
#import "GMDashboardItem.h"

@interface GMCourse : NSObject <NSCoding> {
@private
    NSString *name;
    NSArray *assignments;
    NSArray *participants;
    NSArray *grades;
    NSArray *dashboardItems;
    NSInteger courseID;
    GMOfficeHours *officeHours;
    GMQuarter *quarter;
    GMParticipant *instructor;
}

@property (copy) NSString *name;
@property (retain) NSArray *assignments;
@property (retain) NSArray *participants;
@property (retain) NSArray *grades;
@property (retain) NSArray *dashboardItems;
@property (assign) NSInteger courseID;
@property (retain) GMOfficeHours *officeHours;
@property (retain) GMQuarter *quarter;
@property (retain) GMParticipant *instructor;

//Returns true if the receiver is equal to object, otherwise returns false
- (BOOL)isEqualTo:(id)object;

//Adds newAssignment to the list of assignments associated with this course if it is not already present
- (void)addAssignment:(GMAssignment *)newAssignment;

//Removes the specified GMAssignment from the list of assignments associated with this course, if it exists
- (void)removeAssignment:(GMAssignment *)assignment;

//Removes all assignments from this course
- (void)removeAllAssignments;

//Adds newGrade to the list of grades associated with this course if it is not already present
- (void)addGrade:(GMGrade *)newGrade;

//Removes the specified GMGrade from the list of grades associated with this course, if it exists
- (void)removeGrade:(GMGrade *)grade;

//Removes all grades from this course
- (void)removeAllGrades;

//Adds newParticipant to the list of participants associated with this course if it is not already present
- (void)addParticipant:(GMParticipant *)newParticipant;

//Removes the specified GMParticipant from the list of participants associated with this course, if it exists
- (void)removeParticipant:(GMParticipant *)participant;

//Removes all participants from this course
- (void)removeAllParticipants;

//Adds newItem to the list of dashboard items associated with this course if it is not already present
- (void)addDashboardItem:(GMDashboardItem *)newItem;

//Removes the specified GMDashboardItem from the list of dashboard items associated with this course, if it exists
- (void)removeDashboardItem:(GMDashboardItem *)item;

//Removes all dashboard items from this course
- (void)removeAllDashboardItems;

@end
