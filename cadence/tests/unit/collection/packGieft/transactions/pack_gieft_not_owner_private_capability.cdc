import "Giefts"
import "NonFungibleToken"
import "ExampleNFT"

// This transaction attempts to pack a gieft by using another accounts GieftCollection Public Capability
// it should fail because the packGieft function is only available to the GieftCollection Private Capability

transaction(owner: Address) {

    let capabilityPrivate: Capability<&Giefts.GieftCollection{Giefts.GieftCollectionPrivate}>
    let nfts: @{UInt64: NonFungibleToken.NFT}

    prepare(acct: AuthAccount) {
        self.capabilityPrivate = getAccount(owner).getCapability<&Giefts.GieftCollection{Giefts.GieftCollectionPrivate}>(Giefts.GieftsPublicPath)
        self.nfts <- {}
        let id = acct.borrow<&ExampleNFT.Collection>(from: ExampleNFT.CollectionStoragePath)!.getIDs()[0]
        let nft <- acct.borrow<&ExampleNFT.Collection>(from: ExampleNFT.CollectionStoragePath)!.withdraw(withdrawID: id)
        let oldNft <- self.nfts[nft.uuid] <- nft
        destroy oldNft
    }

    execute {
        let password: [UInt8] = HashAlgorithm.KECCAK_256.hash("abracadabra".utf8)
        self.capabilityPrivate.borrow()!.packGieft(name: "Test", password: password, nfts: <- self.nfts, registryCapability: nil)
    }
}