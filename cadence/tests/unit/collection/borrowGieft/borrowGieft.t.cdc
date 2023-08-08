
import Test

import "TestUtils"

/**/////////////////////////////////////////////////////////////
//                              SETUP                         //
/////////////////////////////////////////////////////////////**/

pub fun setup() {
    // Contracts

    accounts["ExampleNFT"] = admin
    accounts["Giefts"] = admin

    blockchain.useConfiguration(Test.Configuration({
        "ExampleNFT": admin.address,
        "Giefts": admin.address
    }))
    
    deploy(
        "ExampleNFT", 
        admin, 
        "../../../../../modules/flow-utils/cadence/contracts/ExampleNFT.cdc")
    deploy(
        "Giefts", 
        admin, 
        "../../../../contracts/Giefts.cdc")
}

/**/////////////////////////////////////////////////////////////
//                              TESTS                         //
/////////////////////////////////////////////////////////////**/

pub fun test_borrowGieft_not_initialized () {
    // Owner
    let owner = blockchain.createAccount()

    // Get gieft reference
    let gieft = scriptExecutor(
        "../../../../scripts/collection/borrow_gieft.cdc",
        [owner.address, 0 as UInt64])

    // Assert
    assert(gieft == nil)
}

pub fun test_borrowGieft_empty () {
    // Owner
    let owner = blockchain.createAccount()

    // Setup owner Gieft collection
    txExecutor("../../../../transactions/collection/create_gieft_collection.cdc",
        [owner], 
        [], 
        nil, 
        nil)

    // Get gieft reference
    let gieft = scriptExecutor(
        "../../../../scripts/collection/borrow_gieft.cdc",
        [owner.address, 0 as UInt64])

    // Assert
    let expectedGieft = nil
    assert(gieft == expectedGieft)
}

pub fun test_borrowGieft () {
    // Admin
    let owner = blockchain.createAccount()

    // Setup owner Gieft collection
    txExecutor("../../../../transactions/collection/create_gieft_collection.cdc",
        [owner], 
        [], 
        nil, 
        nil)

    // Setup owner NFT collection
    txExecutor(
        "../../../../../modules/flow-utils/cadence/transactions/examplenft/setup.cdc", 
        [owner], 
        [], 
        nil, 
        nil)

    // Mint NFT
    txExecutor(
        "../../../../../modules/flow-utils/cadence/transactions/examplenft/mint.cdc", 
        [admin], 
        [owner.address], 
        nil, 
        nil)

     // Pack Gieft
    let password: [UInt8] = HashAlgorithm.KECCAK_256.hash("a very secret password".utf8)
    let ids = scriptExecutor(
        "../../external/scripts/get_collection_ids.cdc",
        [owner.address])!

    txExecutor(
        "../../../../transactions/collection/pack_gieft.cdc",
        [owner],
        ["testName", ids, password, /storage/exampleNFTCollection],
        nil,
        nil)
    
    // Get gieft ids
    let gieftIDs = scriptExecutor(
        "../../../../scripts/collection/get_gieft_ids.cdc",
        [owner.address])

    // Get gieft reference password
    let gieftPassword = scriptExecutor(
        "../borrowGieft/scripts/borrow_first_gieft_password.cdc",
        [owner.address])

    assert((gieftPassword as! [UInt8]?)! == password)
}