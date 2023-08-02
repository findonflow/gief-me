
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

pub fun test_addNftToGieft_notOwner_publicCapability() {
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
        ["testName", ids, password],
        nil,
        nil)    

    // Add Nft to Gieft
    let errorMessage: String = "member of restricted type is not accessible: addNftToGieft"
    let gieftIDs = scriptExecutor(
        "../../../../scripts/collection/get_gieft_ids.cdc",
        [owner.address])!

    txExecutor(
        "../addNftToGieft/transactions/add_nft_to_gieft_not_owner_public_capability.cdc",
        [not_owner],
        [owner.address, (gieftIDs as? [UInt64]?)!![0]],
        errorMessage,
        ErrorType.TX_PANIC)
}

pub fun test_addNftToGieft_notOwner_privateCapability() {
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
        ["testName", ids, password],
        nil,
        nil)

    // Add Nft to Gieft
    let errorMessage: String = "unexpectedly found nil while forcing an Optional value"
    let gieftIDs = scriptExecutor(
        "../../../../scripts/collection/get_gieft_ids.cdc",
        [owner.address])!

    txExecutor(
        "../addNftToGieft/transactions/add_nft_to_gieft_not_owner_private_capability.cdc",
        [not_owner],
        [owner.address, (gieftIDs as? [UInt64]?)!![0]],
        errorMessage,
        ErrorType.TX_PANIC)
}

pub fun test_addNftToGieftgieft_does_not_exist () {
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

    // Add Nft to Gieft
    let errorMessage: String = "Gieft does not exist"
    let ids = scriptExecutor(
        "../../external/scripts/get_collection_ids.cdc",
        [owner.address])!

    txExecutor(
         "../../../../transactions/collection/add_nft_to_gieft.cdc",
        [owner],
        [0 as UInt64, (ids as? [UInt64]?)!![0]],
        errorMessage,
        ErrorType.TX_PANIC)
}

pub fun test_addNftToGieft() {
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

    // Mint NFT
    txExecutor(
        "../../../../../modules/flow-utils/cadence/transactions/examplenft/mint.cdc", 
        [admin], 
        [owner.address], 
        nil, 
        nil)

    // Pack Gieft
    let password: [UInt8] = HashAlgorithm.KECCAK_256.hash("a very secret password".utf8)
    var ids = scriptExecutor(
        "../../external/scripts/get_collection_ids.cdc",
        [owner.address])!

    txExecutor(
        "../../../../transactions/collection/pack_gieft.cdc",
        [owner],
        ["testName", [(ids as? [UInt64]?)!![0]], password],
        nil,
        nil)


    // Add Nft to Gieft
    let errorMessage: String = "Gieft does not exist"
    ids = scriptExecutor(
        "../../external/scripts/get_collection_ids.cdc",
        [owner.address])!
    let gieftIDs = scriptExecutor(
        "../../../../scripts/collection/get_gieft_ids.cdc",
        [owner.address])!
    txExecutor(
         "../../../../transactions/collection/add_nft_to_gieft.cdc",
        [owner],
        [(gieftIDs as? [UInt64]?)!![0], (ids as? [UInt64]?)!![0]],
        nil,
        nil)
}
