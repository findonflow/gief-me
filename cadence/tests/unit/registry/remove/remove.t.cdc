
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

pub fun test_remove_not_owner() {
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

    // Add address to registry
    txExecutor(
        "../../../../transactions/registry/add_to_registry.cdc", 
        [owner], 
        [/storage/TestRegistry, UInt64(420), user.address],
        nil, 
        nil)

    // Try to remove address from registry
    txExecutor(
        "../../../../transactions/registry/remove_from_registry.cdc", 
        [user], 
        [/storage/TestRegistry, UInt64(420), user.address],
        "Could not borrow private registry capability", 
        ErrorType.TX_PANIC)
}

pub fun test_remove() {
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

    // Add address to registry
    txExecutor(
        "../../../../transactions/registry/add_to_registry.cdc", 
        [owner], 
        [/storage/TestRegistry, UInt64(420), user.address],
        nil, 
        nil)

    // Remove address from registry
    txExecutor(
        "../../../../transactions/registry/remove_from_registry.cdc", 
        [owner], 
        [/storage/TestRegistry, UInt64(420), user.address],
        nil, 
        nil)
}

