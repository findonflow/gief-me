import Test
import "Test2"

/**/////////////////////////////////////////////////////////////
//                              SETUP                         //
/////////////////////////////////////////////////////////////**/

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

    deploy("Giefts", admin, "../contracts/Giefts.cdc")
    deploy("ExampleNFT", admin, "../modules/flow-utils/cadence/contract/ExampleNFT.cdc")
    deploy("MetadataViews", admin, "../modules/flow-utils/cadence/contract/MetadataViews.cdc")
}

