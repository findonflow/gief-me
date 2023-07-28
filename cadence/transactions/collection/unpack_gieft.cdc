import "Giefts"
import "NonFungibleToken"
import "ExampleNFT"

// This transaction unpacks a gieft and deposits the NFTs into the owner's nft collection

// @params gieftID: The ID of the gieft to unpack

transaction(gieftID: UInt64) {

    let collectionPrivate: &Giefts.GieftCollection{Giefts.GieftCollectionPrivate}
    let collectionPublic: Capability<&ExampleNFT.Collection{ExampleNFT.ExampleNFTCollectionPublic}>

    prepare(acct: AuthAccount) {
        self.collectionPrivate = acct.borrow<&Giefts.GieftCollection{Giefts.GieftCollectionPrivate}>(from: Giefts.GieftsStoragePath) 
            ?? panic("Could not borrow private giefts collection capability")
        self.collectionPublic = acct.getCapability<&ExampleNFT.Collection{ExampleNFT.ExampleNFTCollectionPublic}>(ExampleNFT.CollectionPublicPath)!
    }

    execute {
        let nfts: @{UInt64: NonFungibleToken.NFT}  <- self.collectionPrivate.unpackGieft(_gieft: gieftID)
        for nftID in nfts.keys {
            self.collectionPublic.borrow()!.deposit(token: <- nfts.remove(key: nftID)!)
        }
        destroy nfts
    }
}