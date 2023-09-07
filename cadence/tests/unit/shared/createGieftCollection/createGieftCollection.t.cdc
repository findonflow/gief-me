
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

pub fun test_createGieftCollection() {
    // User
    let acct = blockchain.createAccount()

    // Initialize transaction
    txExecutor(
        "../../../../transactions/collection/create_gieft_collection.cdc", 
        [acct], 
        [], 
        nil, 
        nil)
}

pub fun test_createGieftCollection_alreadyCreated() {
    // User
    let acct = blockchain.createAccount()

    // Initialize transaction
    txExecutor(
        "../../../../transactions/collection/create_gieft_collection.cdc", 
        [acct], 
        [], 
        nil, 
        nil)
    txExecutor(
        "../../../../transactions/collection/create_gieft_collection.cdc", 
        [acct], 
        [], 
        nil, 
        nil)
}


