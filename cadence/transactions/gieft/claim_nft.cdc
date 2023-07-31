import "Giefts"
import "NonFungibleToken"
import "MetadataViews"

// This transaction attempts to claim an nft from a gieft
// and deposit it into the authorizer's public collection

// @param gieftOwner: The address of the gieft owner
// @param gieftID: The ID of the gieft to claim an nft from
// @param password: The password of the gieft to claim an nft from

transaction(gieftOwner: Address, gieftID: UInt64, password: String) {

    let gieftPublic: &Giefts.Gieft{Giefts.GieftPublic}
    let collectionPublic: &AnyResource{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}

    prepare(acct: AuthAccount) {
        // Borrow the GieftCollection from the gieftOwner
        self.gieftPublic = getAccount(gieftOwner)
            .getCapability(Giefts.GieftsPublicPath)
            .borrow<&Giefts.GieftCollection{Giefts.GieftCollectionPublic}>()!
            .borrowGieft(gieftID) 
            ?? panic("Could not borrow gieft")

        // Get a refrence to a claimable NFT
        let nftRef = self.gieftPublic.borrowClaimableNFT() ?? panic("No NFTs to claim")

        // Get the nft collection data
        let nftCollectionData = nftRef.resolveView(Type<MetadataViews.NFTCollectionData>())! as! MetadataViews.NFTCollectionData

        // Initialize the NFT collection if it doesn't exist
        if acct.borrow<&AnyResource>(from: nftCollectionData.storagePath) == nil {
            // Create a new ExampleToken Vault and put it in storage
            acct.save(
                <-nftCollectionData.createEmptyCollection(),
                to: nftCollectionData.storagePath
            )

            // Create a public capability to the collection
            acct.link<&{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection}>(
                nftCollectionData.publicPath,
                target: nftCollectionData.storagePath
            )
        }

        // Borrow the public collection from the authorizer
        self.collectionPublic = 
            acct.getCapability(
                nftCollectionData.publicPath
                ).borrow<&AnyResource{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>()!
    }

    execute {
        self.gieftPublic.claimNft(password: password, collection: self.collectionPublic)
    }
}