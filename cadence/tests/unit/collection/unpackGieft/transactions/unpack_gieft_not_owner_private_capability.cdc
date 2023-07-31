import "Giefts"
import "NonFungibleToken"
import "ExampleNFT"

// This transaction attempts to unpack a gieft by using another accounts GieftCollection Private Capability
// it should fail because the unpackGieft function is only available to the GieftCollection Private Capability which is
// only available to the owner of the GieftCollection

transaction(owner: Address, gieftID: UInt64) {

    let capabilityPrivate: Capability<&Giefts.GieftCollection{Giefts.GieftCollectionPrivate}>
    let collectionPublic: Capability<&ExampleNFT.Collection{ExampleNFT.ExampleNFTCollectionPublic}>

    prepare(acct: AuthAccount) {
        self.capabilityPrivate = getAccount(owner).getCapability<&Giefts.GieftCollection{Giefts.GieftCollectionPrivate}>(Giefts.GieftsPublicPath)
        self.collectionPublic = acct.getCapability<&ExampleNFT.Collection{ExampleNFT.ExampleNFTCollectionPublic}>(ExampleNFT.CollectionPublicPath)!
    }

    execute {
        let nfts: @{UInt64: NonFungibleToken.NFT}  <- self.capabilityPrivate.borrow()!.unpackGieft(gieft: gieftID)
        for nftID in nfts.keys {
            self.collectionPublic.borrow()!.deposit(token: <- nfts.remove(key: nftID)!)
        }
        destroy nfts
    }
}