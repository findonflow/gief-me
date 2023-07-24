import NonFungibleToken from "../../../../cadence/contracts/NonFungibleToken.cdc"
import ExampleNFT from "../../../../cadence/contracts/ExampleNFT.cdc"

import ScopedNFTProviders from "../../../../cadence/contracts/ScopedNFTProviders.cdc"

transaction(ids: [UInt64], withdrawID: UInt64) {
    prepare(acct: AuthAccount) {
        let providerPath = /private/exampleNFTProvider
        acct.unlink(providerPath)
        acct.link<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(providerPath, target: ExampleNFT.CollectionStoragePath)

        let cap = acct.getCapability<&{NonFungibleToken.Provider, NonFungibleToken.CollectionPublic}>(providerPath)
        assert(cap.check(), message: "invalid private cap")
        
        let expiration = getCurrentBlock().timestamp - 1000.0
        let idFilter = ScopedNFTProviders.NFTIDFilter(ids)
        let scopedProvider <- ScopedNFTProviders.createScopedNFTProvider(provider: cap, filters: [idFilter], expiration: expiration)

        // this should fail!
        let nft <- scopedProvider.withdraw(withdrawID: withdrawID)
        destroy nft
        destroy scopedProvider
    }
}
