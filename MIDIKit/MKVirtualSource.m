//
//  MKVirtualSource.m
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKVirtualSource.h"

@implementation MKVirtualSource

@synthesize client=_client;

- (instancetype)initWithName:(NSString *)name client:(MKClient *)client {
    if(!client.valid || !(self = [super init])) return nil;
    
    if(MIDISourceCreate(client.MIDIRef, (__bridge CFStringRef)(name), &_MIDIRef) != 0)
        return nil;
    
    self.client = client;
    [self.client.virtualSources addObject:self];
    
    return self;
}

- (void)receivedData:(NSData *)data {
    if(data.length <= 256) {
        MIDIPacketList list;
        list.numPackets = 1;
        list.packet[0].timeStamp = 0;
        list.packet[0].length = data.length;
        memcpy(list.packet[0].data, data.bytes, data.length);
        
        MIDIReceived(self.MIDIRef, &list);
    } else {
        [NSException raise:@"Data is too large" format:@"I need to implement this"];
    }
}

@end