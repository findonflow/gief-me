import "GiefMe"
import "NonFungibleToken"

// This transaction is used to add an NFT to a gieft
// It is called by the gieft owner
// @params gieftID: the ID of the gieft to add the NFT to
// @params withdrawID: the ID of the NFT to add to the gieft

transaction(gieftID: UInt64, withdrawID: UInt64, collectionPath: StoragePath) {

    let collectionPrivate: &GiefMe.GieftCollection{GiefMe.GieftCollectionPrivate}
    let nft: @NonFungibleToken.NFT

    prepare(acct: AuthAccount) {
        self.collectionPrivate = acct.borrow<&GiefMe.GieftCollection{GiefMe.GieftCollectionPrivate}>(from: GiefMe.GiefMeStoragePath) 
            ?? panic("Could not borrow private giefts collection capability")
        self.nft <- acct.borrow<&NonFungibleToken.Collection>(from: collectionPath)!.withdraw(withdrawID: withdrawID)
    }

    execute {
        self.collectionPrivate.addNftToGieft(gieft: gieftID,nft: <- self.nft)
    }
}