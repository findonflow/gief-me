
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

pub fun test_packGieft_notOwner_publicCapability() {
    // Admin
    let owner = blockchain.createAccount()
    // User
    let not_owner = blockchain.createAccount()

    // Setup admin Gieft collection
    txExecutor("../../../../transactions/collection/create_gieft_collection.cdc",
        [owner], 
        [], 
        nil, 
        nil)

    // Setup user NFT collection
    txExecutor(
        "../../../../../modules/flow-utils/cadence/transactions/examplenft/setup.cdc", 
        [not_owner], 
        [], 
        nil, 
        nil)

    // Mint NFT
    txExecutor(
        "../../../../../modules/flow-utils/cadence/transactions/examplenft/mint.cdc", 
        [admin], 
        [not_owner.address], 
        nil, 
        nil)

    // Pack Gieft
    let errorMessage: String = "member of restricted type is not accessible: packGieft"

    txExecutor(
        "../packGieft/transactions/pack_gieft_not_owner_public_capability.cdc",
        [not_owner],
        [owner.address],
        errorMessage,
        ErrorType.TX_PANIC)
}

pub fun test_packGieft_notOwner_privateCapability() {
    // Admin
    let owner = blockchain.createAccount()
    // User
    let not_owner = blockchain.createAccount()

    // Setup admin Gieft collection
    txExecutor("../../../../transactions/collection/create_gieft_collection.cdc",
        [owner], 
        [], 
        nil, 
        nil)

    // Setup user NFT collection
    txExecutor(
        "../../../../../modules/flow-utils/cadence/transactions/examplenft/setup.cdc", 
        [not_owner], 
        [], 
        nil, 
        nil)

    // Mint NFT
    txExecutor(
        "../../../../../modules/flow-utils/cadence/transactions/examplenft/mint.cdc", 
        [admin], 
        [not_owner.address], 
        nil, 
        nil)

    // Pack Gieft
    let errorMessage: String = "unexpectedly found nil while forcing an Optional value"

    txExecutor(
        "../packGieft/transactions/pack_gieft_not_owner_private_capability.cdc",
        [not_owner],
        [owner.address],
        errorMessage,
        ErrorType.TX_PANIC)
}

pub fun test_packGieft () {
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
        "../packGieft/scripts/get_collection_ids.cdc",
        [owner.address])!

    txExecutor(
        "../../../../transactions/collection/pack_gieft.cdc",
        [owner],
        [ids, password],
        nil,
        nil)
}