
import Test

import "TestUtils"

/**/////////////////////////////////////////////////////////////
//                              SETUP                         //
/////////////////////////////////////////////////////////////**/

pub fun setup() {
    // Contracts

    accounts["FindRegistry"] = admin

    blockchain.useConfiguration(Test.Configuration({
        "FindRegistry": admin.address
    }))
    
    deploy(
        "FindRegistry", 
        admin, 
        "../../../../contracts/FindRegistry.cdc")
}

/**/////////////////////////////////////////////////////////////
//                              TESTS                         //
/////////////////////////////////////////////////////////////**/

pub fun test_updateTTL_not_owner() {
    // Admin
    let owner = blockchain.createAccount()

    // User
    let user = blockchain.createAccount()

    // Create Registry
    txExecutor(
        "../../../../transactions/registry/create_registry.cdc", 
        [owner], 
        [/storage/TestRegistry, /private/TestRegistry, /public/TestRegistry, UInt64(420)],
        nil, 
        nil)

    // Try to update TTL as non-owner
    txExecutor(
        "../../../../transactions/registry/update_ttl.cdc", 
        [user], 
        [/storage/TestRegistry, UInt64(69)],
        "Could not borrow private registry capability", 
        ErrorType.TX_PANIC)
}

pub fun test_updateTTL() {
    // Admin
    let owner = blockchain.createAccount()

    // User
    let user = blockchain.createAccount()

    // Create Registry
    txExecutor(
        "../../../../transactions/registry/create_registry.cdc", 
        [owner], 
        [/storage/TestRegistry, /private/TestRegistry, /public/TestRegistry, UInt64(420)],
        nil, 
        nil)

    // Update TTL
    txExecutor(
        "../../../../transactions/registry/update_ttl.cdc", 
        [owner], 
        [/storage/TestRegistry, UInt64(69)],
        nil, 
        nil)
}

