import Test

import "BaseTest"

pub contract TestGieftCollection: BaseTest {

    pub let blockchain: Test.Blockchain 
    pub let accounts: {String: AnyStruct}

    pub fun test_createGieftCollection() {
        let acct = self.blockchain.createAccount()
        self.txExecutor("../../../transactions/collection/create_gieft_collection.cdc", [acct], [], nil, nil)
    }

    pub fun test_createGieftCollection_alreadyCreated() {
        let acct = self.blockchain.createAccount()
        self.txExecutor("../../../transactions/collection/create_gieft_collection.cdc", [acct], [], nil, nil)
        self.txExecutor("../../../transactions/collection/create_gieft_collection.cdc", [acct], [], nil, nil)
    }

    init () {
        self.blockchain = Test.newEmulatorBlockchain()
        self.accounts = {}
    }
}

