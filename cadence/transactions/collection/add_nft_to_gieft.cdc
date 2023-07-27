import "Giefts"
import "NonFungibleToken"
import "ExampleNFT"

// This transaction is used to add an NFT to a gieft
// It is called by the gieft owner
// @params gieftID: the ID of the gieft to add the NFT to
// @params withdrawID: the ID of the NFT to add to the gieft

transaction(gieftID: UInt64, withdrawID: UInt64) {

    let collectionPrivate: &Giefts.GieftCollection{Giefts.GieftCollectionPrivate}
    let nft: @NonFungibleToken.NFT

    prepare(acct: AuthAccount) {
        self.collectionPrivate = acct.borrow<&Giefts.GieftCollection{Giefts.GieftCollectionPrivate}>(from: Giefts.GieftsStoragePath) 
            ?? panic("Could not borrow private giefts collection capability")
        self.nft <- acct.borrow<&ExampleNFT.Collection>(from: ExampleNFT.CollectionStoragePath)!.withdraw(withdrawID: withdrawID)
    }

    execute {
        self.collectionPrivate.addNftToGieft(_gieft: gieftID, _nft: <- self.nft)
    }
}