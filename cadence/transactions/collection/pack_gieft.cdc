import "Giefts"
import "NonFungibleToken"

// This transaction withdraws NFTs from the ExampleNFT collection and packs them into a Gieft
// The Gieft is then stored in the GieftCollection
// The Gieft is encrypted with the password provided

// @params: name - the name of the Gieft
// @params: ids - the ids of the NFTs to be packed into the Gieft
// @params: password - the password to encrypt the Gieft with

transaction(name: String, ids: [UInt64], password: [UInt8], collectionPath: StoragePath) {

    let collectionPrivate: &Giefts.GieftCollection{Giefts.GieftCollectionPrivate}
    let nfts: @{UInt64: NonFungibleToken.NFT}

    prepare(acct: AuthAccount) {
        self.collectionPrivate = acct.borrow<&Giefts.GieftCollection{Giefts.GieftCollectionPrivate}>(from: Giefts.GieftsStoragePath) 
            ?? panic("Could not borrow private giefts collection capability")
        self.nfts <- {}
        for id in ids {
            let nft <- acct.borrow<&NonFungibleToken.Collection>(from: collectionPath)!.withdraw(withdrawID: id)
            let oldNft <- self.nfts[nft.uuid] <- nft
            destroy oldNft
        }
    }

    execute {
        self.collectionPrivate.packGieft(name: name, password: password, nfts: <- self.nfts, registryCapability: nil)
    }
}