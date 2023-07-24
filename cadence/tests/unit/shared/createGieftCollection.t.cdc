
import Test

import "BaseTest"


/**/////////////////////////////////////////////////////////////
//                              SETUP                         //
/////////////////////////////////////////////////////////////**/

pub fun setup() {

    //  Accounts
    
    let admin = blockchain.createAccount()

    // Contracts

    accounts["Giefts"] = admin

    blockchain.useConfiguration(Test.Configuration({
        "Giefts": admin.address
    }))

    deploy("Giefts", admin, "../../../contracts/Giefts.cdc")
}

/**/////////////////////////////////////////////////////////////
//                              TESTS                         //
/////////////////////////////////////////////////////////////**/

pub fun test_createGieftCollection() {
    let acct = blockchain.createAccount()
    txExecutor("../../../transactions/collection/create_gieft_collection.cdc", [acct], [], nil, nil)
}

pub fun test_createGieftCollection_alreadyCreated() {
    let acct = blockchain.createAccount()
    txExecutor("../../../transactions/collection/create_gieft_collection.cdc", [acct], [], nil, nil)
    txExecutor("../../../transactions/collection/create_gieft_collection.cdc", [acct], [], nil, nil)
}


