//
//  MKMessage.h
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>
#import <JavaScriptCore/JavaScriptCore.h>

// MKMessage is a data wrapper class which implements some basic MIDI
// message protocol logic.
//
// It is mainly meant to be extended for generating messages
// that correspond to specific sets of functions for specific
// types of devices. For instance, you could subclass this
// for generating messages that correspond to light commands
// on a pad device

typedef NS_ENUM(UInt8, MKMessageType) {
    kMKMessageTypeNoteOff                           = 0x80,
    kMKMessageTypeNoteOn                            = 0x90,
    kMKMessageTypePolyphonicKeyPressureAfterTouch   = 0xA0,
    kMKMessageTypeControlChange                     = 0xB0,
    kMKMessageTypeProgramChange                     = 0xC0,
    kMKMessageTypeChannelPressureAfterTouch         = 0xD0,
    kMKMessageTypePitchBend                         = 0xE0,
    kMKMessageTypeSysex                             = 0xF0
};

@protocol MKMessageJS <JSExport>

+ (instancetype)new;

// Convenience/accessibility for JavaScript
+ (MKMessageType)noteOnType;
+ (MKMessageType)noteOffType;
+ (MKMessageType)controlChangeType;
+ (MKMessageType)polyphonicAfterTouchType;
+ (MKMessageType)programChangeType;
+ (MKMessageType)channelAfterTouchType;
+ (MKMessageType)pitchBendType;

// Shortcut for data.length
- (NSUInteger)length;

// These will expand the data length to fit.
- (void)setByte:(UInt8)byte atIndex:(NSUInteger)index;

// Channel of the note message
@property (nonatomic, assign) UInt8 channel;
// Type of message
@property (nonatomic, assign) MKMessageType type;

// 2nd and 3rd bytes of the buffer(zero if doesn't exist)
// key for note messages, controller for control change/other
@property (nonatomic, assign) UInt8 key, controller;
// velocity for note messages, value for others
@property (nonatomic, assign) UInt8 velocity, value;

@end

@interface MKMessage : NSObject <MKMessageJS>

+ (instancetype)messageWithType:(MKMessageType)type
                keyOrController:(UInt8)keyOrController
                velocityOrValue:(UInt8)velocityOrValue;

+ (instancetype)controlChangeMessageWithController:(UInt8)controller value:(UInt8)value;

+ (instancetype)messageWithData:(NSData *)data;
+ (instancetype)messageWithPacket:(MIDIPacket *)packet;

- (instancetype)initWithData:(NSData *)data;
- (instancetype)initWithPacket:(MIDIPacket *)packet;
- (instancetype)initWithType:(MKMessageType)type
             keyOrController:(UInt8)keyOrController
             velocityOrValue:(UInt8)velocityOrValue;

// Cleaner syntax for three-byte messages: [MKMessage :0x90 :0x35 :127]
+ (instancetype):(UInt8)type :(UInt8)keyOrController :(UInt8)velocityOrValue;

// Messages stay mutable for performance reasons
- (NSMutableData *)data;
- (UInt8 *)bytes;

// myMessage[0] = @(0x90)
// This ONLY works with one-byte NSNumbers
- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)idx;

@end
