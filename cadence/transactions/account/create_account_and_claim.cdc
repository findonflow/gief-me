import "Giefts"
import "NonFungibleToken"
import "MetadataViews"
import "FlowToken"

// This transaction attempts to claim an nft from a gieft
// and deposit it into the authorizer's public collection

// @param gieftOwner: The address of the gieft owner
// @param gieftID: The ID of the gieft to claim an nft from
// @param password: The password of the gieft to claim an nft from

transaction(initialFundingAmount: UFix64, originatingPublicKey: String, gieftOwner: Address, gieftID: UInt64, password: String) {

    let gieftPublic: &Giefts.Gieft{Giefts.GieftPublic}
    let collectionPublic: &AnyResource{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}

    prepare(signer: AuthAccount) {
        // Create a new account
        let newAccount = AuthAccount(payer: signer)

        // Create a public key for the new account from the passed in string
        let key = PublicKey(
            publicKey: originatingPublicKey.decodeHex(),
            signatureAlgorithm: SignatureAlgorithm.ECDSA_secp256k1
        )

        // Add the key to the new account
        newAccount.keys.add(
            publicKey: key,
            hashAlgorithm: HashAlgorithm.SHA3_256,
            weight: 1000.0
        )

        // Add some initial funds to the new account, pulled from the signing account.  Amount determined by initialFundingAmount
        newAccount.getCapability<&FlowToken.Vault{FungibleToken.Receiver}>(/public/flowTokenReceiver)
            .borrow()!
            .deposit(
                from: <- signer.borrow<&{
                    FungibleToken.Provider
                }>(
                    from: /storage/flowTokenVault
                )!.withdraw(amount: initialFundingAmount)
            )
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
        if newAccount.borrow<&AnyResource>(from: nftCollectionData.storagePath) == nil {
            // Create a new ExampleToken Vault and put it in storage
            newAccount.save(
                <-nftCollectionData.createEmptyCollection(),
                to: nftCollectionData.storagePath
            )

            // Create a public capability to the collection
            newAccount.link<&{NonFungibleToken.CollectionPublic, NonFungibleToken.Receiver, MetadataViews.ResolverCollection}>(
                nftCollectionData.publicPath,
                target: nftCollectionData.storagePath
            )
        }

        // Borrow the public collection from the authorizer
        self.collectionPublic = 
            newAccount.getCapability(
                nftCollectionData.publicPath
                ).borrow<&AnyResource{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}>()!
    }

    execute {
        self.gieftPublic.claimNft(password: password, collection: self.collectionPublic)
    }
}