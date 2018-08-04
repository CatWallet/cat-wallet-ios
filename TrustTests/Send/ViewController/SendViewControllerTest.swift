// Copyright DApps Platform Inc. All rights reserved.

import Quick
import Nimble
import XCTest

@testable import Trust

class SendViewControllerTest: QuickSpec {
        
    override func spec() {
        super.spec()
        
        
        describe("Token") {
            context("can be sent") {
                beforeEach {
                    
                }
                context("with email") {
                    it ("is not invalid") {
                        let email = "abc.com"
                        expect(email.isEmail).to(beFalse())
                    }
                    it ("is not invalid") {
                        let email = "abc@.com"
                        expect(email.isEmail).to(beFalse())
                    }
                    it ("is not invalid") {
                        let email = "abc@gmaoi"
                        expect(email.isEmail).to(beFalse())
                    }
                    it ("is invalid") {
                        let email = "abc@gmail.com"
                        expect(email.isEmail).to(beTrue())
                    }
                }

                context("with phone number") {
                    it ("is not invalid") {
                        let phoneNum = "1234"
                        expect(phoneNum.isPhoneNumber).to(beFalse())
                    }
                    it ("is not invalid") {
                        let phoneNum = "1223446kfdfjh"
                        expect(phoneNum.isPhoneNumber).to(beFalse())
                    }
                    it ("is not invalid") {
                        let phoneNum = "abcdefghi@!"
                        expect(phoneNum.isPhoneNumber).to(beFalse())
                    }
                    it ("is invalid") {
                        let phoneNum = "1234567890"
                        expect(phoneNum.isPhoneNumber).to(beTrue())
                    }
                    
                }
            }
        }
    }
}
