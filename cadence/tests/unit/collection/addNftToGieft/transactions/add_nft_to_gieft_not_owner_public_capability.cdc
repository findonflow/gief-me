import "GiefMe"
import "NonFungibleToken"
import "ExampleNFT"

// This transaction attempts to add an nft to a gieft by using another accounts GieftCollection Public Capability
// it should fail because the addNftToGieft function is only available to the GieftCollection Private Capability which is
// only available to the owner of the GieftCollection

transaction(owner: Address, gieftID: UInt64) {

    let capabilityPublic: Capability<&GiefMe.GieftCollection{GiefMe.GieftCollectionPublic}>
    let nft: @NonFungibleToken.NFT

    prepare(acct: AuthAccount) {
        self.capabilityPublic = getAccount(owner).getCapability<&GiefMe.GieftCollection{GiefMe.GieftCollectionPublic}>(GiefMe.GiefMePublicPath)
        let id = acct.borrow<&ExampleNFT.Collection>(from: ExampleNFT.CollectionStoragePath)!.getIDs()[0]
        self.nft <- acct.borrow<&ExampleNFT.Collection>(from: ExampleNFT.CollectionStoragePath)!.withdraw(withdrawID: id)
    }

    execute {
        self.capabilityPublic.borrow()!.addNftToGieft(gieft: gieftID,nft: <- self.nft)
    }
}