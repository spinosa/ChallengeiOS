//
//  BattleModelTests.swift
//  ChallengeTests
//
//  Created by Daniel Spinosa on 6/18/18.
//  Copyright © 2018 Cromulent Consulting, Inc. All rights reserved.
//

import XCTest

class BattleModelTests: XCTestCase {

    func testBattlesIndex() {
        let jsonData = Data("[{\"id\":\"9b381d03-1551-411e-aabf-6e3e8ccdc275\",\"description\":\"first!\",\"outcome\":1,\"state\":1,\"disputed_at\":null,\"created_at\":\"2018-06-15T18:22:23.675Z\",\"updated_at\":\"2018-06-15T18:22:23.675Z\",\"url\":\"http://localhost:3000/battles/9b381d03-1551-411e-aabf-6e3e8ccdc275.json\",\"initiator\":{\"screenname\":\"spinosa\",\"wins_total\":0,\"losses_total\":0,\"wins_when_initiator\":0,\"losses_when_initiator\":0,\"wins_when_recipient\":0,\"losses_when_recipient\":0,\"disputes_brought_total\":0,\"disputes_brought_against_total\":0}},{\"id\":\"b7bbdea6-ce08-4b40-84f6-cf5ef8d5a095\",\"description\":\"state machine battle\",\"outcome\":1,\"state\":1,\"disputed_at\":null,\"created_at\":\"2018-06-15T19:29:55.447Z\",\"updated_at\":\"2018-06-15T19:29:55.447Z\",\"url\":\"http://localhost:3000/battles/b7bbdea6-ce08-4b40-84f6-cf5ef8d5a095.json\",\"initiator\":{\"screenname\":\"spinosa\",\"wins_total\":0,\"losses_total\":0,\"wins_when_initiator\":0,\"losses_when_initiator\":0,\"wins_when_recipient\":0,\"losses_when_recipient\":0,\"disputes_brought_total\":0,\"disputes_brought_against_total\":0}}]".utf8)

        let battlesResource = Resource<[Battle]>(url: URL(string: "http://not.used")!)
        let battles = battlesResource.parse(jsonData)!
        print(battles)

        XCTAssertNotNil(battles)
        XCTAssertEqual(battles.count, 2)
    }

    func testTesting() {
        let x = XCTestExpectation()

        Webservice().load(Battle.all) { result in
            print(result)
            x.fulfill()
        }

        wait(for: [x], timeout: 1)
    }
    
}
