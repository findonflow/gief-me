import "Giefts"
import "NonFungibleToken"
import "ExampleNFT"

// This transaction attempts to add an nft to a gieft by using another accounts GieftCollection Private Capability
// it should fail because the addNftToGieft function is only available to the GieftCollection Private Capability

transaction(owner: Address, gieftID: UInt64) {

    let capabilityPrivate: Capability<&Giefts.GieftCollection{Giefts.GieftCollectionPrivate}>
    let nft: @NonFungibleToken.NFT

    prepare(acct: AuthAccount) {
        self.capabilityPrivate = getAccount(owner).getCapability<&Giefts.GieftCollection{Giefts.GieftCollectionPrivate}>(Giefts.GieftsPublicPath)
        let id = acct.borrow<&ExampleNFT.Collection>(from: ExampleNFT.CollectionStoragePath)!.getIDs()[0]
        self.nft <- acct.borrow<&ExampleNFT.Collection>(from: ExampleNFT.CollectionStoragePath)!.withdraw(withdrawID: id)
    }

    execute {
        self.capabilityPrivate.borrow()!.addNftToGieft(_gieft: gieftID, _nft: <- self.nft)
    }
}