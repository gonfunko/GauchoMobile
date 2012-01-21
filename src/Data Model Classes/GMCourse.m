//
// GMCourse.m
// Models a course on GauchoSpace
// Created by Group J5 for CS48
//

#import "GMCourse.h"

@implementation GMCourse

@synthesize name;
@synthesize assignments;
@synthesize participants;
@synthesize grades;
@synthesize dashboardItems;
@synthesize courseID;
@synthesize officeHours;
@synthesize quarter;
@synthesize instructor;

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.assignments forKey:@"assignments"];
    [encoder encodeObject:self.participants forKey:@"participants"];
    [encoder encodeObject:self.grades forKey:@"grades"];
    [encoder encodeObject:self.dashboardItems forKey:@"dashboardItems"];
    [encoder encodeInteger:self.courseID forKey:@"courseID"];
    [encoder encodeObject:self.officeHours forKey:@"officeHours"];
    [encoder encodeObject:self.quarter forKey:@"quarter"];
    [encoder encodeObject:self.instructor forKey:@"instructor"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    if ((self = [super init])) {
        self.name = [decoder decodeObjectForKey:@"name"];
        self.assignments = [decoder decodeObjectForKey:@"assignments"];
        self.participants = [decoder decodeObjectForKey:@"participants"];
        self.grades = [decoder decodeObjectForKey:@"grades"];
        self.dashboardItems = [decoder decodeObjectForKey:@"dashboardItems"];
        self.courseID = [decoder decodeIntegerForKey:@"courseID"];
        self.officeHours = [decoder decodeObjectForKey:@"officeHours"];
        self.quarter = [decoder decodeObjectForKey:@"quarter"];    
        self.instructor = [decoder decodeObjectForKey:@"instructor"];
    }
    
    return self;
}

- (id)init {
    if ((self = [super init])) {
        self.name = @"";
        self.assignments = [NSArray array];
        self.participants = [NSMutableDictionary dictionary];
        self.grades = [NSArray array];
        self.dashboardItems = [NSArray array];
        self.courseID = 0;
    
        GMOfficeHours *_officeHours = [[GMOfficeHours alloc] init];
        self.officeHours = _officeHours;
        [_officeHours release];
        
        GMQuarter *_quarter = [[GMQuarter alloc] init];
        self.quarter = _quarter;
        [_quarter release];
        
        GMParticipant *_instructor = [[GMParticipant alloc] init];
        self.instructor = _instructor;
        [_instructor release];
    }
    
    return self;
}

- (BOOL)isEqualTo:(id)object {
    if ([object isKindOfClass:[GMCourse class]]) {
        GMCourse *other = (GMCourse *)object;
        if (other.courseID == self.courseID)
            return YES;
        else
            return NO;
    }
    else
        return NO;
}

- (BOOL)isEqual:(id)object {
    return [self isEqualTo:object];
}

- (NSUInteger)hash {
    return (NSUInteger)self.courseID;
}

- (void)addAssignment:(GMAssignment *)newAssignment {
    if(![self.assignments containsObject:newAssignment]){   
        self.assignments = [self.assignments arrayByAddingObject:newAssignment];
    }
    
    NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
    self.assignments = [self.assignments sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
}

- (void)removeAssignment:(GMAssignment *)assignment {
    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.assignments];
    [temp removeObject:assignment];
    
    self.assignments = temp;
}

- (void)removeAllAssignments {
    NSMutableArray *temp = [NSMutableArray array];
    self.assignments = temp;
}

- (void)addGrade:(GMGrade *)newGrade {
    if (![self.grades containsObject:newGrade]) {
        self.grades = [self.grades arrayByAddingObject:newGrade];
    }
    
    NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES];
    self.grades = [self.grades sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
}

- (void)removeGrade:(GMGrade *)grade {
    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.grades];
    [temp removeObject:grade];
    
    self.grades = temp;
}

- (void)removeAllGrades {
    NSMutableArray *temp = [NSMutableArray array];
    self.grades = temp;
}

- (void)addParticipant:(GMParticipant *)newParticipant {
    
    NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
    
    if ([self.participants objectForKey:[newParticipant firstCharacterOfLastName]] == nil) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:newParticipant];
        [array sortUsingDescriptors:[NSArray arrayWithObject:sorter]];
        [self.participants setObject:array forKey:[newParticipant firstCharacterOfLastName]];
        [array release];
    } else {
        NSMutableArray *currentParticipants = [self.participants objectForKey:[newParticipant firstCharacterOfLastName]];
        if (![currentParticipants containsObject:newParticipant]) {
            [currentParticipants addObject:newParticipant];
            [currentParticipants sortUsingDescriptors:[NSArray arrayWithObject:sorter]];
        }
    }
}

- (void)removeParticipant:(GMParticipant *)participant {
    NSMutableArray *temp = [self.participants objectForKey:[participant firstCharacterOfLastName]];
    if ([temp containsObject:participant]) {
        [temp removeObject:participant];
    }
}

- (void)removeAllParticipants {
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
    self.participants = temp;
    [temp release];
}

- (void)addDashboardItem:(GMDashboardItem *)newItem {
    if (![self.dashboardItems containsObject:newItem]) {   
        self.dashboardItems = [self.dashboardItems arrayByAddingObject:newItem];
    }
}

- (void)removeDashboardItem:(GMDashboardItem *)item {
    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.dashboardItems];
    [temp removeObject:item];
    
    self.dashboardItems = temp;
}

- (void)removeAllDashboardItems {
    NSMutableArray *temp = [NSMutableArray array];
    self.dashboardItems = temp;
}

@end
