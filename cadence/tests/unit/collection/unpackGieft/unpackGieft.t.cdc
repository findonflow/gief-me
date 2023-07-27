
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

pub fun test_unpackGieft_notOwner_publicCapability() {
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

    // Unpack Gieft
    let errorMessage: String = "member of restricted type is not accessible: unpackGieft"

    txExecutor(
        "../unpackGieft/transactions/unpack_gieft_not_owner_public_capability.cdc",
        [not_owner],
        [owner.address, 0 as UInt64],
        errorMessage,
        ErrorType.TX_PANIC)
}

pub fun test_unpackGieft_notOwner_privateCapability() {
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

    // Unack Gieft
    let errorMessage: String = "unexpectedly found nil while forcing an Optional value"

    txExecutor(
        "../unpackGieft/transactions/unpack_gieft_not_owner_private_capability.cdc",
        [not_owner],
        [owner.address, 0 as UInt64],
        errorMessage,
        ErrorType.TX_PANIC)
}

pub fun test_unpackGieft_does_not_exist() {
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

    // Unack Gieft
    let errorMessage: String = "Gieft does not exist"

    txExecutor(
    "../../../../transactions/collection/unpack_gieft.cdc",
    [owner],
    [0 as UInt64],
    errorMessage,
    ErrorType.TX_PRE)
}

pub fun test_unpackGieft() {
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
    
    // Get NFT IDs
    let nftIds = scriptExecutor(
            "../../external/scripts/get_collection_ids.cdc",
            [owner.address])!

    let password: [UInt8] = HashAlgorithm.KECCAK_256.hash("a very secret password".utf8)

    // Pack Gieft
    txExecutor(
        "../../../../transactions/collection/pack_gieft.cdc",
        [owner],
        [nftIds , password],
        nil,
        nil)

    // Get Gieft IDs
    let gieftIDs = scriptExecutor(
            "../../../../scripts/collection/get_gieft_ids.cdc",
            [owner.address])!

    // Unpack Gieft
    txExecutor(
        "../../../../transactions/collection/unpack_gieft.cdc",
        [owner],
        [(gieftIDs as? [UInt64]?)!![0]],
        nil,
        nil)

    // Get NFT IDs
    let nftIdsAfter = scriptExecutor(
                "../../external/scripts/get_collection_ids.cdc",
                [owner.address])!

    // Assert
    assert(nftIds as? [UInt64]== nftIdsAfter as? [UInt64])
}
