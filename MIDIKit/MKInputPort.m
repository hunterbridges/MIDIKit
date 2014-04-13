//
//  MKInputPort.m
//  MIDIKit
//
//  Created by John Heaton on 4/11/14.
//  Copyright (c) 2014 John Heaton. All rights reserved.
//

#import "MKInputPort.h"
#import "MKClient.h"
#import "MKMessage.h"

@interface MKInputPort ()
@property (nonatomic, strong) NSMutableSet *inputDelegates;
@end

@implementation MKInputPort

@synthesize client=_client;
@synthesize inputHandler=_inputHandler;
@synthesize inputHandlers=_inputHandlers;

static void _MKInputPortReadProc(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon) {
    MKInputPort *self = (__bridge MKInputPort *)(readProcRefCon);
    MKEndpoint *source = (__bridge MKEndpoint *)(srcConnRefCon);

    MIDIPacket *packet = (MIDIPacket *)&pktlist->packet[0];
    for (int i=0;i<pktlist->numPackets;++i) {
        NSData *goodData = nil;

        for(id<MKInputPortDelegate> delegate in self.inputDelegates) {
            if([delegate respondsToSelector:@selector(inputPort:receivedData:fromSource:)]) {
                [delegate inputPort:self receivedData:(goodData = [NSData dataWithBytes:packet->data length:packet->length]) fromSource:source];
            }
        }

        if(self.inputHandler) {
            NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:0];
            for(int i=0;i<pktlist->packet[0].length;++i) {
                [dataArray addObject:@(pktlist->packet[0].data[i])];
            }
            [self.inputHandler callWithArguments:@[dataArray]];
        }

        for(id inputHandler in self.inputHandlers) {
            if([inputHandler isKindOfClass:[JSValue class]]) {
                [inputHandler callWithArguments:@[ self, [MKMessage messageWithPacket:packet] ]];
            } else {
                ((MKInputHandler)inputHandler)(self, goodData ?: [NSData dataWithBytes:packet->data length:packet->length]);
            }
        }

        packet = MIDIPacketNext(packet);
    }
}

+ (instancetype)inputPortWithName:(NSString *)name client:(MKClient *)client {
    return [[self alloc] initWithName:name client:client];
}

- (instancetype)initWithName:(NSString *)name client:(MKClient *)client {
    MIDIPortRef p;

    if(!client.valid) return nil;
    if(MIDIInputPortCreate(client.MIDIRef, (__bridge CFStringRef)(name), _MKInputPortReadProc, (__bridge void *)(self), &p) != 0)
        return nil;

    if(!(self = [super initWithMIDIRef:p])) return nil;
    
    self.client = client;
    [self.client.inputPorts addObject:self];

    self.inputHandlers = [NSMutableArray arrayWithCapacity:0];
    self.inputDelegates = [NSMutableSet setWithCapacity:0];
    
    return self;
}

- (void)connectSource:(MKEndpoint *)source {
    MIDIPortConnectSource(self.MIDIRef, source.MIDIRef, (__bridge_retained void *)(source));
}

- (void)disconnectSource:(MKEndpoint *)source {
    MIDIPortDisconnectSource(self.MIDIRef, source.MIDIRef);
}

- (void)dispose {
    MIDIPortDispose(self.MIDIRef);
    self.MIDIRef = 0;
}

- (void)addInputDelegate:(id<MKInputPortDelegate>)delegate {
    [_inputDelegates addObject:delegate];
}

- (void)removeInputDelegate:(id<MKInputPortDelegate>)delegate {
    [_inputDelegates removeObject:delegate];
}

- (void)removeAllInputDelegates {
    [_inputDelegates removeAllObjects];
}

- (void)addInputHandler:(MKInputHandler)inputHandler {
    [self.inputHandlers addObject:inputHandler];
}

- (instancetype)removeAllInputHandlers {
    [_inputHandlers removeAllObjects];
    return self;
}

- (instancetype)addInputHandlerJS:(JSValue *)handler {
    [self.inputHandlers addObject:handler];
    return self;
}

- (instancetype)removeInputHandlerJS:(JSValue *)handler {
    [self.inputHandlers removeObject:handler];
    return self;
}

- (void)removeInputHandler:(MKInputHandler)inputHandler {
    [self.inputHandlers removeObject:inputHandler];
}

@end
