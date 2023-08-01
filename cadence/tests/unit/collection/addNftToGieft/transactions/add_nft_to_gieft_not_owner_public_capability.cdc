import "Giefts"
import "NonFungibleToken"
import "ExampleNFT"

// This transaction attempts to add an nft to a gieft by using another accounts GieftCollection Public Capability
// it should fail because the addNftToGieft function is only available to the GieftCollection Private Capability which is
// only available to the owner of the GieftCollection

transaction(owner: Address, gieftID: UInt64) {

    let capabilityPublic: Capability<&Giefts.GieftCollection{Giefts.GieftCollectionPublic}>
    let nft: @NonFungibleToken.NFT

    prepare(acct: AuthAccount) {
        self.capabilityPublic = getAccount(owner).getCapability<&Giefts.GieftCollection{Giefts.GieftCollectionPublic}>(Giefts.GieftsPublicPath)
        let id = acct.borrow<&ExampleNFT.Collection>(from: ExampleNFT.CollectionStoragePath)!.getIDs()[0]
        self.nft <- acct.borrow<&ExampleNFT.Collection>(from: ExampleNFT.CollectionStoragePath)!.withdraw(withdrawID: id)
    }

    execute {
        self.capabilityPublic.borrow()!.addNftToGieft(gieft: gieftID,nft: <- self.nft)
    }
}