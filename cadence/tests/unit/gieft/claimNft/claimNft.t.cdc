
import Test

import "TestUtils"

/**/////////////////////////////////////////////////////////////
//                              SETUP                         //
/////////////////////////////////////////////////////////////**/

pub fun setup() {
    // Contracts

    accounts["ExampleNFT"] = admin
    accounts["Giefts"] = admin
    accounts["FindRegistry"] = admin

    blockchain.useConfiguration(Test.Configuration({
        "ExampleNFT": admin.address,
        "Giefts": admin.address,
        "FindRegistry": admin.address
    }))
    
    deploy(
        "ExampleNFT", 
        admin, 
        "../../../../../modules/flow-utils/cadence/contracts/ExampleNFT.cdc")
    deploy(
        "FindRegistry", 
        admin, 
        "../../../../contracts/FindRegistry.cdc")
    deploy(
        "Giefts", 
        admin, 
        "../../../../contracts/Giefts.cdc")
}

/**/////////////////////////////////////////////////////////////
//                              TESTS                         //
/////////////////////////////////////////////////////////////**/

pub fun test_claimNft_all_claimed_already() {
    // Admin
    let owner = blockchain.createAccount()

    // User
    let user = blockchain.createAccount()

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

    // Claim NFT
    let passwordString = "a very secret password"
    let gieftIDs = scriptExecutor(
    "../../../../scripts/collection/get_gieft_ids.cdc",
    [owner.address])

    txExecutor(
        "../../../../transactions/gieft/claim_nft.cdc",
        [user],
        [owner.address, (gieftIDs as? [UInt64]?)!![0], passwordString],
        nil,
        nil)

    // Claim NFT again
    txExecutor(
        "../../../../transactions/gieft/claim_nft.cdc",
        [user],
        [owner.address, (gieftIDs as? [UInt64]?)!![0], passwordString],
        "No NFTs to claim",
        ErrorType.TX_PRE)
}

pub fun test_claimNft_wrong_password() {
    // Admin
    let owner = blockchain.createAccount()

    // User
    let user = blockchain.createAccount()

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

    // Claim NFT
    let passwordString = "a very wrong password"
    let gieftIDs = scriptExecutor(
    "../../../../scripts/collection/get_gieft_ids.cdc",
    [owner.address])

    txExecutor(
        "../../../../transactions/gieft/claim_nft.cdc",
        [user],
        [owner.address, (gieftIDs as? [UInt64]?)!![0], passwordString],
        "Incorrect password",
        ErrorType.TX_PRE)
}

pub fun test_claimNft() {
    // Admin
    let owner = blockchain.createAccount()

    // User
    let user = blockchain.createAccount()

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

    // Claim NFT
    let passwordString = "a very secret password"
    let gieftIDs = scriptExecutor(
    "../../../../scripts/collection/get_gieft_ids.cdc",
    [owner.address])

    txExecutor(
        "../../../../transactions/gieft/claim_nft.cdc",
        [user],
        [owner.address, (gieftIDs as? [UInt64]?)!![0], passwordString],
        nil,
        nil)

    let ids2 = scriptExecutor(
        "../../external/scripts/get_collection_ids.cdc",
        [user.address])!

    // Assert
    assert(ids2 as? [UInt64]? == ids as? [UInt64]?)
}
