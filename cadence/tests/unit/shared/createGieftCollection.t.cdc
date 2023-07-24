import "Test2"

pub fun test_createGieftCollection() {
   let acct = blockchain.createAccount()
   txExecutor("collection/create_gieft_collection.cdc", [acct], [], nil, nil)
}

pub fun test_createGieftCollection_alreadyCreated() {
    let acct = blockchain.createAccount()
    txExecutor("collection/create_gieft_collection.cdc", [acct], [], nil, nil)
    txExecutor("collection/create_gieft_collection.cdc", [acct], [], nil, nil)
}