
import Test

import "TestUtils"

/**/////////////////////////////////////////////////////////////
//                              SETUP                         //
/////////////////////////////////////////////////////////////**/

pub fun setup() {
    // Contracts

    accounts["NonFungibleToken"] = admin
    accounts["Giefts"] = admin

    blockchain.useConfiguration(Test.Configuration({
        "NonFungibleToken": admin.address,
        "Giefts": admin.address
    }))
    
    deploy(
        "NonFungibleToken", 
        admin, 
        "../../../../modules/flow-utils/cadence/contracts/NonFungibleToken.cdc")
    deploy(
        "Giefts", 
        admin, 
        "../../../contracts/Giefts.cdc")
}

/**/////////////////////////////////////////////////////////////
//                              TESTS                         //
/////////////////////////////////////////////////////////////**/

pub fun test_createGieftCollection() {
    // User
    let acct = blockchain.createAccount()

    // Initialize transaction
    txExecutor(
        "../../../transactions/collection/create_gieft_collection.cdc", 
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
        "../../../transactions/collection/create_gieft_collection.cdc", 
        [acct], 
        [], 
        nil, 
        nil)
    txExecutor(
        "../../../transactions/collection/create_gieft_collection.cdc", 
        [acct], 
        [], 
        nil, 
        nil)
}


