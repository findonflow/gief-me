import Test

pub enum ErrorType: UInt8 {
    pub case TX_PANIC
    pub case TX_ASSERT
    pub case TX_PRE
}

pub contract interface BaseTest {

    pub let blockchain: Test.Blockchain 
    pub let accounts: {String: AnyStruct}


    /**/////////////////////////////////////////////////////////////
    //                              SETUP                         //
    /////////////////////////////////////////////////////////////**/
    pub fun setup() {

        //  Accounts
        
        let admin = self.blockchain.createAccount()
        let user = self.blockchain.createAccount()
        let gifter_1 = self.blockchain.createAccount()
        let gifter_2 = self.blockchain.createAccount()
        
        // Contracts

        self.accounts["Giefts"] = admin
        self.accounts["ExampleNFT"] = admin
        self.accounts["MetadataViews"] = admin
        self.accounts["user"] = user
        self.accounts["gifter_1"] = gifter_1
        self.accounts["gifter_2"] = gifter_2

        self.blockchain.useConfiguration(Test.Configuration({
            "HybridCustody": admin.address,
            "Giefts": admin.address,
            "ExampleNFT": admin.address
        }))

        self.deploy("Giefts", admin, "../contracts/Giefts.cdc")
        self.deploy("ExampleNFT", admin, "../../modules/flow-utils/cadence/contracts/ExampleNFT.cdc")
        self.deploy("MetadataViews", admin, "../../modules/flow-utils/cadence/contract/MetadataViews.cdc")
    }


    pub fun deploy(_ contractName: String, _ account: Test.Account, _ path: String) {
        let err = self.blockchain.deployContract(
            name: contractName,
            code: Test.readFile(path),
            account: account,
            arguments: [],
        )

        Test.expect(err, Test.beNil())
        if err != nil {
            panic(err!.message)
        }
    }

    pub fun scriptExecutor(_ scriptName: String, _ arguments: [AnyStruct]): AnyStruct? {
        let scriptCode = self.loadCode(scriptName, "scripts")
        let scriptResult = self.blockchain.executeScript(scriptCode, arguments)

        if let failureError = scriptResult.error {
            panic(
                "Failed to execute the script because -:  ".concat(failureError.message)
            )
        }

        return scriptResult.returnValue
    }

    pub fun txExecutor(_ txName: String, _ signers: [Test.Account], _ arguments: [AnyStruct], _ expectedError: String?, _ expectedErrorType: ErrorType?): Bool {
        let txCode = self.loadCode(txName, "transactions")

        let authorizers: [Address] = []
        for signer in signers {
            authorizers.append(signer.address)
        }

        let tx = Test.Transaction(
            code: txCode,
            authorizers: authorizers,
            signers: signers,
            arguments: arguments,
        )

        let txResult = self.blockchain.executeTransaction(tx)
        if let err = txResult.error {
            if let expectedErrorMessage = expectedError {
                let ptr = self.getErrorMessagePointer(errorType: expectedErrorType!)
                let errMessage = err.message
                let hasEmittedCorrectMessage = self.contains(errMessage, expectedErrorMessage)
                let failureMessage = "Expecting - "
                    .concat(expectedErrorMessage)
                    .concat("\n")
                    .concat("But received - ")
                    .concat(err.message)
                assert(hasEmittedCorrectMessage, message: failureMessage)
                return true
            }
            panic(err.message)
        } else {
            if let expectedErrorMessage = expectedError {
                panic("Expecting error - ".concat(expectedErrorMessage).concat(". While no error triggered"))
            }
        }

        return txResult.status == Test.ResultStatus.succeeded
    }

    pub fun loadCode(_ fileName: String, _ baseDirectory: String): String {
        return Test.readFile("../".concat(baseDirectory).concat("/").concat(fileName))
    }

    pub fun getErrorMessagePointer(errorType: ErrorType): Int {
        return 0
    }

    // Copied functions from flow-utils so we can assert on error conditions
    // https://github.com/green-goo-dao/flow-utils/blob/main/cadence/contracts/StringUtils.cdc
    pub fun contains(_ s: String, _ substr: String): Bool {
        if let index = self.index(s, substr, 0) {
            return true
        }
        return false
    }

    // https://github.com/green-goo-dao/flow-utils/blob/main/cadence/contracts/StringUtils.cdc
    pub fun index(_ s: String, _ substr: String, _ startIndex: Int): Int? {
        for i in self.range(startIndex, s.length - substr.length + 1) {
            if s[i] == substr[0] && s.slice(from: i, upTo: i + substr.length) == substr {
                return i
            }
        }
        return nil
    }

    // https://github.com/green-goo-dao/flow-utils/blob/main/cadence/contracts/ArrayUtils.cdc
    pub fun rangeFunc(_ start: Int, _ end: Int, _ f: ((Int): Void)) {
        var current = start
        while current < end {
            f(current)
            current = current + 1
        }
    }

    pub fun range(_ start: Int, _ end: Int): [Int] {
        let res: [Int] = []
        self.rangeFunc(start, end, fun (i: Int) {
            res.append(i)
        })
        return res
    }
}