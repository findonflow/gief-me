import "Giefts"
import "NonFungibleToken"
import "ExampleNFT"
import "MetadataViews"

// This transaction attempts to claim an nft from a gieft
// and deposit it into the authorizer's public collection

// @param gieftOwner: The address of the gieft owner
// @param gieftID: The ID of the gieft to claim an nft from
// @param password: The password of the gieft to claim an nft from

transaction(gieftOwner: Address, gieftID: UInt64, password: String) {

    let gieftPublic: &Giefts.GieftCollection{Giefts.GieftCollectionPublic}
    let collectionPublic: Capability<&ExampleNFT.Collection{ExampleNFT.ExampleNFTCollectionPublic}>

    prepare(acct: AuthAccount) {
        // Initialize the NFT collection if it doesn't exist
        if acct.borrow<&AnyResource>(from: ExampleNFT.CollectionStoragePath) == nil {
            // Create a new ExampleToken Vault and put it in storage
            acct.save(
                <-ExampleNFT.createEmptyCollection(),
                to: ExampleNFT.CollectionStoragePath
            )

            // Create a public capability to the Vault that only exposes
            // the balance field through the Balance interface
            acct.link<&ExampleNFT.Collection{NonFungibleToken.CollectionPublic, ExampleNFT.ExampleNFTCollectionPublic, MetadataViews.ResolverCollection}>(
                ExampleNFT.CollectionPublicPath,
                target: ExampleNFT.CollectionStoragePath
            )
        }

        // Borrow the GieftCollection from the gieftOwner
        self.gieftPublic = getAccount(gieftOwner).getCapability(Giefts.GieftsPublicPath).borrow<&Giefts.GieftCollection{Giefts.GieftCollectionPublic}>()!

        // Get the public NFT collection from the current account
        self.collectionPublic = acct.getCapability<&ExampleNFT.Collection{ExampleNFT.ExampleNFTCollectionPublic}>(ExampleNFT.CollectionPublicPath)!
    }

    execute {
        let nft: @NonFungibleToken.NFT  <- self.gieftPublic.borrowGieft(gieftID)!.claimNft(_password: password)
        self.collectionPublic.borrow()!.deposit(token: <- nft)
    }
}