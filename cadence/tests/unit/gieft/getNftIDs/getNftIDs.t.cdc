
import Test

import "TestUtils"

/**/////////////////////////////////////////////////////////////
//                              SETUP                         //
/////////////////////////////////////////////////////////////**/

pub fun setup() {
    // Contracts

    accounts["ExampleNFT"] = admin
    accounts["GiefMe"] = admin
    accounts["FindRegistry"] = admin

    blockchain.useConfiguration(Test.Configuration({
        "ExampleNFT": admin.address,
        "GiefMe": admin.address,
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
        "GiefMe", 
        admin, 
        "../../../../contracts/GiefMe.cdc")
}

/**/////////////////////////////////////////////////////////////
//                              TESTS                         //
/////////////////////////////////////////////////////////////**/

pub fun test_getNftIDs () {
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
    let gieftNftIDs = scriptExecutor(
        "../../../../scripts/gieft/get_nft_ids.cdc",
        [owner.address, (gieftIDs as? [UInt64]?)!![0]])
}