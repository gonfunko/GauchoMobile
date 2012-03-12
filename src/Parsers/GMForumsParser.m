//
//  GMForumPostsParser.m
//  GauchoMobile
//
//  Created by Aaron Dodson on 2/13/12.
//  Copyright (c) 2012 Me. All rights reserved.
//

#import "GMForumPostsParser.h"

@implementation GMForumPostsParser

- (NSArray *)forumsFromSource:(NSString *)html {
    NSMutableArray *allForums = [[NSMutableArray alloc] init];
    
    //Strip out break tags in the body of posts so hpple doesn't choke
    html = [html stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    TFHpple *document = [[TFHpple alloc] initWithHTMLData:[html dataUsingEncoding:NSUTF8StringEncoding]];

    //Get the names and IDs of the forums
    NSArray *forums = [document searchWithXPathQuery:@"//td[@class='cell c0']/a"];
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
    for (int i = 0; i < [forumDescriptions count]; i++) {
        TFHppleElement *currentDescription = [forumDescriptions objectAtIndex:i];
        [[allForums objectAtIndex:i] setForumDescription:currentDescription.content];
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
    }
    
    //Get the topic starter
    NSArray *topicAuthors = [document searchWithXPathQuery:@"//td[@class='author']/a"];
    for (int i = 0; i < [topicAuthors count]; i++) {
        TFHppleElement *currentAuthor = [topicAuthors objectAtIndex:i];
        GMParticipant *participant = [[GMParticipant alloc] init];
        participant.name = currentAuthor.content;
        [[allTopics objectAtIndex:i] setAuthor:participant];
    }
    
    //Get the reply count
    NSArray *replies = [document searchWithXPathQuery:@"//td[@class='replies']/a"];
    for (int i = 0; i < [replies count]; i++) {
        TFHppleElement *currentAuthor = [topicAuthors objectAtIndex:i];
        GMParticipant *participant = [[GMParticipant alloc] init];
        participant.name = currentAuthor.content;
        [[allTopics objectAtIndex:i] setReplies:NSStringT
    }
    
    [document release];
    
    return [allTopics autorelease];
}

- (NSArray *)forumPostsFromSource:(NSString *)html {
    NSMutableArray *allPosts = [[NSMutableArray alloc] init];
    
    //Strip out break tags in the body of posts so hpple doesn't choke
    html = [html stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    TFHpple *document = [[TFHpple alloc] initWithHTMLData:[html dataUsingEncoding:NSUTF8StringEncoding]];
    //Get the bodies of the posts
    NSArray *posts = [document searchWithXPathQuery:@"//div[@class='posting']"];
    for (TFHppleElement *el in posts) {
        GMForumPost *post = [[GMForumPost alloc] init];
        
        NSString *content = el.content;
        if (content == nil) {
            content = @"";
        }
        for (TFHppleElement *childEl in el.children) {
            content = [content stringByAppendingFormat:@"\n%@", childEl.content];
        }
        
        post.message = content;

        [allPosts addObject:post];
        [post release];
    }
    
    //Identify the authors
    NSArray *authors = [document searchWithXPathQuery:@"//div[@class='author']"];
    for (int i = 0; i < [authors count]; i++) {
        TFHppleElement *el = [authors objectAtIndex:i];
        NSString *dateString = [el.content stringByReplacingOccurrencesOfString:@"- " withString:@""];
        NSLog(@"%@", dateString);
        NSDate *postDate = [self dateFromDateString:dateString];
        [[allPosts objectAtIndex:i] setPostDate:postDate];
        NSLog(@"%@", [[allPosts objectAtIndex:i] postDate]);
        
        for (TFHppleElement *childEl in el.children) {
            if ([childEl.tagName isEqualToString:@"a"]) {
                GMParticipant *participant = [[GMParticipant alloc] init];
                participant.name = childEl.content;
                [[allPosts objectAtIndex:i] setAuthor:participant];
                [participant release];
            }
        }
    }
    
    //Get the post IDs
    NSArray *links = [document searchWithXPathQuery:@"//a"];
    int i = 0;
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

@end
