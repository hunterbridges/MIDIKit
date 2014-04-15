//
//  MKPrivate.h
//  MIDIKit
//
//  Created by John Heaton on 4/14/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <CoreMIDI/CoreMIDI.h>
#import <Foundation/Foundation.h>

@class MKEntity;

extern MIDIPacketList *MKPacketListFromData(NSData *data);
extern MKEntity *MKEntityForEndpoint(id endpoint);