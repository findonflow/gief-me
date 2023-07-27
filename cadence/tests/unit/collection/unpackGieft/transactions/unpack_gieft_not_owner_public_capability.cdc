import "Giefts"
import "NonFungibleToken"
import "ExampleNFT"

// This transaction attempts to unpack a gieft by using another accounts GieftCollection Public Capability
// it should fail because the unpackGieft function is only available to the GieftCollection Private Capability

transaction(owner: Address, gieftID: UInt64) {

    let capabilityPublic: Capability<&Giefts.GieftCollection{Giefts.GieftCollectionPublic}>
    let collectionPublic: Capability<&ExampleNFT.ExampleCollection{ExampleNFT.ExampleCollectionPublic}>

    prepare(acct: AuthAccount) {
        self.capabilityPublic = getAccount(owner).getCapability<&Giefts.GieftCollection{Giefts.GieftCollectionPublic}>(Giefts.GieftsPublicPath)
        self.collectionPublic = acct.getCapability<&ExampleNFT.ExampleCollection{ExampleNFT.ExampleCollectionPublic}>(ExampleNFT.CollectionPublicPath)!
    }

    execute {
        let nfts: @{UInt64: NonFungibleToken.NFT}  <- self.capabilityPublic.borrow()!.unpackGieft(_gieft: gieftID)
        for nftID in nfts.keys {
            self.collectionPublic.borrow()!.deposit(token: <- nfts.remove(key: nftID)!)
        }
        destroy nfts
    }
}