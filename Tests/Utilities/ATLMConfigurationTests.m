//
//  ATLMConfigurationTests.m
//  Atlas Messenger
//
//  Created by JP McGlone on 2/3/17.
//  Copyright © 2017 Layer, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ATLMConfiguration.h"
#import <Expecta/Expecta.h>

@interface ATLMConfigurationTests : XCTestCase
@property (nonatomic, nullable) ATLMConfiguration *configuration;

@end

@implementation ATLMConfigurationTests

- (void)setUp {
    [super setUp];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *fileURL = [bundle URLForResource:@"TestLayerConfiguration.json" withExtension:nil];
    self.configuration = [[ATLMConfiguration alloc] initWithFileURL:fileURL];
}

- (void)tearDown {
    self.configuration = nil;
    [super tearDown];
}

- (void)testConfigurationParameters {
    expect(self.configuration.appID.absoluteString).to.equal(@"layer:///apps/staging/test");
    expect(self.configuration.identityProviderURL.absoluteString).to.equal(@"https://test.herokuapp.com");
}

@end
