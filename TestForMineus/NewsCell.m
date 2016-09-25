//
//  NewsCell.m
//  TestForMineus
//
//  Created by Indieg0 on 22.09.16.
//  Copyright © 2016 Kirill. All rights reserved.
//

#import "NewsCell.h"
#import "Constants.h"

@implementation NewsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = PASTEL_GREEN_COLOR;
    [self setSelectedBackgroundView:bgColorView];
    
    self.backgroundColor = BONE_COLOR;
    self.titleLabel.textColor = INDEPENDENCE_COLOR;
    self.snippetLabel.textColor = EERIE_BLACK_COLOR;
    self.publishDateLabel.textColor = NICKEL_COLOR;
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
