import Test
import "Test2"

/**/////////////////////////////////////////////////////////////
//                              SETUP                         //
/////////////////////////////////////////////////////////////**/

pub fun setup() {

    //  Accounts
    
    let admin = blockchain.createAccount()
    let user = blockchain.createAccount()
    let gifter_1 = blockchain.createAccount()
    let gifter_2 = blockchain.createAccount()
    
    // Contracts

    accounts["Giefts"] = admin
    accounts["ExampleNFT"] = admin
    accounts["MetadataViews"] = admin
    accounts["user"] = user
    accounts["gifter_1"] = gifter_1
    accounts["gifter_2"] = gifter_2

    blockchain.useConfiguration(Test.Configuration({
        "HybridCustody": admin.address,
        "Giefts": admin.address,
        "ExampleNFT": admin.address
    }))

    deploy("Giefts", admin, "../contracts/Giefts.cdc")
    deploy("ExampleNFT", admin, "../../modules/flow-utils/cadence/contracts/ExampleNFT.cdc")
    deploy("MetadataViews", admin, "../../modules/flow-utils/cadence/contract/MetadataViews.cdc")
}

