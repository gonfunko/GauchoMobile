//
//  GMForumPostsParser.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 2/13/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "GMForumsParser.h"

@implementation GMForumsParser

- (NSArray *)forumsFromSource:(NSString *)html {
    NSMutableArray *allForums = [[NSMutableArray alloc] init];
    
    //Strip out break tags in the body of posts so hpple doesn't choke
    html = [html stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    TFHpple *document = [[TFHpple alloc] initWithHTMLData:[html dataUsingEncoding:NSUTF8StringEncoding]];
    
    /* For some inane reason, GauchoSpace has two kinds of forums (General and Learning) that put the title
       and description in columns 0 and 1 or 1 and 2, respectively. The apparently repetitive stuff here
       is an effort to work around that.
     */

    //Get the names and IDs of the forums
    NSArray *forums = [document searchWithXPathQuery:@"//td[@class='cell c0']/a"];
    NSArray *secondaryForums = [document searchWithXPathQuery:@"//td[@class='cell c1']/a"];
    forums = [forums arrayByAddingObjectsFromArray:secondaryForums];
    for (TFHppleElement *el in forums) {
        GMForum *forum = [[GMForum alloc] init];
        forum.title = el.content;
        
        NSString *forumID = [el.attributes objectForKey:@"href"];
        forumID = [forumID substringFromIndex:[forumID length] - 4];
        forum.forumID = forumID;
        [allForums addObject:forum];
    }
    
    //Get the forum descriptions
    NSArray *forumDescriptions = [document searchWithXPathQuery:@"//td[@class='cell c1']"];
    for (int i = 0; i < MIN([forums count], [forumDescriptions count]); i++) {
        TFHppleElement *currentDescription = [forumDescriptions objectAtIndex:i];
        NSString *forumDescription = currentDescription.content;
        if (forumDescription == nil) {
            forumDescription = @"";
        }
        
        for (TFHppleElement *childEl in currentDescription.children) {
            if (childEl.content != nil) {
                forumDescription = [forumDescription stringByAppendingFormat:@" %@", childEl.content];
            }
        }
        
        [[allForums objectAtIndex:i] setForumDescription:forumDescription];
    }
    
    forumDescriptions = [document searchWithXPathQuery:@"//td[@class='cell c2']"];
    for (int i = [forums count] - [secondaryForums count]; i < MIN([allForums count], [forumDescriptions count]); i++) {
        TFHppleElement *currentDescription = [forumDescriptions objectAtIndex:i];
        NSString *forumDescription = currentDescription.content;
        if (forumDescription == nil) {
            forumDescription = @"";
        }

        for (TFHppleElement *childEl in currentDescription.children) {
            if (childEl.content != nil) {
                forumDescription = [forumDescription stringByAppendingString:childEl.content];
            }
        }
        
        [[allForums objectAtIndex:i] setForumDescription:forumDescription];
    }
    
    [document release];
    
    return [allForums autorelease];
}

- (NSArray *)forumTopicsFromSource:(NSString *)html {
    NSMutableArray *allTopics = [[NSMutableArray alloc] init];
    
    //Strip out break tags in the body of posts so hpple doesn't choke
    html = [html stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    TFHpple *document = [[TFHpple alloc] initWithHTMLData:[html dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Get the names and IDs of the topics
    NSArray *topics = [document searchWithXPathQuery:@"//td[@class='topic starter']/a"];
    for (TFHppleElement *el in topics) {
        GMForumTopic *topic = [[GMForumTopic alloc] init];
        topic.title = el.content;
        
        NSString *topicID = [el.attributes objectForKey:@"href"];
        topicID = [topicID substringFromIndex:[topicID length] - 5];
        topic.topicID = topicID;
        [allTopics addObject:topic];
        [topic release];
    }
    
    //Get the topic starter
    NSArray *topicAuthors = [document searchWithXPathQuery:@"//td[@class='author']/a"];
    for (int i = 0; i < [topicAuthors count]; i++) {
        TFHppleElement *currentAuthor = [topicAuthors objectAtIndex:i];
        GMParticipant *participant = [[GMParticipant alloc] init];
        participant.name = currentAuthor.content;
        [[allTopics objectAtIndex:i] setAuthor:participant];
        [participant release];
    }
    
    //Get the reply count
    NSArray *replies = [document searchWithXPathQuery:@"//td[@class='replies']/a"];
    for (int i = 0; i < [replies count]; i++) {
        TFHppleElement *currentTopic = [replies objectAtIndex:i];
        NSInteger replyCount = [currentTopic.content intValue];
        [[allTopics objectAtIndex:i] setReplies:replyCount];
    }
    
    //Get the date of the last post
    NSArray *lastPostDates = [document searchWithXPathQuery:@"//td[@class='lastpost']/a[2]"];
    for (int i = 0; i < [lastPostDates count]; i++) {
        TFHppleElement *currentTopic = [lastPostDates objectAtIndex:i];
        NSDate *lastPostDate = [self dateFromDateString:currentTopic.content];
        [[allTopics objectAtIndex:i] setLastPostDate:lastPostDate];
    }
    
    [document release];
    
    return [allTopics autorelease];
}

- (NSArray *)forumPostsFromSource:(NSString *)html {
    NSMutableArray *allPosts = [[NSMutableArray alloc] init];
    TFHpple *document = [[TFHpple alloc] initWithHTMLData:[html dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSArray *postingChunks = [html componentsSeparatedByString:@"<div class=\"posting\">"];
    
    for (int i = 1; i < [postingChunks count]; i++) {
        NSString *message = [[postingChunks objectAtIndex:i] substringToIndex:[[postingChunks objectAtIndex:i] rangeOfString:@"</div>"].location];
        message = [self stripHTMLFromString:message];

        GMForumPost *post = [[GMForumPost alloc] init];
        post.message = message;
        
        [allPosts addObject:post];
        [post release];
    }
    
    //Identify the authors
    NSArray *authors = [document searchWithXPathQuery:@"//div[@class='author']"];
    for (int i = 0; i < [authors count]; i++) {
        TFHppleElement *el = [authors objectAtIndex:i];
        NSString *dateString = [el.content stringByReplacingOccurrencesOfString:@"- " withString:@""];
        NSDate *postDate = [self dateFromDateString:dateString];
        [[allPosts objectAtIndex:i] setPostDate:postDate];
        
        for (TFHppleElement *childEl in el.children) {
            if ([childEl.tagName isEqualToString:@"a"]) {
                GMParticipant *participant = [[GMParticipant alloc] init];
                participant.name = childEl.content;
                [[allPosts objectAtIndex:i] setAuthor:participant];
                [participant release];
            }
        }
    }
    
    //Get the author's photo URLs
    NSArray *photos = [document searchWithXPathQuery:@"//img[@height='35']"];
    int i = 0;
    for (TFHppleElement *el in photos) {
        NSURL *photoURL = [NSURL URLWithString:[[el.attributes objectForKey:@"src"] stringByReplacingOccurrencesOfString:@"f2" withString:@"f1"]];
        [[allPosts objectAtIndex:i] author].imageURL = photoURL;
        i++;
    }   
    
    //Get the post IDs
    NSArray *links = [document searchWithXPathQuery:@"//a"];
    i = 0;
    for (TFHppleElement *el in links) {
        if ([[el.attributes valueForKey:@"id"] hasPrefix:@"p"]) {
            [[allPosts objectAtIndex:i] setPostID:[el.attributes valueForKey:@"id"]];
            i++;
        }
    }
    
    [document release];
    
    return [allPosts autorelease];
}

- (NSDate *)dateFromDateString:(NSString *)dateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, d MMMM yyyy, hh:mm a"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSDate *date = [formatter dateFromString:dateString];
    [formatter release];
    
    return date;
}

- (NSString *)stripHTMLFromString:(NSString *)source {
    //Based on http://stackoverflow.com/questions/277055/remove-html-tags-from-an-nsstring-on-the-iphone
    source = [source stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    source = [source stringByReplacingOccurrencesOfString:@"&mdash;" withString:@"–"];
    source = [source stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    source = [source stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    
    NSRange r;
    while ((r = [source rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
        source = [source stringByReplacingCharactersInRange:r withString:@""];
    }
    
    source = [source stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return source;
}

@end
