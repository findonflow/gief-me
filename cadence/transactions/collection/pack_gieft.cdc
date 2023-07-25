import "Giefts"
import "NonFungibleToken"
import "ExampleNFT"

// This transaction attempts to pack a gieft by using another accounts GieftCollection Public Capability
// it should fail because the packGieft function is only available to the GieftCollection Private Capability

transaction(ids: [UInt64], password: [UInt8]) {

    let collectionPrivate: &Giefts.GieftCollection{Giefts.GieftCollectionPrivate}
    let nfts: @{UInt64: NonFungibleToken.NFT}

    prepare(acct: AuthAccount) {
        self.collectionPrivate = acct.borrow<&Giefts.GieftCollection{Giefts.GieftCollectionPrivate}>(from: Giefts.GieftsStoragePath) 
            ?? panic("Could not borrow private giefts collection capability")
        self.nfts <- {}
        for id in ids {
            let nft <- acct.borrow<&ExampleNFT.Collection>(from: ExampleNFT.CollectionStoragePath)!.withdraw(withdrawID: id)
            let oldNft <- self.nfts[nft.uuid] <- nft
            destroy oldNft
        }
    }

    execute {
        self.collectionPrivate.packGieft(_password: password, _nfts: <- self.nfts)
    }
}