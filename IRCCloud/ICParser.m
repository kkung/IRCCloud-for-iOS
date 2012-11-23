//
//  ICParser.m
//  IRCCloud
//
//  Created by Aditya KD on 22/11/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import "ICParser.h"
#import "ICController.h"
#import "ICNetwork.h"
#import "ICChannel.h"

@implementation ICParser
+ (ICParser *)sharedParser
{
    // a sharedInstance is better than continually creating a new instance of the parser
    static ICParser *parser;
    if (!parser)
        parser = [[self alloc] init];
    return parser;
}

- (void)parse:(NSDictionary *)json
{
    NSAutoreleasePool *p = [NSAutoreleasePool new];
    if ([json[@"type"] isEqualToString:@"header"]) {
        NSLog(@"Header received, stream has begun");
    }

    if ([json[@"type"] isEqualToString:@"makeserver"]) {
        ICNetwork *network = [[[ICNetwork alloc] initWithNetworkNamed:json[@"name"]
                                                            hostName:json[@"hostname"]
                                                                 SSL:[(NSNumber *)json[@"ssl"] boolValue]
                                                                port:[(NSNumber *)json[@"port"] intValue]
                                                         connectionID:[(NSNumber *)json[@"cid"] intValue]] autorelease];
        [[ICController sharedController] addNetwork:network];
    }
    if ([json[@"type"] isEqualToString:@"channel_init"]) {
        if (![[ICController sharedController] networkForConnection:json[@"cid"]])
            return;
        ICChannel *channel = [[[ICChannel alloc] initWithName:json[@"chan"] andBufferID:json[@"bid"]] autorelease];
        channel.members = json[@"members"];
        channel.creationDate = [NSDate dateWithTimeIntervalSince1970:[json[@"timestamp"] intValue]];
        channel.topic = json[@"topic"];
        channel.type = json[@"channel_type"];
        channel.mode = json[@"mode"];
        channel.ops = json[@"ops"];
        
        ICNetwork *channelNetwork = [[ICController sharedController] networkForConnection:json[@"cid"]];
        [channelNetwork addChannel:channel];
    }
    [p release];
}

@end