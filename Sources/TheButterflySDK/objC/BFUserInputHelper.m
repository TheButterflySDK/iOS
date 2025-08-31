//
//  BFUserInputHelper.m
//  butterfly
//
//  Created by Aviel on 10/9/20.
//  Copyright © 2020 Aviel. All rights reserved.
//

#import "BFUserInputHelper.h"

@implementation BFUserInputHelper

- (void) getUserInput: (UIViewController*)viewController onDone:(void(^)(NSString* , NSString* , NSString*))completion {
    if (!completion) return;

    NSString* path = [[NSBundle bundleForClass: [BFUserInputHelper class]]
                      pathForResource:@"Butterfly" ofType:@"bundle"];
    
    NSBundle* bundle = [NSBundle bundleWithPath:path];
    if (!bundle) {
        completion(nil, nil, nil);
        return;
    }

    NSString* message =
    [bundle localizedStringForKey:@"butterfly_host_report_meesage" value:@"" table:nil];

    _alertController = [UIAlertController alertControllerWithTitle:
                            [bundle localizedStringForKey: @"butterfly_host_contact"
                                                    value:@""
                                                    table:nil]
                        message: message
                        preferredStyle: UIAlertControllerStyleAlert];

    UIAlertController *__weak weakAlertController = _alertController;

    [_alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder =
                [bundle localizedStringForKey:@"butterfly_host_way_to_contact" value:@"" table:nil];
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];

    [_alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder =
                [bundle localizedStringForKey:@"butterfly_host_fake_place" value:@"" table:nil];
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];

    [_alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder =
                [bundle localizedStringForKey:@"butterfly_host_comments" value:@"" table:nil];
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
    
    [_alertController addAction:[UIAlertAction actionWithTitle:[bundle localizedStringForKey:@"butterfly_host_send" value:@"" table:nil] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = [weakAlertController textFields];
        UITextField * wayContactField = textfields[0];
        UITextField * fakePlaceField = textfields[1];
        UITextField * commentsField = textfields[2];
        
        if ([wayContactField.text length]) {
            completion(wayContactField.text, fakePlaceField.text, commentsField.text);
        }
    }]];

    [_alertController addAction:[UIAlertAction actionWithTitle:[bundle localizedStringForKey:@"butterfly_host_cancel" value:@"" table:nil] style:UIAlertActionStyleCancel handler:nil]];
    
    
//    [[_alertController.actions firstObject] setEnabled: false];

    [[_alertController.textFields firstObject] addTarget:self
                                      action:@selector(contactDetailsFieldDidChange) forControlEvents: UIControlEventEditingChanged];
    
    [viewController presentViewController:_alertController animated: YES completion:^{
        UIAlertController *strongAlertController = weakAlertController;
        strongAlertController.view.superview.userInteractionEnabled = YES;
        [strongAlertController.view.superview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOutsideButterflyDialog)]];
    }];
}

-(void) contactDetailsFieldDidChange
{
    if ([[_alertController.textFields firstObject] hasText]) {
        [[_alertController.actions firstObject] setEnabled: YES];
    } else {
        [[_alertController.actions firstObject] setEnabled: NO];
    }

}

-(void) didTapOutsideButterflyDialog
{
    [_alertController dismissViewControllerAnimated:true completion:nil];
}

@end
