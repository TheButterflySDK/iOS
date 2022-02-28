//
//  BFReport.m
//  first
//
//  Created by Aviel on 9/30/20.
//  Copyright © 2020 Aviel. All rights reserved.
//

#import "BFReport.h"

@implementation BFReport

- (NSString *) description {
    return [NSString stringWithFormat:@"contact information:%@, comments: %@, fake place:%@", self.contactDetails,self.comments,self.fakePlace];
}

@end
