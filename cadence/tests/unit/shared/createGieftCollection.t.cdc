import "Test2"
import Test

pub fun test_createGieftCollection() {
    let acct = blockchain.createAccount()
    txExecutor("../../../transactions/collection/create_gieft_collection.cdc", [acct], [], nil, nil)
}

pub fun test_createGieftCollection_alreadyCreated() {
    let acct = blockchain.createAccount()
    txExecutor("../../../transactions/collection/create_gieft_collection.cdc", [acct], [], nil, nil)
    txExecutor("../../../transactions/collection/create_gieft_collection.cdc", [acct], [], nil, nil)
}

pub fun setup() {

    //  Accounts
    
    let user = blockchain.createAccount()
    let gifter = blockchain.createAccount()
    let admin = blockchain.createAccount()
    
    // Contracts

    accounts["Giefts"] = admin
    accounts["ExampleNFT"] = admin
    accounts["MetadataViews"] = admin

    blockchain.useConfiguration(Test.Configuration({
        "HybridCustody": admin.address,
        "Giefts": admin.address,
        "ExampleNFT": admin.address
    }))

    deploy("Giefts", admin, "../../../contracts/Giefts.cdc")
    deploy("ExampleNFT", admin, "../../../../modules/flow-utils/cadence/contracts/ExampleNFT.cdc")
    deploy("MetadataViews", admin, "../../../../modules/flow-utils/cadence/contract/MetadataViews.cdc")
}